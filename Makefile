setup:
	@docker build . -t kodi --progress=plain

up: rdp_port=3389
up: vnc_port=5900
up: novnc_port=6080
up: xpra_port=10000
up:
	@docker run --rm -it --name kodi \
		--privileged \
		--device /dev/fuse \
		--cap-add SYS_ADMIN \
        -p 127.0.0.1:$(rdp_port):3389 \
        -p 127.0.0.1:$(vnc_port):5900 \
        -p 127.0.0.1:$(novnc_port):6080 \
        -p 127.0.0.1:$(xpra_port):10000 \
        -v ./storage/freerdp/certs:/var/freerdp/certs \
        kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi sh
