# Sonarqube

[**Sonarqube**](https://docs.sonarsource.com/) - платформа с открытым исходным кодом для непрерывного анализа и измерения качества программного кода.

## Создание образа

Все переменные перечислены в файле [.arg.tmpl](build/.arg.tmpl)

Аргументы сборки:

- `SONARQUBE_REPO` - имя репозитория оразов **sonarqube** (по-умолчанию *sonarqube*).
- `SONARQUBE_VERSION` - версия [базового образа **sonarqube**](https://hub.docker.com/_/sonarqube/tags?name=community).
- `RUSSIAN_PACK_VERSION` - версия [плагина русификации **sonarqube**](https://github.com/1c-syntax/sonar-l10n-ru).
- `BSL_PLUGIN_VERSION` - версия [плагина поддерживающего язык 1С:Предприятие 8 для **sonarqube**](https://github.com/1c-syntax/sonar-bsl-plugin-community).
- `BRANCH_PLUGIN_VERSION` - версия [плагина, позволяющего работать с ветками для **sonarqube**](https://github.com/mc1arke/sonarqube-community-branch-plugin).
- `ROOT_CERTS` - ссылки на внешние публичные сертификаты, для их фиксации в образе.
  Данная переменная используется, для интеграции с внешними сервисами по протоколу **HTTPS**, например, с **Gitlab**. Ее указание необходимо в 2 случаях:
  - Внешние сервисы используют сертификаты, выпущенные внутренним **PKI**, и для их доверия необходимо указать корневые и промежуточные сертификаты.
  - Внешние сервисы используют сертификаты, выпущенными доверенными центрами сертификации, но, по каким-то причинам, эти сертификаты не установлены в базовом образе **Linux**. Соответственно возникает ошибка доверия при обращении к этим сервисам.

  Сертификаты должны быть доступны по url ссылкам. Ссылки должны быть разделены пробелом. Например:
  
  ```ini
  ROOT_CERTS="http://secure.globalsign.com/cacert/gsgccr6alphasslca2023.crt http://secure.globalsign.com/cacert/root-r6.crt"
  ```

## Создание контейнера

Все переменные перечислены в файле [.env.tmpl](compose/.env.tmpl)

Значимые переменные среды:

- `SONAR_WEB_CONTEXT` - дополнительный путь в составе url-адреса сервиса. Например, */sonarqube* для *<http://test.ru/sonarqube>*.
- `SONAR_HTTP_PORT` - порт хоста для связи с приложением по HTTP протоколу.
