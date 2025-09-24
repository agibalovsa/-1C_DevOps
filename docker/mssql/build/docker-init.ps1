
$MSSQL_TAG=
$DATA_PATH=

docker run `
    -v "${DATA_PATH}:C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL" `
    -it $MSSQL_TAG "init"