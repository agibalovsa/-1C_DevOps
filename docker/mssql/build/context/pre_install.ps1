function Install-Packs
{
    begin
    {
        Invoke-WebRequest "https://aka.ms/vc14/vc_redist.x64.exe" `
            -OutFile "./vc_redist.x64.exe"
        Start-Process -FilePath "./vc_redist.x64.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
        Remove-Item "./vc_redist.x64.exe"
    }
}