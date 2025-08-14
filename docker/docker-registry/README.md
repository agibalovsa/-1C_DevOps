# Docker-registry

- [**Docker-registry**](https://distribution.github.io/distribution/) - это централизованная система для хранения и распространения образов контейнеров Docker.

## Создание контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

Значимые переменные среды:

- `DOCKER_REGISTRY_PORT` - порт хоста для связи с HTTP портом приложения.
