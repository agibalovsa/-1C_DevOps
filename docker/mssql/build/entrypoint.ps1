function setup_mssql_healthcheck {

    if( !(Test-Path -Path "./healthcheck.ps1" ) )
    {
        echo "sqlcmd -Q select 1"  > ./healthcheck.ps1
    }

}

function set_passwd_mssql {

    Write-Verbose "Changing SA login credentials"

    $Cred   = Get-Credential
    $Passw  = $Cred.GetNetworkCredential().password
    $User   = $Cred.Username
    $sqlcmd = "ALTER LOGIN $User with password='${Passw}'; ALTER LOGIN ${User} ENABLE;"
    & sqlcmd -Q ${sqlcmd}
    $Passw  = ""
    $sqlcmd = ""
    $User   = ""

}

function init_first_start_mssql {

    if( !(Test-Path -Path 'C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL/*') )
    {
        Get-ChildItem "C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/" |
        Foreach-Object {
            $FullName = $_.FullName.Replace("\MSSQL_temp\", "\MSSQL\")
            Copy-Item $_.FullName $FullName -Recurse
        }

        Get-ChildItem "C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/" -Recurse |
        Foreach-Object {
            $FullName = $_.FullName.Replace("\MSSQL_temp\", "\MSSQL\")
            $acl = Get-Acl $_.FullName;
            Set-Acl $FullName -AclObject $acl;
        }
    }

    if( Test-Path -Path 'C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/*' )
    {
        Remove-Item "C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/" -Recurse
    }

}

function start_mssql {

    Write-Host "Starting SQL Server"

    if( !(Test-Path -Path 'C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL/*') )
    {
        Write-Warning "SQL Server is not initialized. Run docker with command `"init`""
        exit 1
    }

    Start-Service MSSQLSERVER

    if ( $Env:MSSQL_AGENT_ENABLED )
    {
        Start-Service SQLSERVERAGENT
    }

    Write-Host "SQL Server started"

}

function get_log_mssql {

    $lastCheck = (Get-Date).AddSeconds(-2)
    while ( $true )
    {
        Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message | Format-List
        $lastCheck = Get-Date
        Start-Sleep -Seconds 2
    }

}

function init_mssql {

    init_first_start_mssql
    start_mssql

    set_passwd_mssql

}

function mssql {

    setup_mssql_healthcheck
    start_mssql
    get_log_mssql

}

if ( $args[0] -eq "cmd" )
{
    cmd
}
elseif ( $args[0] -eq "pwsh" )
{
    pwsh
}
else
{
    if ( $args[0] -eq "mssql" )
    {
        mssql
    }
    elseif ( $args[0] -eq "init" )
    {
        init_mssql
    }
    else
    {
        pwsh
    }
}

exit 0