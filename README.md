# [kodi-rdp-container][project]

```shell
make setup
make up
make shell
PASSWORD_HASH="$(printf "Your SuperSecret Password123!!!" | mkpasswd -P0)"
sed '/^PASSWORD_HASH=$/d' -i .env && printf 'PASSWORD_HASH=%s\n' "$PASSWORD_HASH" >> .env
```

[project]: https://hub.docker.com/r/nedix/kodi-rdp
