function install_packs {

    mkdir logs;
    Invoke-WebRequest "https://github.com/microsoft/windows-container-tools/releases/download/v2.0.2/LogMonitor.exe" `
        -OutFile LogMonitor/LogMonitor.exe;

    Set-ExecutionPolicy Bypass -Scope Process -Force ;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ;
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));

    choco install powershell-core -y;

}