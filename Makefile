setup:
	@docker build . -t kodi --progress=plain
	@test -e .env || cp .env.example .env

up: rdp_port=3389
up:
	@docker run --rm -it --name kodi \
		--env-file .env \
        -p $(rdp_port):3389 \
        -v ./storage/xrdp/certs:/var/xrdp/certs \
        -v ./storage/kodi:/home/kodi/.kodi \
        kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi sh
