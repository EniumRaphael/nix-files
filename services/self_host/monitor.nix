{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.monitor;
  dashboardsDir = ../../assets/grafana_dashboards;
  grafanaLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/a/a1/Grafana_logo.svg";
    name = "grafana.svg";
    sha256 = "sha256-UjE6ArLCa52o3XGUmpqPoakbEOeFi+zfsnATi1FtWmQ=";
  };
  monitoredUrls = [
    "https://auth.enium.eu"
    "https://git.enium.eu"
    "https://jellyfin.enium.eu"
    "https://monitor.enium.eu"
    "https://nextcloud.enium.eu"
    "https://radarr.enium.eu"
    "https://sonarr.enium.eu"
    "https://vault.enium.eu"
    "https://raphael.parodi.pro"
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
        mode = "0400";
      };

      "grafana-mail-password" = {
        file = ../../secrets/grafana-mail-password.age;
        owner = "grafana";
        group = "alertmanager";
        mode = "0440";
      };
    };

    services = {
      kanidm = {
        provision = {
          systems.oauth2.grafana = {
            present = true;
            displayName = "Grafana";
            imageFile = grafanaLogo;
            originUrl = "https://monitor.enium.eu";
            originLanding = "https://monitor.enium.eu/login/generic_oauth";
            basicSecretFile = config.age.secrets.grafana-oidc-secret.path;
            public = false;
            enableLocalhostRedirects = false;
            allowInsecureClientDisablePkce = false;
            preferShortUsername = true;
            scopeMaps = {
              grafana_superadmins = [
                "email"
                "openid"
                "profile"
                "groups"
              ];
              grafana_admins = [
                "email"
                "openid"
                "profile"
                "groups"
              ];
              grafana_editors = [
                "email"
                "openid"
                "profile"
                "groups"
              ];
              grafana_users = [
                "email"
                "openid"
                "profile"
                "groups"
              ];
            };
            claimMaps = {
              groups = {
                joinType = "array";
                valuesByGroup = {
                  grafana_superadmins = [
                    "grafana_superadmins"
                  ];
                  grafana_admins = [
                    "grafana_admins"
                  ];
                  grafana_editors = [
                    "grafana_editors"
                  ];
                  grafana_users = [
                    "grafana_users"
                  ];
                };
              };
            };
          };
        };
      };
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
              name = "Loki";
              type = "loki";
              uid = "loki";
              access = "proxy";
              url = "http://127.0.0.1:3100";
              editable = false;
            }
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

          smtp = {
            enabled = true;
            host = "smtp.migadu.com:465";
            from_address = "grafana@enium.eu";
            from_name = "Grafana";
            user = "grafana@enium.eu";
            password = "$__file{${config.age.secrets.grafana-mail-password.path}}";
            startTLS_policy = "NoStartTLS";
          };

          "auth.generic_oauth" = {
            enabled = true;
            name = "Enium";
            allow_sign_up = true;
            client_id = "grafana";
            client_secret = "$__file{${config.age.secrets.grafana-oidc-secret.path}}";
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
            secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
            cookie_secure = true;
            cookie_samesite = "none";
            allow_embedding = true;
          };
        };
      };
      prometheus = {
        enable = true;
        checkConfig = false;
        alertmanager = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = 9093;
          configuration = {
            global = {
              smtp_smarthost = "smtp.migadu.com:465";
              smtp_from = "grafana@enium.eu";
              smtp_auth_username = "grafana@enium.eu";
              smtp_auth_password_file = config.age.secrets.grafana-mail-password.path;
              smtp_require_tls = false;
            };

            route = {
              receiver = "email-default";
              group_by = [
                "alertname"
                "severity"
              ];
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "3h";

              routes = [
                {
                  match = {
                    severity = "critical";
                  };
                  receiver = "email-critical";
                  repeat_interval = "1h";
                }
              ];
            };

            receivers = [
              {
                name = "email-critical";
                email_configs = [
                  {
                    to = "raphael@enium.eu";
                    send_resolved = true;
                  }
                ];
              }
              {
                name = "email-default";
                email_configs = [
                  {
                    to = "raphael@enium.eu";
                    send_resolved = true;
                  }
                ];
              }
            ];
          };
        };
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
            job_name = "blackbox_http_probe";
            metrics_path = "/probe";
            params = {
              module = [
                "http_2xx"
              ];
            };
            static_configs = [
              {
                targets = monitoredUrls;
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
      nginx = {
        enable = true;
        virtualHosts."monitor.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };
      };
    };

    systemd.services = {
      alloy.serviceConfig.SupplementaryGroups = [ "systemd-journal" ];
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    environment.etc = {
      "grafana/dashboards".source = dashboardsDir;
      "prometheus/services.rules".text = ''
        groups:
        - name: services
          rules:
          - alert: ServiceDown
            expr: node_systemd_unit_state{state="failed"} == 1
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Service {{ $labels.name }} en échec"
              description: "Le service {{ $labels.name }} est en état 'failed' depuis >1m sur {{ $labels.instance }}."
      '';
    };

  };
}
