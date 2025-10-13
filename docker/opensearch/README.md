# Opensearch

[**Opensearch**](https://docs.opensearch.org/latest/) - это высокопроизводительная поисковая система и аналитическая платформа с открытым исходным кодом. Инструмент позволяет индексировать и анализировать большие объёмы данных в режиме реального времени.

## Создание образа

Образ берется с [**Docker Hub**](https://hub.docker.com/u/opensearchproject):

- opensearchproject/opensearch
- opensearchproject/opensearch-dashboards

## Создание контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

### Значимые переменные среды **Opensearch**

> [!NOTE]
> Значения и правила определения переменных для кластера описаны в документации <https://docs.opensearch.org/latest/tuning-your-cluster/>.

- `OPENSEARCH_NODE_NAME`     - (обязательный) - имя ноды opensearch.
- `OPENSEARCH_TYPE`          - (обязательный для не кластера) - необходимо прописать `single-node`. В случае кластера оставить пустым.
- `OPENSEARCH_INITIAL_ADMIN_PASSWORD` - (обязательный) - начальный пароль администратора.

> [!WARNING]
> Пароль администратора должен соответствовать [правилам безопасности](https://docs.opensearch.org/latest/install-and-configure/install-opensearch/docker/#password-requirements).

- `OPENSEARCH_NODE_ROLE`     - (для кластера) - роль, которую выполняет нода opensearch.
- `OPENSEARCH_CLUSTER_NAME`  - (для кластера) - имя кластера, в которую входит нода opensearch.
- `OPENSEARCH_MANAGER_NODES` - (для кластера) - описывается начальный массив имен нод, из которых должен состоять кластер.
- `OPENSEARCH_SEED_HOSTS`    - (для кластера) - указывается массив IP или доменных имен нод, входящих в кластер.

Порты:

- `OPENSEARCH_API_PORT`      - порт хоста для связи с приложением по HTTP протоколу.
- `OPENSEARCH_PERFMON_PORT`  - порт для сбора информации о производительности

### Значимые переменные среды **Opensearch dashboard**

- `OPENSEARCH_DASHBOARD_HOSTS` - массив IP или доменных имен нод, которые необходимо подключить к dashboard.
- `SERVER_REWRITEBASEPATH`     - (используется совместно с `SERVER_BASEPATH`) - `true`, если используется `SERVER_BASEPATH`.
- `SERVER_BASEPATH`            - дополнительный путь в составе url-адреса сервиса. Например, */dashboard* для *<http://test.ru/dashboard>*.

Порты:

- `OPENSEARCH_DASHBOARD_PORT` - порт хоста для связи с приложением по HTTP протоколу.

### Пример .env файла для режима Opensearch single-node

```yml
OPENSEARCH_TAG="opensearchproject/opensearch:latest"
OPENSEARCH_HOSTNAME="opensearch"
OPENSEARCH_NAME="opensearch"
OPENSEARCH_DASHBOARD_TAG="opensearchproject/opensearch-dashboards:latest"
OPENSEARCH_DASHBOARD_HOSTNAME="opensearch-dashboards"
OPENSEARCH_DASHBOARD_NAME="opensearch-dashboards"
OPENSEARCH_NODE_NAME="opensearch-node"
OPENSEARCH_TYPE="single-node"
OPENSEARCH_INITIAL_ADMIN_PASSWORD="ThzhO3Bvhjt5mTXWR8entRV1IMQp_v"
OPENSEARCH_NODE_ROLE=""
OPENSEARCH_CLUSTER_NAME=""
OPENSEARCH_MANAGER_NODES=""
OPENSEARCH_SEED_HOSTS=""
OPENSEARCH_DASHBOARD_HOSTS='[ "https://opensearch:9200" ]'
OPENSEARCH_LOG_SIZE="100M"
OPENSEARCH_API_PORT="9200"
OPENSEARCH_PERFMON_PORT="9600"
OPENSEARCH_DATA_VOL="opensearch-data"
OPENSEARCH_CONFIG_VOL="opensearch-config"
OPENSEARCH_DASHBOARD_PORT="5601"
```

> [!NOTE]
> Примеры compose файлов для запуска Opensearch в режиме кластера можно посмотреть в [документации](https://docs.opensearch.org/latest/install-and-configure/install-opensearch/docker/).
