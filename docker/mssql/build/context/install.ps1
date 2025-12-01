function Install-Packs
{
    param
    (  
        [string]$DistrUrl,
        [string]$DistrName
    )

    process
    {
        Write-Verbose "Install from url ${DistrUrl}${DistrName}"

        $DistrPath = Resolve-Path .
        
        Invoke-WebRequest -maximumretrycount 5 -Uri "${DistrUrl}\${DistrName}.exe" -OutFile "${DistrPath}\${DistrName}.exe"
        Invoke-WebRequest -maximumretrycount 5 -Uri "${DistrUrl}\${DistrName}.box" -OutFile "${DistrPath}\${DistrName}.box"

        Start-Process -Wait -FilePath "${DistrPath}\${DistrName}.exe" -ArgumentList /qs, /x:"${DistrPath}\setup"
        
        Remove-Item -Force "${DistrPath}\${DistrName}.exe", "${DistrPath}\${DistrName}.box"

        & "${DistrPath}\setup\setup.exe" `
            /q `
            /ACTION=Install `
            /INSTANCENAME=MSSQLSERVER `
            /FEATURES=SQLEngine `
            /UpdateEnabled=false `
            /SQLSVCACCOUNT='NT AUTHORITY\System' `
            /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' `
            /TCPENABLED=1 `
            /NPENABLED=0 `
            /IACCEPTSQLSERVERLICENSETERMS `
            /INDICATEPROGRESS

        Remove-Item -Recurse -Force "${DistrPath}\setup"

        Stop-Service MSSQLSERVER

        Set-ItemProperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql16.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value ''
        Set-ItemProperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql16.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433
        Set-ItemProperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql16.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2
    }

}

function Install-Update
{
    param
    (
        [string]$UpdateUrl
    )

    process
    {
        $UpdPath="$(Resolve-Path .)\upd"

        mkdir "${UpdPath}"
        Invoke-WebRequest -maximumretrycount 5 -Uri $UpdateUrl -OutFile "${UpdPath}\MSSQL_upd.exe"

        Start-Process -Wait -FilePath "${UpdPath}\MSSQL_upd.exe" -ArgumentList /qs, /x:"${UpdPath}\setup"

        Remove-Item -Force "${UpdPath}\MSSQL_upd.exe"

        Start-Process -Wait -FilePath msiexec.exe -ArgumentList /quiet, /qn, /a, "${UpdPath}\setup\1033_ENU_LP\x64\Setup\SQLSUPPORT.MSI", /qb, TARGETDIR="${UpdPath}\msi"
    
        $prefix = "v4.0_16.0.0.0_"
        $suffix = "_89845dcd8080cc91"

        $folder_msi = "${UpdPath}\msi\Windows\Gac"
        $folder_ne = "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.NetEnterpriseServers.ExceptionMessageBox.resources"
        $folder_cc = "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.SqlServer.CustomControls.resources"

        foreach ( $lang_folder in $( Get-ChildItem $folder_msi -Directory ) ) {
            $lang = $lang_folder.Name
            $newfolder_ne = "${folder_ne}\${prefix}${lang}${suffix}"
            $newfolder_cc = "${folder_cc}\${prefix}${lang}${suffix}"
            $null = New-Item -ItemType Directory -Path ${newfolder_ne} -ErrorAction SilentlyContinue
            $null = New-Item -ItemType Directory -Path ${newfolder_cc} -ErrorAction SilentlyContinue
            $null = Copy-Item "${folder_msi}\${lang}\Microsoft.NetEnterpriseServers.ExceptionMessageBox.Resources.dll" ${newfolder_ne} -ErrorAction SilentlyContinue
            $null = Copy-Item "${folder_msi}\${lang}\Microsoft.Sqlserver.CustomControls.Resources.dll" ${newfolder_cc} -ErrorAction SilentlyContinue
        }

        Remove-Item -Recurse -Force "${UpdPath}\msi"

        & "${UpdPath}\setup\setup.exe" `
            /q `
            /ACTION=Patch `
            /IAcceptSQLServerLicenseTerms `
            /AllInstances `
            /INDICATEPROGRESS

        Remove-Item -Recurse -Force "${UpdPath}"
    }
}