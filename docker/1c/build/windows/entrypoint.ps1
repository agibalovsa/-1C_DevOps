# common

function Set-Init
{
    begin
    {
        if ( Test-Path "logcfg.xml" )
        {
            Move-Item "logcfg.xml" "${OC_PATH}/conf/logcfg.xml";
        }

        if ( Test-Path "config_ibsrv.yml" )
        {
            $DirPath = Split-Path -Path "${OC_IBSRV_CONFIG_PATH}"
            New-Item -ItemType "Directory" -Path "${DirPath}" -Force
            Move-Item "config_ibsrv.yml" "${OC_IBSRV_CONFIG_PATH}"
        }

        if ( Test-Path "init.ps1" )
        {
            & ./init.ps1;
            Remove-Item ./init.ps1;
        }
    }
}

function Set-IIS-Catalog
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [string]$IISPath="${IIS_DEF_PATH}"
    )

    begin
    {
        if( ! (Test-Path -Path "${IISPath}_temp") )
        {
            return
        }
        if( ! (Test-Path -Path "${IISPath}\*") )
        {
            New-Item -ItemType "Directory" -Path "${IISPath}" -Force
            Get-ChildItem "${IISPath}_temp\" |
            Foreach-Object {
                $FullName = $_.FullName.Replace("_temp", "")
                Copy-Item $_.FullName $FullName -Recurse
            }

            Get-ChildItem "${IISPath}_temp\" -Recurse |
            Foreach-Object {
                $FullName = $_.FullName.Replace("_temp", "")
                $acl = Get-Acl $_.FullName;
                Set-Acl $FullName -AclObject $acl;
            }
        }
    }
}

function Set-OC-Catalog
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [string]$SrvinfoPath="${OC_SRVINFO}",
        [string]$CRSPath="${OC_CRSERVER_PATH}",
        [string]$LogPath="${OC_LOG_PATH}"
    )

    begin
    {
        if( ! (Test-Path -Path "${OCPath}\conf\*") )
        {
            if( ! (Test-Path -Path "${OCPath}\conf") )
            {
                New-Item -ItemType "Directory" -Path "${OCPath}\conf" -Force
            }
            Get-ChildItem "${OCPath}\conf_temp\" |
            Foreach-Object {
                $FullName = $_.FullName.Replace("\conf_temp\", "\conf\")
                Copy-Item $_.FullName $FullName -Recurse
            }
            Get-ChildItem "${OCPath}\conf_temp\" -Recurse |
            Foreach-Object {
                $FullName = $_.FullName.Replace("\conf_temp\", "\conf\")
                $acl = Get-Acl $_.FullName;
                Set-Acl $FullName -AclObject $acl;
            }
        }

        if(Test-Path -Path "${OCPath}\conf_temp")
        {
            Remove-Item "${OCPath}\conf_temp\" -Recurse
        }

        # Задание ACL для файлов 1С
        $ACL = Get-Acl "${OC_DEF_SRVINFO}_temp\1cv8wsrv.lst"
        if ( Test-Path "${SrvinfoPath}" )
        {
            Get-ChildItem "${SrvinfoPath}" -r | Set-Acl -AclObject ${ACL}
        }
        if ( Test-Path "${CRSPath}" )
        {
            Get-ChildItem "${CRSPath}" -r | Set-Acl -AclObject ${ACL}
        }
        if ( Test-Path "${LogPath}" )
        {
            Get-ChildItem "${LogPath}" -r | Set-Acl -AclObject ${ACL}
        }
    }
}

# server

function Set-Ragent-Healthcheck
{
    begin
    {
        if ( ! (Test-Path "./healthcheck.sh") )
        {  
            $healthcheck = "(rac cluster list localhost:${OC_RAS_PORT})"
            if (Test-Path -Path "${OC_PATH}\${OC_VERSION}\bin\wsisapi.dll")
            { 
                $healthcheck += " && (curl http://localhost/)"
            }
            
            Write-Output "$healthcheck" > ./healthcheck.ps1
        }
    }
}

function Start-OC-Server
{
    begin
    {
        Set-Ragent-Healthcheck
        Set-Ras-Service "${OC_PATH}" "${OC_VERSION}" "${OC_RAS_PORT}" "${OC_RAGENT_PORT}"
        Start-Ras-Service
        Set-Ragent-Service `
            "${OC_PATH}" `
            "${OC_VERSION}" `
            "${OC_RAGENT_PORT}" `
            "${OC_RMNGR_PORT}" `
            "${OC_RPHOST_PORTS}" `
            "${OC_SRVINFO}" `
            "${OC_SECLEVEL}" `
            "${OC_PING_PERIOD}" `
            "${OC_PING_TIMEOUT}" `
            "${OC_DEBUG_TYPE}" `
            "${OC_DEBUG_PORT}" `
            "${OC_DEBUG_ADDR}" `
            "${OC_DEBUG_PWD}" `
            $script:Credential
        Start-Ragent-Service
    }
}

# ibsrv

function Set-Ibsrv-Healthcheck
{
    begin
    {
        if ( ! (Test-Path "./healthcheck.sh") )
        {
            Write-Output "curl http://localhost:${OC_IBSRV_HTTP_PORT}${OC_IBSRV_HTTP_PATH}" > ./healthcheck.ps1
        }
    }
}

function Start-Ibsrv-Server
{
    begin
    {
        Set-Ibsrv-Healthcheck
        Set-Ibsrv-Config "${OC_PATH}" "${OC_VERSION}" "${OC_IBSRV_CONFIG_PATH}"
        Set-Ibsrv-Service "${OC_PATH}" "${OC_VERSION}" -Credential $script:Credential
        Start-Ibsrv-Service
    }
}

# crserver

function Set-CRS-Healthcheck
{
    begin
    {
        if ( ! (Test-Path "./healthcheck.sh") )
        {
            Write-Output "curl http://${OC_CRSERVER_HOSTNAME}/${OC_CRSERVER_LOCATION}" > ./healthcheck.ps1
        }
    }
}

function Start-CRS-Server
{
    begin
    {
        Set-CRS-Healthcheck
        Set-CRS-IIS
        Set-CRS-Service "${OC_PATH}" "${OC_VERSION}" -Credential $script:Credential
        Start-CRS-Service
    }
}

. "/build_context/oc_lib.ps1"
Set-Envs
$PasswordSec = ConvertTo-SecureString ${OC_PASSWORD} -AsPlainText -Force
$script:Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ".\${OC_USER}", ${PasswordSec}
Set-Init
Set-IIS-Catalog
Set-OC-Catalog
Set-OC-IIS "${OC_PATH}" "${OC_VERSION}"
if ( $args[0] -eq "server" )
{
    Start-OC-Server
}
elseif ( $args[0] -eq "ibsrv" )
{
    Start-Ibsrv-Server
}
elseif ( $args[0] -eq "crserver" )
{
    Start-CRS-Server
}
else
{
    Write-Error "Wrong parametr: $($args[0])"
    exit 1
}

exit 0