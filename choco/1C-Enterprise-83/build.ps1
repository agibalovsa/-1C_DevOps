$Version = Read-Host "Введите версию 1С с сайта https://releases.1c.ru/project/Platform83"
$Nuspec = (Get-ChildItem *.nuspec).FullName

[xml]$xml = Get-Content $Nuspec
$xml.package.metadata.version = $Version
$xml.Save($Nuspec)

choco pack $Nuspec