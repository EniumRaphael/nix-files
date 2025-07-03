{ config, pkgs, lib, ... }:

let
	cfg = config.service.selfhost.ollama;
in
{
	services = {
		ollama = {
			enable = true;
			loadModels = [
				"qwen2.5:3b"
			];
			acceleration = "cuda";
		};

		open-webui = {
			enable = true;
			port = 13007;
		};
		nginx.virtualHosts."ollama.enium.eu" = {
			enableACME = true;
			forceSSL = true;
			locations."/" = {
				proxyPass = "http://127.0.0.1:13007";
				proxyWebsockets = true;
			};
		};
	};
}
