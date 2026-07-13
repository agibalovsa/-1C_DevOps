$LocalPackages = Get-ChildItem -Path . -Filter "1C-Enterprise-83.*.nupkg"

if (-not $LocalPackages) {
    Write-Error "В текущем каталоге не найдено собранных пакетов 1C-Enterprise-83 (*.nupkg)."
    exit
}

$Versions = $LocalPackages.Name | ForEach-Object {
    if ($_ -match '1C-Enterprise-83\.(?<version>[\d\.]+)\.nupkg') {
        $Matches['version'] = $Matches['version'].TrimEnd('.')
        $Matches['version']
    }
} | Sort-Object { [version]$_ } -Descending

. "../../docker/common_context/build/tools.ps1"

$CustomFields = @(
    @{
        Name    = "Version"
        Options = $Versions
    },
    @{
        Name    = "InstallPath"
        Default = "D:\Program Files\1cv8"
    }
)

$InstallData = Invoke-YamlForm -FormPath "install-form.yml" -CustomFields $CustomFields

if (-not $InstallData) {
    Write-Error "Данные формы не получены."
    Exit
}

$Params = "/ReleasesLogin:'$($InstallData.Login)' /ReleasesPassword:'$($InstallData.Password)' /OCPath:'$($InstallData.InstallPath)' /Client:1 /Server:1"

choco install 1C-Enterprise-83 --version $InstallData.Version --source "." --params="${Params}" --suppress-arguments-sensitive
