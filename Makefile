setup:
	@docker build --progress=plain -f Containerfile -t kodi-rdp .
	@test -e .env || cp .env.example .env

destroy:
	-@docker rm -fv kodi-rdp

up: RDP_PORT = "3389"
up:
	@docker run \
		--env-file .env \
		--name kodi-rdp \
		--rm \
        -p 127.0.0.1:$(RDP_PORT):3389 \
        -v ./storage/kodi/:/var/kodi-rdp/.kodi/ \
        -v ./storage/xrdp/certs/:/var/xrdp/certs/ \
		-d \
        kodi-rdp
	@docker logs -f kodi-rdp

down:
	-@docker stop kodi-rdp

shell:
	@docker exec -it kodi-rdp /bin/sh

test:
	@$(CURDIR)/tests/index.sh
