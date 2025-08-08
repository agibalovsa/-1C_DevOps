# Portainer

[**Portainer**](https://docs.portainer.io/) - это универсальная платформа для управления контейнерами.

## Создание контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

Значимые переменные среды:

- `PORTAINER_HTTPS_PORT`    - порт хоста для указания HTTPS порта приложения.
- `PORTAINER_HTTP_PORT`     - порт хоста для указания HTTP порта приложения.
- `PORTAINER_KUBERNET_PORT` - порт хоста для указания порта приложения интеграции с **Kubernetes**.
