# ssswithnix - Serving a static site with Nginx built with Nix

Some day somebody thought it would be a nice idea to serve some html via nginx.
Playing around with NixOS it was certainly clear it needed to be done with nixpkgs instead of any other way.
Now the question: How to ship that? And software these days around the globe is shipped in containers. Therefore lets built an OCI container with Nix packed with nginx and some file we pass.

## Requirements

You need Nix with Flakes enabled. I won't cover that here, the NixOS Wiki does a great job, at least in this particular case. Jump to https://nixos.wiki/wiki/Flakes and follow the instructions.
Having podman or docker handy makes life a joy, at least when trying to run commands from this README.

## Building the container

    nix build .#container

## Loading it in your OCI images

    podman load < result

## Running the image

    podman run -p 8080:80 ssswithnix:flake

And now the part of trying it out:

    curl localhost:8080 -v  
    *   Trying 127.0.0.1:8080...
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > GET / HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/8.1.1
    > Accept: */*
    > 
    < HTTP/1.1 200 OK
    < Server: nginx/1.24.0
    < Date: Sun, 23 Jul 2023 19:00:00 GMT
    < Content-Type: text/html
    < Content-Length: 79
    < Last-Modified: Sun, 23 Jul 2023 18:48:43 GMT
    < Connection: keep-alive
    < ETag: "64bd760b-4f"
    < Accept-Ranges: bytes
    < 
    <html><body><h1>Hello from NGINX wrapped by Nix from a file</h1></body></html>
    * Connection #0 to host localhost left intact

What a joy, isn't it?
