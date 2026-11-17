Set-Location -Path $PSScriptRoot
$LocalPackages = Get-ChildItem -Path . -Filter "1C-Enterprise-83.*.nupkg"

if (-not $LocalPackages) {
    Write-Error "В текущем каталоге не найдено собранных пакетов 1C-Enterprise-83 (*.nupkg)."
    exit
}

$Versions = @($LocalPackages.Name | ForEach-Object {
    if ($_ -match '1C-Enterprise-83\.(?<version>[\d\.]+)\.nupkg') {
        $Matches['version'].TrimEnd('.')
    }
} | Sort-Object { [version]$_ } -Descending)

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

$CachePath = ".cache"
if (Test-Path $CachePath) {
    try {
        $CachedData = Get-Content -Raw -Path $CachePath | ConvertFrom-Json -AsHashtable
        foreach ($Key in $CachedData.Keys) {
            $CustomFields += @{
                Name    = $Key
                Default = $CachedData[$Key]
            }
        }
    } catch {
        Write-Warning "Не удалось прочитать кэш: $_"
    }
}

. "../../docker/common_context/build/tools.ps1"

$InstallData = Invoke-YamlForm -FormPath "install-form.yml" -CustomFields $CustomFields

if (-not $InstallData) {
    Write-Error "Данные формы не получены."
    Exit
}
else
{
    try {
        $InstallData | ConvertTo-Json | Set-Content -Path $CachePath -Force
    } catch {
        Write-Warning "Не удалось сохранить кэш: $_"
    }
}

$Params = "/ReleasesLogin:'$($InstallData.Login)' /ReleasesPassword:'$($InstallData.Password)' /OCPath:'$($InstallData.InstallPath)' /Client:1 /Server:1"

choco install 1C-Enterprise-83 --version $InstallData.Version --source "." --params="${Params}" --suppress-arguments-sensitive --force
