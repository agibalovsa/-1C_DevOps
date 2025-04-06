# Sonarqube

[**Sonarqube**](https://docs.sonarsource.com/) - платформа с открытым исходным кодом для непрерывного анализа и измерения качества программного кода.

## Создание образа

Аргументы сборки:

- `SONARQUBE_VERSION`     - версия [базового образа](https://hub.docker.com/_/sonarqube/tags?name=community) *sonarqube*.
- `RUSSIAN_PACK`          - версия [плагина русификации](https://github.com/1c-syntax/sonar-l10n-ru) *sonarqube*.
- `BSL_PLUGIN_VERSION`    - плагин, [поддерживающий язык 1С:Предприятие 8](https://github.com/1c-syntax/sonar-bsl-plugin-community) для *sonarqube*.
- `BRANCH_PLUGIN_VERSION` - плагин, [позволяющий работать с ветками для](https://github.com/mc1arke/sonarqube-community-branch-plugin) *sonarqube community edition*.
- `ROOT_CERTS`            - ссылки на внешние публичные сертификаты, для их фиксации в образе.
  Данная переменная используется, для интеграции с внешними сервисами по протоколу HTTPS, например, с Gitlab. Ее указание необходимо в 2 случаях:
  - Внешние сервисы используют сертификаты, выпущенные внутренним PKI, и для их доверия необходимо указать корневые и промежуточные сертификаты.
  - Внешние сервисы используют сертификаты, выпущенными доверенными центрами сертификации, но, по каким-то причинам, эти сертификаты не установлены в базовом образе Linux. Соответственно возникает ошибка доверия при обращении к этим сервисам.

  Сертификаты должны быть доступны по url ссылкам. Ссылки должны быть разделены запятой. Например:
  
  ```ini
  ROOT_CERTS="http://secure.globalsign.com/cacert/gsgccr6alphasslca2023.crt http://secure.globalsign.com/cacert/root-r6.crt""http://secure.globalsign.com/cacert/gsgccr6alphasslca2023.crt http://secure.globalsign.com/cacert/root-r6.crt"
  ```

Для сборки приложения необходимо создать файл переменны среды *.arg* на основе шаблона *.arg.tmpl*.
