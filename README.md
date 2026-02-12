# [kodi-rdp-container][project]

Kodi container with display output via RDP ([xrdp][xrdp]).


## Usage


### 1. Start the container

```shell
docker run --rm --pull always --name kodi-rdp \
    -p 127.0.0.1:3389:3389 \
    -e PASSWORD_HASH=$(printf "Your SuperSecret Password123!!!" | mkpasswd -P0) \
    nedix/kodi-rdp
```


### 2. Connect via Remote Desktop Protocol

The default username is `kodi`.

[project]: https://hub.docker.com/r/nedix/kodi-rdp
[xrdp]: https://github.com/neutrinolabs/xrdp
