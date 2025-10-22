# Portainer

[**Portainer**](https://docs.portainer.io/) - это универсальная платформа для управления контейнерами.

## Запуск контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

Значимые переменные среды:

- `PORTAINER_AGENT_PORT`    - порт хоста для связи с агентом.

- `PORTAINER_HTTPS_PORT`    - порт хоста для связи с приложением по HTTPS протоколу.
- `PORTAINER_HTTP_PORT`     - порт хоста для связи с приложением по HTTP протоколу.
- `PORTAINER_KUBERNET_PORT` - порт хоста для интеграции с **Kubernetes**.
