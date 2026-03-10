
param (
    [Parameter(Mandatory)][string]$VolumeName,
    [string]$MountPoint
)

. "../../common_context/build/tools.ps1"

Set-Vars-From-File ".arg"
Create-Docker-Volume "${VolumeName}" "${MountPoint}"

docker run --rm `
    -v "${VolumeName}:C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL" `
    -it "${MSSQL_TAG}" "mssql=init"