{
  description = "ssswithnix - Serving a static site with Nginx built with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        nginxPort = "80";
        nginxConf = pkgs.writeText "nginx.conf" ''
          user nobody nobody;
          daemon off;
          error_log /dev/stdout info;
          pid /dev/null;
          events {}
          http {
            access_log /dev/stdout;
            server {
              listen ${nginxPort};
              index index.html;
              location / {
                root ${contentDir};
              }
            }
          }
        '';
        nginxWebRoot = pkgs.writeTextDir "index.html" ''
          <html><body><h1>Hello from NGINX wrapped by Nix</h1></body></html>
        '';
        contentDir = builtins.filterSource (path: type: type != "directory" || baseNameOf path != ".svn") ./content;
      in
      rec {
        packages.container = pkgs.dockerTools.buildLayeredImage {
          name = "ssswithnix";
          tag = "flake";
          created = "now";
          contents = [
            pkgs.fakeNss
            pkgs.nginx
            contentDir
          ];

          extraCommands = ''
            mkdir -p tmp/nginx_client_body var/log/nginx
          '';

          config = {
            Cmd = [ "nginx" "-c" nginxConf ];
            ExposedPorts = { "${nginxPort}/tcp" = { }; };
          };
        };
      }
    );
}
