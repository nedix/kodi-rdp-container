setup:
	@docker build . -t kodi --progress=plain

up: vnc_port=5900
up: novnc_port=6080
up:
	@docker run --rm -it --name kodi \
		--privileged \
		--device /dev/fuse \
        -p 127.0.0.1:$(vnc_port):5900 \
        -p 127.0.0.1:$(novnc_port):6080 \
        -p 127.0.0.1:47984-47990:47984-47990/tcp \
        -p 127.0.0.1:48010:48010 \
        -p 127.0.0.1:47998-48000:47998-48000/udp \
        -v ./storage/freerdp/certs:/var/freerdp/certs \
        kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi sh
