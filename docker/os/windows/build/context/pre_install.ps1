function Install-Packs
{
    begin
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -Force
        Install-Module powershell-yaml -Force
        
        mkdir "logs"
        Invoke-WebRequest "https://github.com/microsoft/windows-container-tools/releases/download/v2.0.2/LogMonitor.exe" `
            -OutFile "/LogMonitor/LogMonitor.exe"

        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ( (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1') )

        choco install powershell-core -y
        choco install nano -y
        choco install 7zip -y
        choco install et dust -y

    }
}