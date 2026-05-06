{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.monitor;
  dashboardsDir = ../../assets/grafana_dashboards;
  oidc-secret = config.age.secrets.grafana-oidc-secret.path;
  encryption-key = config.age.secrets.grafana-secret-key.path;
  monitored = [
    "nginx"
    "grafana"
  ];
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "grafana-oidc-secret" = {
        file = ../../secrets/grafana-oidc-secret.age;
        owner = "kanidm";
        group = "grafana";
        mode = "0440";
      };

      "grafana-secret-key" = {
        file = ../../secrets/grafana-secret-key.age;
        owner = "grafana";
        group = "grafana";
        mode = "0440";
      };
    };

    services = {
      grafana = {
        enable = true;
        package = pkgs.grafana;
        dataDir = "/var/lib/grafana";
        provision = {
          dashboards.settings.providers = [
            {
              name = "nixos-dashboards";
              type = "file";
              updateIntervalSeconds = 30;
              editable = false;

              options = {
                path = "/etc/grafana/dashboards";
                foldersFromFilesStructure = false;
              };
            }
          ];
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              uid = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:9090";
              isDefault = true;
              editable = false;
              jsonData = {
                httpMethod = "POST";
                timeInterval = "15s";
              };
            }
          ];
        };
        settings = {
          server = {
            root_url = "https://monitor.enium.eu";
            domain = "monitor.enium.eu";
            serve_from_sub_path = false;
          };

          "auth.generic_oauth" = {
            enabled = true;
            name = "Enium";
            allow_sign_up = true;
            client_id = "grafana";
            client_secret = "$__file{${oidc-secret}}";
            scopes = "openid profile email groups";
            auth_url = "https://auth.enium.eu/ui/oauth2";
            token_url = "https://auth.enium.eu/oauth2/token";
            api_url = "https://auth.enium.eu/oauth2/openid/grafana/userinfo";
            redirect_uri = "https://monitor.enium.eu/login/generic_oauth";
            use_pkce = true;
            use_refresh_token = true;
            login_attribute_path = "preferred_username";
            name_attribute_path = "name";
            email_attribute_path = "email";
            groups_attribute_path = "groups";
            role_attribute_path = "contains(groups, 'grafana_superadmins@enium.eu') && 'GrafanaAdmin' || contains(groups, 'grafana_admins@enium.eu') && 'Admin' || contains(groups, 'grafana_editors@enium.eu') && 'Editor' || 'Viewer'";
            allow_assign_grafana_admin = true;
            role_attribute_strict = false;
            skip_org_role_sync = false;
          };
          log.level = "debug";
          auth = {
            disable_login_form = true;
            disable_signout_menu = false;
          };
          security = {
            secret_key = "$__file{${encryption-key}}";
            cookie_secure = true;
            cookie_samesite = "none";
            allow_embedding = true;
          };
        };
      };
      prometheus = {
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
                  "https://auth.enium.eu"
                  "https://git.enium.eu"
                  "https://htop.enium.eu"
                  "https://jellyfin.enium.eu"
                  "https://monitor.enium.eu"
                  "https://nextcloud.enium.eu"
                  "https://radarr.enium.eu"
                  "https://sonarr.enium.eu"
                  "https://vault.enium.eu"
                  "https://ollama.enium.eu"
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
      loki = {
        enable = true;
        configuration = {
          auth_enabled = false;
          server = {
            http_listen_port = 3100;
            grpc_listen_port = 9095;
          };
          common = {
            path_prefix = "/var/lib/loki";
            storage = {
              filesystem = {
                chunks_directory = "/var/lib/loki/chunks";
                rules_directory = "/var/lib/loki/rules";
              };
            };
            replication_factor = 1;
            ring = {
              instance_addr = "127.0.0.1";
              kvstore.store = "inmemory";
            };
          };
          schema_config = {
            configs = [
              {
                from = "2024-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };
        };
      };
      alloy = {
        enable = true;
        configPath = pkgs.writeText "config.alloy" ''
          loki.source.journal "systemd" {
            forward_to = [loki.relabel.journal.receiver]
            relabel_rules = loki.relabel.journal.rules
            labels = {
              job = "systemd-journal",
            }
          }

          loki.relabel "journal" {
            forward_to = [loki.write.local.receiver]

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }

            rule {
              source_labels = ["__journal_priority_keyword"]
              target_label  = "level"
            }

            rule {
              source_labels = ["__journal__hostname"]
              target_label  = "hostname"
            }

            rule {
              source_labels = ["__journal_syslog_identifier"]
              target_label  = "syslog_identifier"
            }
          }

          loki.write "local" {
            endpoint {
              url = "http://localhost:3100/loki/api/v1/push"
            }
          }
        '';
      };
      nginx.virtualHosts."monitor.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
    };

    systemd.services = {
      alloy.serviceConfig.SupplementaryGroups = [ "systemd-journal" ];
      process_exporter = {
        description = "Prometheus Process Exporter";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.prometheus-process-exporter}/bin/process-exporter --config.path /etc/process-exporter.json";
          Restart = "always";
        };
      };
    };

    environment.etc = {
      "process-exporter.json".text = builtins.toJSON {
        procMatchers = lib.map (svc: {
          name = svc;
          cmdline = [
            "${svc}:"
          ];
        }) monitored;
      };
      "grafana/dashboards".source = dashboardsDir;
      "prometheus/services.rules".text = ''
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
    };

  };
}
