# Portainer

[**Portainer**](https://docs.portainer.io/) - это универсальная платформа для управления контейнерами.

## Создание контейнера

Переменные среды:

- `PORTAINER_HTTPS_PORT` - порт хоста для указания HTTPS порта приложения.
- `PORTAINER_HTTP_PORT` - порт хоста для указания HTTP порта приложения.
- `PORTAINER_KUBERNET_PORT` - порт хоста для указания порта приложения интеграции с **Kubernetes**.

> **Важно**. Запуск осуществляется только с помощью **docker swarm** на узле где активирован менеджер swarm, для этого используется файл скрипта *docker-stack-deploy.sh*.
