function Install-Packs
{
    param
    (
        [string]$DistrPath
    )

    . "${PSScriptRoot}/oc_lib.ps1"
    
    Set-Envs
    & $INSTALL_MODE ${DistrPath}

}

function Install-From-File
{
    param
    (
        [string]$DistrPath
    )

    begin
    {
        $SystemEvntCount = (Get-WinEvent -LogName "System").Count
        $ApplicationEvntCount = (Get-WinEvent -LogName "Application").Count

        # Получаем накопленные события
        $NewSystemEvntCount = (Get-WinEvent -LogName "System").Count - $SystemEvntCount
        if ( $NewSystemEvntCount -gt 0 )
        {
            Get-WinEvent -LogName "System" -MaxEvents $NewSystemEvntCount -FilterXPath "*[System[Level=2 or Level=3]]"
        }
    }

    process
    {
        $PasswordSec = ConvertTo-SecureString ${OC_PASSWORD} -AsPlainText -Force

        Install-OC-Msi "${DistrPath}" "${OC_PATH}" ${OC_MODE_SERVER} ${OC_MODE_WS} ${OC_MODE_CRS} ${OC_MODE_CLIENT} "${OC_USER}" "${OC_PASSWORD}"
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ".\${OC_USER}", ${PasswordSec}
        if ( ${OC_MODE_SERVER} -gt 0 ){
            New-Catalog-With-Rules "${OC_SRVINFO}" "${OC_USER}"
            Set-Ragent-Service  "${OC_PATH}" "${OC_VERSION}" "${OC_RMNGR_PORT}" "${OC_RAGENT_PORT}" "${OC_RPHOST_PORTS}" "${OC_SRVINFO}" -Credential ${Credential}
            Set-Ras-Service "${OC_PATH}" "${OC_VERSION}" "${OC_RAS_PORT}" "${OC_RAGENT_PORT}" ${Credential}
            Set-Comcntr    "${OC_PATH}" "${OC_VERSION}"
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
        $NewApplicationEvntCount = (Get-WinEvent -LogName "Application").Count - ${ApplicationEvntCount}
        if ( ${NewApplicationEvntCount} -gt 0 )
        {
            Get-WinEvent -LogName "Application" -MaxEvents ${NewApplicationEvntCount} -FilterXPath "*[System[Level=2 or Level=3]]"
        }
    }

}