function Install-Packs
{
    begin
    {
        # install ws 1c
        if ( ${script:OC_MODE_WS} -eq "1" )
        {
            Add-WindowsFeature Web-Server | Format-List
            Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/microsoft/IIS.ServiceMonitor/releases/download/v${script:VER_SM}/ServiceMonitor.exe" -OutFile "C:/ServiceMonitor.exe"
            Set-Service -Name "w3svc" -StartupType "Manual"
            dism /online /enable-feature /all /featurename:IIS-ISAPIFilter
            dism /online /enable-feature /all /featurename:IIS-ISAPIExtensions
        }

        # install client 1c
        # if ( ${script:OC_MODE_CLIENT} -eq "1" )
        # {
            # установка XX для Windows
        # }
    }

}