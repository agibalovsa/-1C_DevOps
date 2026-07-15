# Docker-registry

- [**Docker-registry**](https://distribution.github.io/distribution/) - это централизованная система для хранения и распространения образов контейнеров Docker.

## Создание контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

Значимые переменные среды:

- `DOCKER_REGISTRY_PORT` - порт хоста для связи с HTTP портом приложения.
- `REGISTRY_HTTP_SECRET` - ключ для безопасного шифрования и подписи состояния загрузок (HTTP chunked uploads).
- `OTEL_TRACES_EXPORTER` - глобальный стандартный параметр [OpenTelemetry (OTel)](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/), который указывает приложению, куда именно нужно отправлять собранные данные трассировки (traces). Значение "none" отключает телеметрию.
