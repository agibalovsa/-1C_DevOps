function Install-Packs
{
    param
    (
        [string]$ArchivePath
    )

    . "/tools/oc_lib.ps1"
    . "/tools/tools.ps1"
    
    Set-Envs
    & $INSTALL_MODE ${ArchivePath}

}

function Install-From-File
{
    param
    (
        [string]$ArchivePath
    )

    begin
    {
        $SystemEventCount = (Get-WinEvent -LogName "System").Count
        $ApplicationEventCount = (Get-WinEvent -LogName "Application").Count

        # Получаем накопленные события
        $NewSystemEventCount = (Get-WinEvent -LogName "System").Count - $SystemEventCount
        if ( $NewSystemEventCount -gt 0 )
        {
            Get-WinEvent -LogName "System" -MaxEvents $NewSystemEventCount -FilterXPath "*[System[Level=2 or Level=3]]" | Format-List
        }
    }

    process
    {
        $Credential  = Get-Credential "${OC_USER}" "${OC_PASSWORD}"

        Install-OC-Msi "${ArchivePath}" "${OC_PATH}" ${OC_MODE_SERVER} ${OC_MODE_WS} ${OC_MODE_CRS} ${OC_MODE_CLIENT} "${OC_USER}" "${OC_PASSWORD}"
        if ( ${OC_MODE_SERVER} -gt 0 ){
            New-Catalog-With-Rules "${OC_SRVINFO}" "${OC_USER}"
            Set-Ragent-Service "${OC_PATH}" "${OC_VERSION}" "${OC_RMNGR_PORT}" "${OC_RAGENT_PORT}" "${OC_RPHOST_PORTS}" "${OC_SRVINFO}" -Credential ${Credential}
            Set-Ras-Service    "${OC_PATH}" "${OC_VERSION}" "${OC_RAS_PORT}" "${OC_RAGENT_PORT}" ${Credential}
            Set-Comcntr        "${OC_PATH}" "${OC_VERSION}"
        }
        if ( ${OC_MODE_WS} -gt 0 ){
            Set-Wsisapi-IIS "${OC_PATH}" "${OC_VERSION}"
        }
        if ( ${OC_MODE_CRS} -gt 0 ){
            New-Catalog-With-Rules "${OC_CRSERVER_PATH}" "${OC_USER}"
            Set-CRS-Service "${OC_PATH}" "${OC_VERSION}" "${OC_CRSERVER_PORT}" "${OC_CRSERVER_PATH}" ${Credential}
        }
    }

    end
    {
        $NewApplicationEventCount = (Get-WinEvent -LogName "Application").Count - ${ApplicationEventCount}
        if ( ${NewApplicationEventCount} -gt 0 )
        {
            Get-WinEvent -LogName "Application" -MaxEvents ${NewApplicationEventCount} -FilterXPath "*[System[Level=2 or Level=3]]" | Format-List
        }
    }

}