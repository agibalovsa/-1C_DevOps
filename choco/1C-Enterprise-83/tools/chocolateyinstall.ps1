$ErrorActionPreference = 'Stop' # stop on all errors

$Param = Get-PackageParameters

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$InstallPath = if ($Param['OCPath']) { ( Join-Path $Param['OCPath'] ${env:chocolateyPackageVersion} ) } else { "" }
$DistrPath = if ($Param['DistrPath']) { $Param['DistrPath'] } else { "${toolsDir}" }
$Server = if ($Param['Server']) { $Param['Server'] } else { 0 }
$WS = if ($Param['WS']) { $Param['WS'] } else { 0 }
$CRS = if ($Param['CRS']) { $Param['CRS'] } else { 0 }
$Client = if ($Param['Client']) { $Param['Client'] } else { 0 }
$User = if ($Param['User']) { $Param['User'] } else { "" }
$Password = if ($Param['Password']) { $Param['Password'] } else { "" }
$RelisesLogin = if ($Param['RelisesLogin']) { $Param['RelisesLogin'] } else { "" }
$RelisesPassword = if ($Param['RelisesPassword']) { $Param['RelisesPassword'] } else { "" }

$DistrFileName = "windows64full_$($Env:chocolateyPackageVersion.Replace('.', '_')).rar"
$LocalDistrFilePath = (Join-Path "${DistrPath}" "${DistrFileName}")

. (Join-Path "${toolsDir}" "tools.ps1")
. (Join-Path "${toolsDir}" "oc_lib.ps1")

if ( Test-Path $LocalDistrFilePath )
{
    Write-Host "Local distribution ${LocalDistrFilePath} found" -ForegroundColor Green
} 
else
{
    Write-Host "Local distribution ${LocalDistrFilePath} not found. Starting download..." -ForegroundColor Yellow
    if ( ! $RelisesLogin )
    {
        $RelisesLogin    = Read-Host -Prompt "Enter login for releases.1c.ru..."
        Write-Host "Enter password for releases.1c.ru..." -ForegroundColor Yellow
        $SecurePassword  = $Host.UI.ReadLineAsSecureString()
        $RelisesPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
    }
    Get-OC-Msi-Rar "${DistrPath}" "${env:chocolateyPackageVersion}" "${RelisesLogin}" "${RelisesPassword}"
}
$InstallDistrPath = ( Join-Path "${toolsDir}" "install")
$DistrParam = Unpack-OC-Msi-Rar "${LocalDistrFilePath}" "${InstallDistrPath}"
$DistrMsiPath = ( Join-Path "${InstallDistrPath}" $DistrParam["PackageName"] ) 
Set-Envs

$silentArgs = @(
    "/l*v"
    '"' + ( Join-Path "${env:TEMP}" "${packageName}.${env:chocolateyPackageVersion}.MsiInstall.log" ) + '"'
    "/qn"
)
$silentArgs += Get-Install-Arg-OC-Msi "${InstallPath}" ${Server} ${WS} ${CRS} ${Client} ${User} ${Password}
$packageArgs = @{
    packageName   = $env:ChocolateyPackageName
    fileType      = 'MSI'
    softwareName  = '1c*'
    file          = "${DistrMsiPath}"
    silentArgs    = $($silentArgs -join ' ')
    validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyInstallPackage @packageArgs