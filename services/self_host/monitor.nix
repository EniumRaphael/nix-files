{ config, pkgs, lib, ... }:

let
	cfg = config.service.selfhost.monitor;
	monitored = [ "nginx" "grafana" ];
	email = "raphael@enium.eu";
in
{
	config = lib.mkIf cfg {
		services.grafana = {
			enable = true;
			package = pkgs.grafana;
			dataDir = "/var/lib/grafana";
		};
	
		environment.etc."process-exporter.json".text = builtins.toJSON {
			procMatchers = lib.map (svc: {
				name    = svc;
				cmdline = [
					"${svc}:"
				];
			}) monitored;
		};
	
		systemd.services.process_exporter = {
			description = "Prometheus Process Exporter";
			after       = [ "network.target" ];
			wantedBy    = [ "multi-user.target" ];
			serviceConfig = {
				ExecStart = "${pkgs.prometheus-process-exporter}/bin/process-exporter --config.path /etc/process-exporter.json";
				Restart   = "always";
			};
		};
	
		services.prometheus = {
			enable = true;
			checkConfig = false;
			exporters = {
				blackbox = {
					enable = true;
					configFile = pkgs.writeText "blackbox-exporter.yml" ''
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        valid_status_codes: []
        method: GET
        no_follow_redirects: false
        fail_if_not_ssl: false
'';
				};
				node.enable = true;
				systemd.enable = true;
			};
			scrapeConfigs = [
				{
					job_name = "systemd_exporter";
					metrics_path = "/metrics";
					static_configs = [{
						targets = [
							"127.0.0.1:9558"
						];
					}];
				}
				{
					job_name = "node_exporter";
					static_configs = [{
						targets = [
							"127.0.0.1:9100"
						];
					}];
				}
				{
					job_name = "process_exporter";
					metrics_path = "/metrics";
					scheme = "http";
					static_configs = [{
						targets = [
							"127.0.0.1:9256"
						];
					}];
				}
				{
					job_name = "blackbox_http_probe";
					metrics_path = "/probe";
					params = {
						module = [
							"http_2xx"
						];
					};
					static_configs = [{
						targets = [
							"https://raphael.parodi.pro"
							"https://nextcloud.enium.eu"
							"https://htop.enium.eu"
							"https://monitor.enium.eu"
							"https://ollama.enium.eu"
							"http://relance-pas-stp.me:4242"
						];
					}];
					relabel_configs = [
						{ source_labels = [ "__address__" ];
							target_label  = "__param_target";
						}
						{ source_labels = [ "__param_target" ];
							target_label  = "instance";
						}
						{ target_label = "__address__";
							replacement  = "127.0.0.1:9115";
						}
					];
					proxy_url = "http://127.0.0.1:9115";
				}
			];
			ruleFiles = lib.mkForce [ "/etc/prometheus/services.rules" ];
		};
	
		environment.etc."prometheus/services.rules".text = ''
groups:
- name: services
  rules:
  - alert: nginxServiceDown
    expr: process_up{job="process_exporter",name="nginx"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Processus nginx arrêté"
      description: "Le processus nginx ne tourne plus depuis >1m."

  - alert: nginxServiceUp
    expr: process_up{job="process_exporter",name="nginx"} == 1
    for: 1m
    labels:
      severity: info
    annotations:
      summary: "Processus nginx rétabli"
      description: "Le processus nginx tourne de nouveau."

  - alert: grafanaServiceDown
    expr: process_up{job="process_exporter",name="grafana"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Processus grafana arrêté"
      description: "Le processus grafana ne tourne plus depuis >1m."

  - alert: grafanaServiceUp
    expr: process_up{job="process_exporter",name="grafana"} == 1
    for: 1m
    labels:
      severity: info
    annotations:
      summary: "Processus grafana rétabli"
      description: "Le processus grafana tourne de nouveau."
'';

		services.nginx.virtualHosts."monitor.enium.eu" = {
			enableACME      = true;
			forceSSL        = true;
			locations."/" = {
				proxyPass       = "http://127.0.0.1:3000";
				proxyWebsockets = true;
			};
		};
	};
}
