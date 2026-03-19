$ComposePath="."

docker compose  -f "${ComposePath}/common-compose.yml" -f "${ComposePath}/docker-compose.yml" -f "${ComposePath}/windows/docker-compose.yml" -f "${ComposePath}/mssql/docker-compose.yml" down