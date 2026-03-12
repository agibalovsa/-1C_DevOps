$ErrorActionPreference = 'Stop'
$packageVersion = $env:ChocolateyPackageVersion

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    softwareName   = "1*8*(${packageVersion})"
    fileType       = 'MSI'
    silentArgs     = "/qn /norestart"
    validExitCodes = @(0, 3010, 1605, 1614, 1641)
}

[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName'] | Where-Object { $_.DisplayVersion -eq $packageVersion }

if ($keys.Count -eq 1)
{
    $keys | ForEach-Object {
        $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
        $packageArgs['file'] = ''
        Uninstall-ChocolateyPackage @packageArgs
    }
} 
elseif ($keys.Count -eq 0)
{
    Write-Warning "$($packageArgs['packageName']) version ${packageVersion} has already been uninstalled by other means."
} 
else
{
    Write-Warning "$($keys.Count) matches found!"
    Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
    Write-Warning "Please alert package maintainer the following keys were matched:"
    $keys | % {Write-Warning "- $($_.DisplayName)"}
}