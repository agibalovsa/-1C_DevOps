function Set-Healthcheck-MSSQL
{
    begin
    {
        if( !(Test-Path -Path "./healthcheck.ps1" ) )
        {
            Write-Output "sqlcmd -S localhost -Q `"SELECT 1`""  > "./healthcheck.ps1"
        }
    }

}

function Set-Passwd-MSSQL
{
    begin
    {
        Write-Verbose "Changing SA login credentials"

        $Cred   = Get-Credential
        $Passw  = $Cred.GetNetworkCredential().password
        $User   = $Cred.Username
        $sqlcmd = "ALTER LOGIN $User with password='${Passw}'; ALTER LOGIN ${User} ENABLE;"
        & sqlcmd -S localhost -Q ${sqlcmd}
        $Passw  = ""
        $sqlcmd = ""
        $User   = ""
    }
}

function Set-First-Start-MSSQL
{

    begin
    {
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
                $acl = Get-Acl $_.FullName
                Set-Acl $FullName -AclObject $acl
            }
        }

        if( Test-Path -Path 'C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/*' )
        {
            Remove-Item "C:/Program Files/Microsoft SQL Server/MSSQL16.MSSQLSERVER/MSSQL_temp/" -Recurse
        }
    }
}

function Start-MSSQL
{
    begin
    {
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
}


function Set-MSSQL
{
    begin
    {
        Set-First-Start-MSSQL
        Start-MSSQL
        Set-Passwd-MSSQL
    }
}

function MSSQL
{
    begin
    {
        Set-Healthcheck-MSSQL
        Start-MSSQL
    }
}

if ( $args[0] -eq "mssql" )
{
    MSSQL
}
elseif ( $args[0] -eq "init" )
{
    Set-MSSQL
}
else
{
    Write-Error "Wrong parametr: $($args[0])"
    exit 1
}

exit 0