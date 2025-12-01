function Get-Log
{
    begin
    {
        $lastCheck = (Get-Date).AddSeconds(-2)
        while ( $true )
        {
            Get-EventLog -LogName Application -After $lastCheck | Select-Object TimeGenerated, EntryType, Message | Format-List
            Get-EventLog -LogName System -After $lastCheck | Select-Object TimeGenerated, EntryType, Message | Format-List
            $lastCheck = Get-Date
            Start-Sleep -Seconds 2
        }
    }
}

if ( $args[0] -eq "cmd" )
{
    cmd
}
elseif ( ( $args[0] -eq "pwsh" ) -or ( $args[0] -eq "") )
{
    pwsh
}
elseif ( ( $args[0] -match ".*=.*" ))
{
    foreach ($Param in $args)
    {
        $Commands = ConvertFrom-StringData($Param)
        foreach ($Command in $Commands.GetEnumerator()) {
            & "entrypoint.d/entrypoint_$($Command.Key).ps1" $Command.Value
        }
    }

    Get-Log
}
else
{
    Write-Error "Wrong parametr: $($args[0])"
    exit 1
}

exit 0