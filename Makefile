setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t kodi .

destroy:
	-@docker rm -fv kodi

up: RDP_PORT := "3389"
up: USERNAME := $(shell grep "^USERNAME=" .env | cut -d= -f2-)
up:
	@docker run --rm -d --name kodi \
		--env-file .env \
		-e USERNAME="$(USERNAME)" \
        -p 127.0.0.1:$(RDP_PORT):3389 \
        -v "./storage/kodi:/home/$(USERNAME)/.kodi" \
        -v ./storage/xrdp/certs:/var/xrdp/certs \
        kodi
	@docker logs -f kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi /bin/sh

test:
	@$(CURDIR)/tests/index.sh
