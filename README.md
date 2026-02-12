# [kodi-rdp-container][project]

Kodi container with display output via RDP ([xrdp][xrdp]).


## Configuration


### Environment variables


#### PASSWORD_HASH

Execute this command to generate your password hash:

```shell
docker run \
    --entrypoint /bin/sh \
    --name kodi-rdp \
    --pull always \
    --rm \
    nedix/kodi-rdp \
    -c 'echo "Your SuperSecret Password123!!!" | mkpasswd -P0'
```


## Usage


### 1. Start the container

```shell
docker run \
    --name kodi-rdp \
    --pull always \
    --rm \
    -e PASSWORD_HASH="^&*()_+" \
    -p 127.0.0.1:3389:3389 \
    nedix/kodi-rdp
```


### 2. Connect via Remote Desktop Protocol

The default username is `kodi`.

[project]: https://hub.docker.com/r/nedix/kodi-rdp
[xrdp]: https://github.com/neutrinolabs/xrdp
