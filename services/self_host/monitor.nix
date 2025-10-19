{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.monitor;
  monitored = [
    "nginx"
    "grafana"
  ];
  authentik-grafana-id = config.age.secrets."auth-grafana-id".path;
  authentik-grafana-secret =config.age.secrets."auth-grafana-secret".path;
in
{
  config = lib.mkIf cfg {
    services.grafana = {
      enable = true;
      package = pkgs.grafana;
      dataDir = "/var/lib/grafana";

      settings = {
        server = {
          root_url = "https://monitor.enium.eu";
          domain = "monitor.enium.eu";
          serve_from_sub_path = false;
        };

        users = {
          auto_assign_org = true;
          auto_assign_org_role = "Viewer";
        };

        auth = {
          disable_login_form = true;
          disable_signout_menu = false;
        };

        security = {
          allow_embedding = true;
        };

        "auth.generic_oauth" = {
          enabled = true;
          name = "Enium";
          allow_sign_up = true;

          client_id = "$__file{${authentik-grafana-id}}";
          client_secret = "$__file{${authentik-grafana-secret}}";

          scopes = "openid profile email groups";
          auth_url = "https://auth.enium.eu/application/o/authorize/";
          token_url = "https://auth.enium.eu/application/o/token/";
          api_url = "https://auth.enium.eu/application/o/userinfo/";
          redirect_uri = "https://monitor.enium.eu/login/generic_oauth";

          use_pkce = true;
          use_refresh_token = true;
          login_attribute_path = "preferred_username";
          name_attribute_path = "name";
          email_attribute_path = "email";
          groups_attribute_path = "groups";

          role_attribute_path = "contains(groups, 'Direction') && 'Admin' || contains(groups, 'ResponsableIT') && 'Admin' || contains(groups, 'EquipeIT') && 'Editor' || 'Viewer'";
          allow_assign_grafana_admin = true;
          role_attribute_strict = false;
          skip_org_role_sync = false;
        };
      };
    };

    environment.etc."process-exporter.json".text = builtins.toJSON {
      procMatchers = lib.map (svc: {
        name = svc;
        cmdline = [
          "${svc}:"
        ];
      }) monitored;
    };

    systemd.services.process_exporter = {
      description = "Prometheus Process Exporter";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-process-exporter}/bin/process-exporter --config.path /etc/process-exporter.json";
        Restart = "always";
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
          static_configs = [
            {
              targets = [
                "127.0.0.1:9558"
              ];
            }
          ];
        }
        {
          job_name = "node_exporter";
          static_configs = [
            {
              targets = [
                "127.0.0.1:9100"
              ];
            }
          ];
        }
        {
          job_name = "process_exporter";
          metrics_path = "/metrics";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "127.0.0.1:9256"
              ];
            }
          ];
        }
        {
          job_name = "blackbox_http_probe";
          metrics_path = "/probe";
          params = {
            module = [
              "http_2xx"
            ];
          };
          static_configs = [
            {
              targets = [
                "https://raphael.parodi.pro"
                "https://nextcloud.enium.eu"
                "https://htop.enium.eu"
                "https://monitor.enium.eu"
                "https://ollama.enium.eu"
                "http://relance-pas-stp.me:4242"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:9115";
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
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
