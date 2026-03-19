. "../../common_context/build/tools.ps1"

Set-Vars-From-File ".env"

Create-Docker-Volume "${MSSQL_DATA_VOL}" "${MSSQL_DATA_MOUNT_PATH}"
Create-Docker-Volume "${MSSQL_TEMP_VOL}" "${MSSQL_TEMP_MOUNT_PATH}"

docker run --rm `
    -v "${MSSQL_DATA_VOL}:C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL" `
    -it "${MSSQL_TAG}" "mssql=init"