Set-Location -Path $PSScriptRoot

$Version = Read-Host "Введите версию платформы 1С с сайта https://releases.1c.ru/project"

$ConfigFile = (Get-ChildItem *.nuspec)

[xml]$xml = Get-Content $ConfigFile.FullName
$xml.package.metadata.version = $Version
$xml.Save($ConfigFile.FullName)

choco pack $ConfigFile.FullName
