$ErrorActionPreference = 'Stop'

Write-Host "Preparing the system for 1C:Enterprise update/modification..."

# 1. Terminate active client processes to prevent MSI file-in-use errors
$processesToClose = @("1cv8", "1cv8c", "1cv8s")

foreach ($processName in $processesToClose) {
    $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($runningProcesses) {
        Write-Warning "Closing active process: $processName..."
        Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# 2. Stop 1C:Enterprise services (Server, Agent, etc.)
$services = Get-Service -Name "1C:Enterprise 8*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' }

if ($services) {
    foreach ($service in $services) {
        Write-Warning "Stopping service: $($service.DisplayName)..."
        Stop-Service -InputObject $service -Force -Confirm:$false
    }
} else {
    Write-Host "No active 1C:Enterprise services found."
}

Write-Host "System is ready for modification."