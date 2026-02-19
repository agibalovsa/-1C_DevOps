function Install-Packs
{
    begin
    {
        choco install liberica8jre -y
        # Installing SQL Server Native Client
        choco install sql2012.nativeclient -y
    }
}