# [kodi-rdp-container][project]

Kodi container with display output via RDP ([xrdp][xrdp]).


## Table of contents

- [Configuration](#configuration)
    - [Environment variables](#environment-variables)
    - [Make variables](#make-variables)
- [Usage](#usage)
    - [1. Start the container](#1-start-the-container)
    - [2. Connect via Remote Desktop Protocol](#2-connect-via-remote-desktop-protocol)


## Configuration


### Environment variables

You can configure the container by making use of the following environment variables.
Add them to the `.env` file and use `--env-file=.env` or use the `-e` flag with the `docker run` command.


#### PASSWORD_HASH

Execute this command to generate your password hash:

```shell
docker run \
    --entrypoint /bin/sh \
    --pull always \
    --rm \
    nedix/kodi-rdp \
    -c 'echo "Your Super Secret Password123!!!" | mkpasswd -P0'
```


### Make variables

Please read the Makefile [documentation](/docs/make.md).


## Usage


### 1. Start the container

```shell
docker run \
    --env-file .env \
    --name kodi-rdp \
    --pull always \
    --rm \
    -p 127.0.0.1:3389:3389 \
    nedix/kodi-rdp
```


### 2. Connect via Remote Desktop Protocol

The default username is `kodi`.

[project]: https://hub.docker.com/r/nedix/kodi-rdp
[xrdp]: https://github.com/neutrinolabs/xrdp
