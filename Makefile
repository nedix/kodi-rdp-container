setup:
	@test -e .env || cp .env.example .env
	@docker build  --progress=plain -f Containerfile -t kodi .

up: SSH_PORT=22
up: RDP_PORT=3389
up:
	@docker run --rm -it --name kodi \
		--env-file .env \
        -p $(SSH_PORT):22 \
        -p $(RDP_PORT):3389 \
        -v ./storage/xrdp/certs:/var/xrdp/certs \
        -v ./storage/kodi:/home/kodi/.kodi \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        kodi

down:
	-@docker stop kodi

shell:
	@docker exec -it kodi sh

profile-xrdp: kcachegrind_port=8080
profile-xrdp:
#	@docker build -f Containerfile --progress=plain --target=xrdp -t kodi-xrdp
#	@docker run --rm -d --entrypoint "/bin/sh" --name kodi-xrdp kodi-xrdp -c "tail -f /dev/null"
#	@docker export kodi-xrdp | tar -xpf- --strip-components=2 -C ./build/xrdp build/xrdp
#	@docker rm -fv kodi-xrdp
	@docker run --rm -p $(kcachegrind_port):8080 -v "${PWD}:/data" -v "${PWD}/build/xrdp:/build/xrdp:ro" --name kcachegrind nedix/kcachegrind
