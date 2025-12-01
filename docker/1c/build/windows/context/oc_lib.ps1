# Install

function Set-Envs
{
    begin
    {
        New-Variable-With-Test -Name "IIS_DEF_PATH"    -Value "C:\inetpub\wwwroot"                  -Scope "Script"
        New-Variable-With-Test -Name "OC_DEF_USER"     -Value "USER1CV8"                        -Scope "Script"
        New-Variable-With-Test -Name "OC_DEF_PASSWORD" -Value "_USER_1C_V8"                     -Scope "Script"
        New-Variable-With-Test -Name "OC_DEF_SRVINFO"  -Value "C:\Program Files\1cv8\srvinfo"   -Scope "Script"

        New-Variable-With-Test -Name "OC_VERSION"      -Value ""                                -Scope "Script"
        New-Variable-With-Test -Name "OC_USER"         -Value "${OC_DEF_USER}"                  -Scope "Script"
        New-Variable-With-Test -Name "OC_PASSWORD"     -Value "${OC_DEF_PASSWORD}"              -Scope "Script"
        New-Variable-With-Test -Name "OC_RAGENT_PORT"  -Value "1540"                            -Scope "Script"
        New-Variable-With-Test -Name "OC_RMNGR_PORT"   -Value "1541"                            -Scope "Script"
        New-Variable-With-Test -Name "OC_RPHOST_PORTS" -Value "1560:1591"                       -Scope "Script"
        New-Variable-With-Test -Name "OC_RAS_PORT"     -Value "1545"                            -Scope "Script"
        New-Variable-With-Test -Name "OC_PATH"         -Value "C:\Program Files\1cv8"           -Scope "Script"
        New-Variable-With-Test -Name "OC_SRVINFO"      -Value "${OC_DEF_SRVINFO}"               -Scope "Script"
        New-Variable-With-Test -Name "OC_LOG_PATH"     -Value "C:\Program Files\1cv8\logs"      -Scope "Script"
        New-Variable-With-Test -Name "OC_LICENSE_PATH" -Value "C:\ProgramData\1C\licenses"      -Scope "Script"

        New-Variable-With-Test -Name "OC_DEBUG_TYPE"   -Value ""                                -Scope "Script"
        New-Variable-With-Test -Name "OC_DEBUG_PORT"   -Value "1549"                            -Scope "Script"
        New-Variable-With-Test -Name "OC_SECLEVEL"     -Value "0"                               -Scope "Script"
        New-Variable-With-Test -Name "OC_PING_PERIOD"  -Value "1000"                            -Scope "Script"
        New-Variable-With-Test -Name "OC_PING_TIMEOUT" -Value "5000"                            -Scope "Script"

        New-Variable-With-Test -Name "OC_IBSRV_PORT"           -Value "1541"                                -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_RANGE_PORT"     -Value "1560:1591"                           -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_SECLEVEL"       -Value "0"                                   -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_HTTP_ADDRESS"   -Value "any"                                 -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_HTTP_PORT"      -Value "8314"                                -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_HTTP_PATH"      -Value "/ibsrv"                              -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_BASE_NAME"      -Value "ibsrv"                               -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_CONFIG_PATH"    -Value "C:\Program Files\1cv8\conf\config_ibsrv.yml"       -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_FILE_BASE_PATH" -Value "C:\Program Files\1cv8\ibsrv\${OC_IBSRV_BASE_NAME}" -Scope "Script"

        # MSSQLServer|PostrgeSQL|IBMDB2|OracleDatabase
        New-Variable-With-Test -Name "OC_IBSRV_DBMS_KIND"      -Value ""                                    -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DBMS_ADRESS"    -Value "localhost"                           -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DBMS_NAME"      -Value "ibsrv"                               -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DBMS_LOGIN"     -Value "ibsrv"                               -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DBMS_PASSWORD"  -Value "ibsrv"                               -Scope "Script"

        # tcp|http|server
        New-Variable-With-Test -Name "OC_IBSRV_DEBUG_TYPE"     -Value "http"                                -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DEBUG_ADDRESS"  -Value "any"                                 -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DEBUG_PORT"     -Value "1550"                                -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DEBUG_PASSWORD" -Value ""                                    -Scope "Script"
        New-Variable-With-Test -Name "OC_IBSRV_DEBUG_URL"      -Value ""                                    -Scope "Script"

        New-Variable-With-Test -Name "OC_LOCATION"             -Value "1c"                                  -Scope "Script"

        New-Variable-With-Test -Name "OC_CRSERVER_PATH"        -Value "C:\Program Files\1cv8\storage"       -Scope "Script"
        New-Variable-With-Test -Name "OC_CRSERVER_HOSTNAME"    -Value "localhost"                           -Scope "Script"
        New-Variable-With-Test -Name "OC_CRSERVER_LOCATION"    -Value "1c\repository\repository.1ccr"       -Scope "Script"
        New-Variable-With-Test -Name "OC_CRSERVER_PORT"        -Value "1542"                                -Scope "Script"

    }
}

function Start-Exec
{
    param
    (
        [array]$Exec
    )

    begin
    {
        Write-Host "${Exec}"
        & $Exec[0].Trim("""") $Exec[1..($Exec.count-1)] 2>&1
    }
}

function  New-Variable-With-Test
{
    param
    (
        [string]$Name,
        [string]$Value,
        [string]$Scope
    )

    process
    {
        if ( ( ! (Test-Path Variable:$Name) ) -or  ( ! ( Get-Variable -Name $Name -ValueOnly ) ) )
        {
            
            New-Variable -Name "${Name}" -Value ( ((${Name}) -and (Test-Path Env:${Name})) ? (Get-Item -Path env:\${Name}).Value : "${Value}" ) -Scope "${Scope}"
        }
    }

}

function New-Catalog-With-Rules
{
    param
    (
        [string]$CatalogPath,
        [string]$User="${OC_USER}"
    )

    process
    {
        if ( ! (Test-Path -Path "${CatalogPath}" ) ) {
            New-Item -ItemType "Directory" -Path "${CatalogPath}" -Force
        }

        Set-Icacls-Rules "${CatalogPath}" "${User}"
    }
}

function Set-Icacls-Rules
{
    param
    (
        [string]$CatalogPath,
        [string]$User="${OC_USER}"
    )

    process
    {
        icacls.exe "${CatalogPath}" /grant:r ${User}:F /t /c /q
        icacls.exe "${CatalogPath}" /grant:r BUILTIN\Administrators:F /t /c /q
    }
}

function Set-OC-Service
{
    param
    (
        [Parameter(Mandatory)][string]$ServiceName,
        [Parameter(Mandatory)][string]$OCExec,
        [System.Management.Automation.PSCredential]$Credential
    )

    process
    {
        # Изменение службы сервера администрирования кластера серверов 1С
        Write-Host "Setting ${ServiceName}"

        if ( ! ( Test-Path "HKLM:\System\CurrentControlSet\Services\${ServiceName}" ) )
        {
            New-Service -Name "${ServiceName}" `
                -BinaryPathName "${OCExec}" `
                -DisplayName "${ServiceName}" `
                -Description "${ServiceName}"
        }
        else
        {
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\${ServiceName}" -Name ImagePath -Value "${OCExec}"
        }

        Set-Service   -Name "${ServiceName}" -Credential $Credential -StartupType "Manual"
        Start-Service -Name "${ServiceName}"
        Stop-Service  -Name "${ServiceName}"
    }
}

function Start-OC-Service
{
    param
    (
        [Parameter(Mandatory)][string]$ServiceName
    )
    process
    {
        Set-Service -Name "${ServiceName}" -StartupType "Automatic"
        # Если после остановки сервиса сразу его запустить, возникает ошибка, поэтому ждем 5 секунд
        Start-Sleep -Seconds 5
        Start-Service "${ServiceName}"
    }
}

function New-OCUsers
{
    param
    (
        [string]$User,
        [System.Security.SecureString]$PasswordSec
    )

    process
    {
        $UserStatus = Get-LocalUser | Where-Object Name -eq "${User}" | Measure-Object
        if ( ${UserStatus}.count -eq 0 )
        {
            # Создание локального пользователя 1С
            New-LocalUser -Name "${User}" -Password $PasswordSec -Description "Account for 1C:Enterprise 8 Server" -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword

            # Добавление пользователя в локальную политику безопасности "Вход в качестве службы" и выдача прав на доступ к папкам
            $tmp = New-TemporaryFile
            secedit /export /cfg "${tmp}.inf" | Out-Null
            (Get-Content -Encoding ascii "${tmp}.inf")`
                -replace '^SeServiceLogonRight .+', "`$0,${User}"`
                -replace '^SeBatchLogonRight .+', "`$0,${User}"`
                -replace '^SeDenyInteractiveLogonRight .+', "`$0,${User}"`
                -replace '^SeDenyNetworkLogonRight .+', "`$0,${User}"`
                | Set-Content -Encoding ascii "${tmp}.inf"
            secedit /import /cfg "${tmp}.inf" /db "${tmp}.sdb" | Out-Null
            secedit /configure /db "${tmp}.sdb" /cfg "${tmp}.inf" | Out-Null
            Remove-Item $tmp* -ea 0
        }
    }
}

function Install-OC-Msi
{
    param(
        [Parameter(Mandatory)][string]$DistrPath,
        [string]$OCPath="${OC_PATH}",
        [int]$Server=0,
        [int]$WS=0,
        [int]$CRS=0,
        [int]$Client=0,
        [string]$User="${OC_DEF_USER}",
        [string]$Password="${OC_DEF_PASSWORD}"
    )

    process
    {
        $PasswordSec = ConvertTo-SecureString "${Password}" -AsPlainText -Force
        
        if ( ! ( "${User}" -eq "${OC_DEF_USER}") -or ! ( $Server -gt 1 ) )
        {
            New-OCUsers "${User}" ${PasswordSec}
        }

        Write-Host "Install 1C begining"

        $InstallPath="C:\temp\install"
        $InatallMsiPath="${InstallPath}\1CEnterprise 8 (x86-64).msi"
        New-Catalog-With-Rules "${InstallPath}"
        New-Item -ItemType "Directory" -Path "${InstallPath}" -Force

        Expand-Archive "${DistrPath}" -DestinationPath "${InstallPath}" -Force

        $SetupContent    = Get-Ini-Content "${InstallPath}\Setup.ini"
        $PackageName     = $SetupContent["Startup"]["PackageName"]
        $Version         = $SetupContent["Startup"]["ProductVersion"]

        $InatallMsiPath  = "${InstallPath}\${PackageName}"
        if ( !(Test-Path "${InatallMsiPath}") )
        {
            Write-Error -Message "File not found: ${InatallMsiPath}" -ErrorAction 'Stop'
        }

        $ArgumentList = @(
            "/l*"
            '"' + "${InstallPath}" + '\Msi_Install.log"'
            "/i"
            '"' + "${InatallMsiPath}" + '"'
            "/qn"
            'TRANSFORMS="adminstallrelogon.mst;1049.mst"'
            "DESIGNERALLCLIENTS=1"                                           # Конфигуратор и все виды клиентов
            "THICKCLIENT=$( ${Client} -gt 0 ? 1 : 0 )"                       # Толстый клиент
            "THINCLIENTFILE=$( ${Client} -gt 0 ? 1 : 0 )"                    # Тонкий клиент, файловый вариант
            "THINCLIENT=$( ${Client} -gt 0 ? 1 : 0 )"                        # Тонкий клиент
            "SERVER=$( ${Server} -gt 0 ? 1 : 0 )"                            # Сервер 1С:Предприятие
            "WEBSERVEREXT=$( ${WS} -gt 0 ? 1 : 0 )"                          # Модули расширения веб-сервера
            "SERVERCLIENT=$( ${Server} -gt 0 ? 1 : 0 )"                      # Администрирование сервера 1С:Предприятие
            "LANGUAGES=RU"                                                   # Интерфейсы на различных языках
            "CONFREPOSSERVER=$( ${CRS} -gt 0 ? 1 : 0 )"                      # Сервер хранилища конфигураций 1С:Предприятие
            "ADMINISTRATIONFUNC=$( ${Server} -gt 0 ? 1 : 0 )"                # Дополнительные функции администрирования
            "CONVERTER77=0"                                                  # Конвертор ИБ 1С:Предприятия 7.7
            "INSTALLSRVRASSRVC=$( ${Server} -gt 1 ? 1 : 0 )"                 # Установить сервер 1С:Предприятие как службу Windows
            "SRVCUSERSELECTMODE=$( ${Server} -gt 1 ? ( "${User}" -eq "${OC_DEF_USER}" ? "new" : "existing") : '`"`"' )" # new(Создать пользователя USER1CV8)|existing(Существующий пользователь)
            "USER1CV82SERVER=$( ${Server} -gt 1 ? "${User}" : '`"`"' )"          # Имя пользователя
            "PASSWORD1CV82SERVER=$( ${Server} -gt 1 ? "${Password}" : '`"`"' )"  # Пароль пользователя
            'INSTALLDIR="' + "${InstallDir}" + '"'                           # Папка
        )

        Start-Process -FilePath "msiexec.exe" -ArgumentList ${ArgumentList} -Wait -NoNewWindow

        if ( ! ( "${User}" -eq "${OC_DEF_USER}" ) )
        {
            Set-Icacls-Rules "${OC_LICENSE_PATH}" "${User}"
        }
        New-Catalog-With-Rules "${OC_LOG_PATH}" "${User}"

        if ( Test-Path "${InstallPath}\Msi_Install.log")
        {
            Get-Content "${InstallPath}\Msi_Install.log" | ForEach-Object {Write-Host $_}
        }

        Remove-Item -r "${InstallPath}"

        # Редактирование переменной среды PATH
        $Include = "${OCPath}\${Version}\bin\"
        $OldPath = [System.Environment]::GetEnvironmentVariable('PATH','machine')
        $NewPath = "${OldPath};${Include}"
        [Environment]::SetEnvironmentVariable("PATH", "${NewPath}", "Machine")  

        Write-Host "Install 1C finished"

        New-Variable-With-Test -Name "OC_VERSION" -Value "${Version}" -Scope "Script"
    }
}

# Ras

function Get-Ras-Service-Name
{
    begin
    {
        return "1C:Enterprise 8.3 Remote Server"
    }
}

function Get-Ras-Exec
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$RasPort="${OC_RAS_PORT}",
        [string]$RagentPort="${OC_RAGENT_PORT}"
    )

    begin
    {
        $RasExec="""${OCPath}\${Version}\bin\ras.exe""", "cluster", "--service", "--port $RasPort", "localhost:$RagentPort"
        
        return "$RasExec"
    }
}

function Set-Ras-Service
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$RasPort="${OC_RAS_PORT}",
        [string]$RagentPort="${OC_RAGENT_PORT}",
        [System.Management.Automation.PSCredential]$Credential
    )

    begin
    {
        # Изменение службы сервера администрирования кластера серверов 1С
        Write-Host "Setting 1C-Ras Server"

        $ServiceName = Get-Ras-Service-Name
        $RasExec     = Get-Ras-Exec "${OCPath}" "${Version}" "${RasPort}" "${RagentPort}"

        Set-OC-Service "${ServiceName}" "${RasExec}" $Credential
    }
}

function Start-Ras-Service
{
    begin
    {
        $ServiceName = Get-Ras-Service-Name
        Start-OC-Service "${ServiceName}"
    }
}

# Ragent

function Get-Ragent-Service-Name
{
    begin
    {
        return "1C:Enterprise 8.3 Server Agent (x86-64)"
    }
}

function Get-Ragent-Exec
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [bool]$Service=$true,
        [string]$RagentPort="${OC_RAGENT_PORT}",
        [string]$RmngrPort="${OC_RMNGR_PORT}",
        [string]$RphostPorts="${OC_RPHOST_PORTS}",
        [string]$SrvInfoPath="${OC_SRVINFO}",
        [string]$SecLevel="${OC_SECLEVEL}",
        [string]$PingPeriod="${OC_PING_PERIOD}",
        [string]$PingTimeout="${OC_PING_TIMEOUT}",
        [ValidateSet("", "-tcp","-http")][string]$DebugType="${OC_DEBUG_TYPE}",
        [string]$DebugServerPort="${OC_DEBUG_PORT}",
        [string]$DebugServerAddres="",
        [string]$DebugServerUsers,
        [string]$DebugServerPwd=""
    )

    begin
    {
        $RagentExec = @( """${OCPath}\${Version}\bin\ragent.exe""" )
        if( $Service ) { $RagentExec+="-srvc -agent" }
        $RagentExec+=@( "-port ${RagentPort}", "-regport ${RmngrPort}", "-range ${RphostPorts}", "-d ""${SrvInfoPath}""" )
        $RagentExec+=@( "-seclev ${SecLevel}", "-pingPeriod ${PingPeriod}", "-pingTimeout ${PingTimeout}" )
        if( $DebugType ) { $RagentExec+=@( "-debug ${DebugType}", "-debugServerPort ${DebugServerPort}" ) }
        if( ($DebugType) -and ($DebugServerAddres) ) { $RagentExec+="-debugServerAddr ${DebugServerAddres}" }
        if( ($DebugType) -and ($DebugServerUsers) )  { $RagentExec+="-debugServerUsers ${DebugServerUsers}" }
        if( ($DebugType) -and ($DebugServerPwd) )    { $RagentExec+="-debugServerPwd ${DebugServerPwd}" }

        return $RagentExec
    }
}

function Start-Ragent-Exec
{
    param
    (
        [string]$RagentExec
    )

    begin
    {
        Write-Host "Begining Ragent"
        Start-Exec ${RagentExec} 
    }
}

function Set-Ragent-Service
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$RagentPort="${OC_RAGENT_PORT}",
        [string]$RmngrPort="${OC_RMNGR_PORT}",
        [string]$RphostPorts="${OC_RPHOST_PORTS}",
        [string]$SrvInfoPath="${OC_SRVINFO}",
        [string]$SecLevel="${OC_SECLEVEL}",
        [string]$PingPeriod="${OC_PING_PERIOD}",
        [string]$PingTimeout="${OC_PING_TIMEOUT}",
        [ValidateSet("", "-tcp","-http")][string]$DebugType="${OC_DEBUG_TYPE}",
        [string]$DebugPort="${OC_DEBUG_PORT}",
        [string]$DebugServerAddres="",
        [string]$DebugServerPwd="",
        [System.Management.Automation.PSCredential]$Credential
    )

    begin
    {
        Write-Host "Creating 1C Server"

        $ServiceName = Get-Ragent-Service-Name
        $RagentExec  = Get-Ragent-Exec `
            "${OCPath}" `
            "${Version}" `
            $true `
            "${RagentPort}" `
            "${RmngrPort}" `
            "${RphostPorts}" `
            "${SrvInfoPath}" `
            "${SecLevel}" `
            "${PingPeriod}" `
            "${PingTimeout}" `
            "${DebugType}" `
            "${DebugPort}" `
            "${DebugServerAddres}" `
            "${DebugServerPwd}"

        Set-OC-Service "${ServiceName}" "${RagentExec}" $Credential

        # Установка параметров службы "Действие при первом сбое"(перезапуск службы через 3 мин.)
        sc failure "${ServiceName}" reset= 0 actions= restart/180000/noaction/noaction
    }
}

function Start-Ragent-Service
{
    begin
    {
        $ServiceName = Get-Ragent-Service-Name
        Start-OC-Service "${ServiceName}"
    }
}

# Ibsrv

function Get-Ibsrv-Service-Name
{
    begin
    {
        return "1C:Enterprise 8.3 Server Ibsrv"
    }
}

function Get-Ibsrv-Exec
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [bool]$Service=$true,
        [string]$IbsrvPort="${OC_IBSRV_PORT}",
        [string]$IbsrvRangePorts="${OC_IBSRV_RANGE_PORT}",
        [string]$IbsrvConfigPath="${OC_IBSRV_CONFIG_PATH}",
        [string]$IbsrvSecLevel="${OC_IBSRV_SECLEVEL}",
        [ValidateSet("","tcp","http","server")][string]$IbsrvDebugType="${OC_IBSRV_DEBUG_TYPE}",
        [string]$IbsrvDebugAddress="${OC_IBSRV_DEBUG_ADDRESS}",
        [string]$IbsrvDebugPort="${OC_IBSRV_DEBUG_PORT}",
        [string]$IbsrvDebugUrl="${OC_IBSRV_DEBUG_URL}",
        [string]$IbsrvDebugPwd="${OC_IBSRV_DEBUG_PASSWORD}"
    )

    begin
    {
        
        $IbsrvExec = @( """${OCPath}\${Version}\bin\ibsrv.exe""")
        if ( $Service ) { $IbsrvExec+="--service" }
        
        $IbsrvExec+=@( "--direct-regport=${IbsrvPort}", "--direct-range=${IbsrvRangePorts}", "--direct-seclevel=${IbsrvSecLevel}" )
        
        if( $IbsrvDebugType ) { $IbsrvExec+=@( "--debug=${IbsrvDebugType}", "--debug-address=${IbsrvDebugAddress}", "--debug-port=${IbsrvDebugPort}" ) }
        if( ($IbsrvDebugType) -and ($IbsrvDebugUrl) ) { $IbsrvExec+="--debug-server-url=${IbsrvDebugUrl}" }
        if( ($IbsrvDebugType) -and ($IbsrvDebugPwd) ) { $IbsrvExec+="--debug-password=${IbsrvDebugPwd}" }
        if ( !($IbsrvDebugType) ) { $IbsrvExec+="--debug=none" }

        if ( $Service )
        {
            $IbsrvExec+="--config=""${IbsrvConfigPath}"""
        }
        else
        {
            $IbsrvExec+="--config=${IbsrvConfigPath}"
        }

        return $IbsrvExec
    }
}

function Get-Ibsrv-Init-Exec
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$IbsrvConfigPath="${OC_IBSRV_CONFIG_PATH}",
        [string]$IbsrvHttpAddr="${OC_IBSRV_HTTP_ADDRESS}",
        [string]$IbsrvHttpPort="${OC_IBSRV_HTTP_PORT}",
        [string]$IbsrvHttpPath="${OC_IBSRV_HTTP_PATH}",
        [string]$IbsrvBaseName="${OC_IBSRV_BASE_NAME}",
        [string]$IbsrvBasePath="${OC_IBSRV_FILE_BASE_PATH}",
        [ValidateSet("","MSSQLServer","PostrgeSQL","IBMDB2","OracleDatabase")][string]$IbsrvDbmsKind="${OC_IBSRV_DBMS_KIND}",
        [string]$IbsrvDbmsAddr="${OC_IBSRV_DBMS_ADRESS}",
        [string]$IbsrvDbmsName="${OC_IBSRV_DBMS_NAME}",
        [string]$IbsrvDbmsLogin="${OC_IBSRV_DBMS_LOGIN}",
        [string]$IbsrvDbmsPass="${OC_IBSRV_DBMS_PASSWORD}"
    )

    begin
    {
        $IbsrvExec = @( """${OCPath}\${Version}\bin\ibcmd.exe""", "server", "config", "init" )
        $IbsrvExec+="--http-address=${IbsrvHttpAddr}"
        $IbsrvExec+="--http-port=${IbsrvHttpPort}"
        $IbsrvExec+="--http-base=${IbsrvHttpPath}"
        $IbsrvExec+="--name=${IbsrvBaseName}"
        $IbsrvExec+="--distribute-licenses=no"
        $IbsrvExec+="--schedule-jobs=allow"
        $IbsrvExec+="--disable-local-speech-to-text=false"

        if( $IbsrvDbmsKind )
        {
            $IbsrvExec+="--dbms=${IbsrvDbmsKind}"
            $IbsrvExec+="--database-server=${IbsrvDbmsAddr}"
            $IbsrvExec+="--database-name=${IbsrvDbmsName}"
            $IbsrvExec+="--database-user=${IbsrvDbmsLogin}"
            $IbsrvExec+="--database-password=${IbsrvDbmsPass}"
        }
        else
        {
            $IbsrvExec+="--database-path=${IbsrvBasePath}"
        }
        $IbsrvExec+="--out=${IbsrvConfigPath}"

        return $IbsrvExec
    }
}

function Start-Ibsrv-Exec
{
    param
    (
        [string]$IbsrvExec
    )

    begin
    {
        Write-Host "Begining Ibsrv"
        Start-Exec ${IbsrvExec}
    }
}

function Set-Ibsrv-Config
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$IbsrvConfigPath="${OC_IBSRV_CONFIG_PATH}"
    )

    $IbsrvConfigDir = Split-Path -Path ${IbsrvConfigPath}
    if ( ! ( Test-Path "${IbsrvConfigDir}" ) )
    {
        New-Catalog-With-Rules "${IbsrvConfigDir}"
    }
    if ( ! ( Test-Path "${IbsrvConfigPath}" ) )
    {
        Write-Host "Init ibsrv";
        $IbsrvInitExec = Get-Ibsrv-Init-Exec "${OCPath}" "${Version}" "${IbsrvConfigPath}"
        Start-Exec ${IbsrvInitExec}
    }
    Set-Icacls-Rules "${IbsrvConfigPath}"

    $Config = Get-Content "${IbsrvConfigPath}" -Raw
    Write-Host $Config
    $ConfigYml = ConvertFrom-Yaml $Config
    if ( ( ! ( $ConfigYml.database.dbms ) ) -and ( $ConfigYml.database.path ) )
    {
        $IbsrvBasePath = "$($ConfigYml.database.path)"
        if ( ! (Test-Path "${IbsrvBasePath}" ) )
        {
            New-Catalog-With-Rules "${IbsrvBasePath}"
            & "${OCPath}\${Version}\bin\ibcmd.exe" @( "infobase", "create", "--database-path=${IbsrvBasePath}")
            Set-Icacls-Rules "${IbsrvBasePath}\*"
        }
    }
}

function Set-Ibsrv-Service
{
    param(
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$IbsrvPort="${OC_IBSRV_PORT}",
        [string]$IbsrvRangePorts="${OC_IBSRV_RANGE_PORT}",
        [string]$IbsrvConfigPath="${OC_IBSRV_CONFIG_PATH}",
        [string]$IbsrvSecLevel="${OC_IBSRV_SECLEVEL}",
        [ValidateSet("","tcp","http","server")][string]$IbsrvDebugType="${OC_IBSRV_DEBUG_TYPE}",
        [string]$IbsrvDebugAddress="${OC_IBSRV_DEBUG_ADDRESS}",
        [string]$IbsrvDebugPort="${OC_IBSRV_DEBUG_PORT}",
        [string]$IbsrvDebugUrl="${OC_IBSRV_DEBUG_URL}",
        [string]$IbsrvDebugPwd="${OC_IBSRV_DEBUG_PASSWORD}",
        [System.Management.Automation.PSCredential]$Credential
    )

    begin
    {
        Write-Host "Creating Ibsrv Server"

        $ServiceName = Get-Ibsrv-Service-Name
        $IbsrvExec   = Get-Ibsrv-Exec `
            "${OCPath}" `
            "${Version}" `
            $true `
            "${IbsrvPort}" `
            "${IbsrvRangePorts}" `
            "${IbsrvConfigPath}" `
            "${IbsrvSecLevel}" `
            "${IbsrvDebugType}" `
            "${IbsrvDebugAddress}" `
            "${IbsrvDebugPort}" `
            "${IbsrvDebugUrl}" `
            "${IbsrvDebugPwd}"

        Set-OC-Service "${ServiceName}" "${IbsrvExec}" $Credential

    }
}

function Start-Ibsrv-Service
{
    begin
    {
        $ServiceName = Get-Ibsrv-Service-Name
        Start-OC-Service "${ServiceName}"
    }
}

# CRS

function Get-CRS-Service-Name
{
    begin
    {
        return "1C:Enterprise 8.3 Configuration Repository Server"
    }
}

function Get-CRS-Exec
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$CRSPort="${OC_CRSERVER_PORT}",
        [string]$StoragePath="${OC_CRSERVER_PATH}"
    )

    begin
    {
        $CRSExec = @( """${OCPath}\${Version}\bin\crserver.exe""", "-srvc -port ${CRSPort}", "-d ""${StoragePath}""" )
        return "$CRSExec"
    }
}

function Start-CRS-Exec
{
    param
    (
        [string]$CRSExec
    )

    begin
    {
        Write-Host "Begining CRServer"
        Start-Exec ${CRSExec}
    }
}

function Set-CRS-Service
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$CRSPort="${OC_CRSERVER_PORT}",
        [string]$StoragePath="${OC_CRSERVER_PATH}",
        [System.Management.Automation.PSCredential]$Credential
    )

    begin
    {
        #Создание службы сервера хранилища конфигураций 1С
        Write-Host "Creating Configuration Repository Server"

        $ServiceName = Get-CRS-Service-Name
        $CRSExec     = Get-CRS-Exec "${OCPath}" "${Version}" "${CRSPort}" "${StoragePath}"
        
        Set-OC-Service "${ServiceName}" "${CRSExec}" $Credential
    }
}

function Start-CRS-Service
{
    begin
    {
        $ServiceName = Get-CRS-Service-Name
        Start-OC-Service "${ServiceName}"
    }
}

# Comcntr

function Set-Comcntr
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version
    )

    begin
    {
        # Регистрация компонента для установки COM-соединения (comcntr.dll).
        regsvr32 /s "${OCPath}\${Version}\bin\comcntr.dll"
    }

}

# Wsisapi

function Set-Wsisapi-IIS
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version
    )

    begin
    {
        Start-Process -FilePath "C:\ServiceMonitor.exe" -ArgumentList "w3svc" -WindowStyle Hidden
        Import-Module WebAdministration
        # Прописываются настройки в файл C:\Windows\System32\inetsrv\config\applicationHost.config
        Set-WebConfiguration /System.webServer/handlers -metadata overrideMode -value Allow -PSPath IIS:/
        Add-WebConfiguration /system.webServer/security/isapiCgiRestriction -value @{description="1C Web-service Extension"; path="${OCPath}\${Version}\bin\wsisapi.dll"; allowed="True"}
    }
}

function Set-OC-IIS
{
    param
    (
        [string]$OCPath="${OC_PATH}",
        [Parameter(Mandatory)][string]$Version,
        [string]$IISPath="${IIS_DEF_PATH}",
        [string]$OCLoc="${OC_LOCATION}"
    )

    begin
    {
        
        if( ! (Test-Path -Path "${OCPath}\${Version}\bin\wsisapi.dll") )
        { 
            return
        }

        $ArgumentList = @(
            "C:\ServiceMonitor.exe" 
            "w3svc"
        )

        Start-Process -FilePath "C:\LogMonitor\LogMonitor.exe" -ArgumentList $ArgumentList -WindowStyle Hidden

        if(Test-Path -Path "${IISPath}\web.config")
        { 
            Remove-Item "${IISPath}\web.config"
        }

        Import-Module WebAdministration

        New-WebHandler -Location @('1c') -PSPath 'IIS:\Sites\Default Web Site' -Name '1C Web-service Extension' -Path '*' -Verb '*' -Modules 'IsapiModule' -ScriptProcessor "${OCPath}\${Version}\bin\wsisapi.dll" -ResourceType 'Unspecified' -RequiredAccess 'Script' -Precondition 'bitness64'
        New-WebHandler -Location @('1c') -PSPath 'IIS:\Sites\Default Web Site' -Name '1crs' -Path '*.1crs' -Verb '*' -Modules 'IsapiModule' -ScriptProcessor "${OCPath}\${Version}\wsisapi.dll" -ResourceType 'Unspecified' -RequiredAccess 'Execute' -Precondition 'bitness64'
        New-WebHandler -Location @('1c') -PSPath 'IIS:\Sites\Default Web Site' -Name '1cws' -Path '*.1cws' -Verb '*' -Modules 'IsapiModule' -ScriptProcessor "${OCPath}\${Version}\wsisapi.dll" -ResourceType 'Unspecified' -RequiredAccess 'Execute' -Precondition 'bitness64'

        If ( ! (Test-Path "${IISPath}\${OCLoc}") )
        {
            return
        }
        
        Get-ChildItem "${IISPath}\${OCLoc}\" |
        Foreach-Object {
            $AppStatus = Get-WebApplication | Where-Object Path -eq "/$(${OCLoc}.Replace('\','/'))/$($_.Name)" | Measure-Object
            if ( ${AppStatus}.count -eq 0 )
            {
                New-WebApplication -Name "${OCLoc}\$($_.Name)" -ApplicationPool "DefaultAppPool" -Site "Default Web Site" -PhysicalPath "${IISPath}\${OCLoc}\$($_.Name)" -Force
            }
        }
    }
}

function Set-CRS-IIS
{
    param
    (
        [string]$IISPath="${IIS_DEF_PATH}",
        [string]$CRSLoc="${OC_CRSERVER_LOCATION}"
    )

    process
    {
        $CRSLocDir = Split-Path -Path ${CRSLoc}

        if( ! (Test-Path -Path "${IISPath}\${CRSLoc}") )
        {
            New-Item -ItemType "Directory" -Path "${IISPath}\${CRSLocDir}" -Force
            New-Item "${IISPath}\${CRSLoc}"
            Set-Content -Path "${IISPath}\${CRSLoc}" -Value "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`r`n<storage connectString=`"tcp://localhost`"/>"
        }
        $AppStatus = Get-WebApplication | Where-Object Path -eq "/$(${CRSLocDir}.Replace('\','/'))" | Measure-Object
        if ( ${AppStatus}.count -eq 0 )
        {
            New-WebApplication -Name "${CRSLocDir}" -ApplicationPool "DefaultAppPool" -Site "Default Web Site" -PhysicalPath "${IISPath}\${CRSLocDir}" -Force
        }
        if(Test-Path -Path "${IISPath}\${CRSLocDir}\web.config")
        { 
            Remove-Item "${IISPath}\${CRSLocDir}\web.config"
        }
        Add-WebConfigurationProperty    -PSPath "IIS:\Sites\Default Web Site\${CRSLocDir}" -filter "system.webServer/staticContent" -name "." -value @{fileExtension='.1ccr'; mimeType='text/xml'}
        Set-WebConfigurationProperty    -PSPath "IIS:\Sites\Default Web Site\${CRSLocDir}" -filter "system.webServer/security/requestFiltering/requestLimits" -name "maxAllowedContentLength" -value 2097152000
        Remove-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site\${CRSLocDir}" -filter "system.webServer/handlers" -name "." -AtElement @{name='1crs'}
        Remove-WebConfigurationProperty -PSPath "IIS:\Sites\Default Web Site\${CRSLocDir}" -filter "system.webServer/handlers" -name "." -AtElement @{name='1cws'}
    }
}