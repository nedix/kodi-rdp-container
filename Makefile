setup:
	@docker build --progress=plain -f Containerfile -t kodi .
	@test -e .env || cp .env.example .env

destroy:
	-@docker rm -fv kodi

up: FORWARD_RDP_PORT := $(shell grep "^FORWARD_RDP_PORT=" .env | cut -d= -f2-)
up: USERNAME := $(shell grep "^USERNAME=" .env | cut -d= -f2-)
up:
	@docker run \
		--env-file .env \
		--name kodi \
		--rm \
        -p 127.0.0.1:$(FORWARD_RDP_PORT):3389 \
        -v "./storage/kodi:/home/$(USERNAME)/.kodi" \
        -v ./storage/xrdp/certs:/var/xrdp/certs \
		-d \
        kodi
	@docker logs -f kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi /bin/sh

test:
	@$(CURDIR)/tests/index.sh
