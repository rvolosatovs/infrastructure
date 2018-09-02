{ config, lib, ... }:
with lib;
mkMerge [
  {
    services.deluge.enable = true;
    services.deluge.web.enable = true;
  }
  (mkIf config.services.nginx.enable {
    services.nginx.virtualHosts."deluge".enableACME = true;
    services.nginx.virtualHosts."deluge".forceSSL = true;
    services.nginx.virtualHosts."deluge".locations."/".proxyPass = "http://localhost:8112";
  })
]
