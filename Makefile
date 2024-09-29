setup:
	@docker build . -t kodi --progress=plain

up: rdp_port=3389
up:
	@docker run --rm -it --name kodi \
        -p 127.0.0.1:$(rdp_port):3389 \
        -v ./storage/xrdp/certs:/var/xrdp/certs \
        kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi sh
