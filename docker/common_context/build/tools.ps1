function Set-Vars-From-File
{
    param
    (
        [Parameter(Mandatory)][string]$FilePath,
        [string]$VarName = ""
    )

    Process
    {
        Get-Content $FilePath | ForEach-Object {
            if ( $_ -like '^#.*' ) { continue }
            if ( $_ )
            {
                $name, $value = $_.split('=')
                if ( ($VarName) -and ($VarName -eq $name) -or (-not $VarName) )
                {
                    $value=$ExecutionContext.InvokeCommand.ExpandString($value).Trim('"')
                    New-Variable -Name $name -Value $value -Force -Scope Script
                }
            }
        }
    }

}

function Get-Ini-Content
{
    param
    (
        [Parameter(Mandatory)][string]$FilePath
    )

    Process
    {
        $ini = @{}
        switch -regex -file $FilePath
        {
            "^\[(.+)\]" # Section
            {
                $section = $matches[1]
                $ini[$section] = @{}
                $CommentCount = 0
            }
            "^(;.*)$" # Comment
            {
                $value = $matches[1]
                $CommentCount = $CommentCount + 1
                $name = "Comment" + $CommentCount
                $ini[$section][$name] = $value
            }
            "(.+?)\s*=(.*)" # Key
            {
                $name,$value = $matches[1..2]
                $ini[$section][$name] = $value
            }
        }

        return $ini
    }

}

function Invoke-YamlForm {
    param(
        [string]$FormPath = "form.yml",
        [object[]]$CustomFields = @()
    )

    begin
    {
        if (-not (Get-Module -ListAvailable Microsoft.PowerShell.ConsoleGuiTools)) {
           Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser -Force -ErrorAction Stop
        }
        if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
            Install-Module powershell-yaml -Scope CurrentUser -Force -ErrorAction Stop
        }
        Import-Module powershell-yaml
        $ModulePath = (Get-Module -ListAvailable Microsoft.PowerShell.ConsoleGuiTools).ModuleBase
        Add-Type -Path (Join-Path $ModulePath "Terminal.Gui.dll")
    }

    Process
    {
        if (-not (Test-Path $FormPath)) {
            throw "Form '${FormPath}' not found"
        }

        # Reading form
        $Config = Get-Content $FormPath -Raw | ConvertFrom-Yaml

        foreach ($CustomField in $CustomFields) {
            $ConfigField = $Config.Fields | Where-Object { $_.Name -eq $CustomField.Name }
            if ($ConfigField)
            {
                foreach ($Key in $CustomField.Keys)
                {
                    if ($Key -ne "Name")
                    {
                        $ConfigField.$Key = $CustomField.$Key
                    }
                }
            }
        }

        [Terminal.Gui.Application]::Init()
        $top = [Terminal.Gui.Application]::Top
        $win = [Terminal.Gui.Window]::new($Config.Title)
        $win.X = 0; $win.Y = 0; $win.Width = [Terminal.Gui.Dim]::Fill(); $win.Height = [Terminal.Gui.Dim]::Fill()

        $currentY = 1
        $generatedControls = [ordered]@{}

        foreach ($f in $Config.Fields) {

            # Create label
            $label = [Terminal.Gui.Label]::new($f.Label)
            $label.X = 2; $label.Y = $currentY
            $win.Add($label)

            if ($f.Type -eq "Radio") {
                # Create list
                $optionsArray = [string[]]($f.Options)
                $radio = [Terminal.Gui.RadioGroup]::new($optionsArray)
                $radio.X = 4; $radio.Y = $currentY + 1
                $win.Add($radio)

                $generatedControls[$f.Name] = @{ Control = $radio; Type = "Radio"; Options = $optionsArray }
                $currentY += ($optionsArray.Count + 2)
            }
            else {
                # Create input box
                $defaultValue = if ($f.Default) { $f.Default } else { "" }
                $txt = [Terminal.Gui.TextField]::new($defaultValue)
                $txt.X = 35; $txt.Y = $currentY; $txt.Width = 35

                if ($f.Type -eq "Password") { $txt.Secret = $true }

                $win.Add($txt)
                $generatedControls[$f.Name] = @{ Control = $txt; Type = "Text" }
                $currentY += 2
            }
        }

        # Create button OK
        $btn = [Terminal.Gui.Button]::new("ОК")
        $btn.X = 2; $btn.Y = $currentY + 1
        $btn.add_Clicked({ [Terminal.Gui.Application]::RequestStop() })
        $win.Add($btn)

        $top.Add($win)
        [Terminal.Gui.Application]::Run($top)
        [Terminal.Gui.Application]::Shutdown()

        # Get results
        $results = [ordered]@{}
        foreach ($key in $generatedControls.Keys)
        {
            $item = $generatedControls[$key]
            if ($item.Type -eq "Radio") {
                $results[$key] = $item.Options[$item.Control.SelectedItem]
            } else {
                $results[$key] = $item.Control.Text.ToString()
            }
        }

        return [PSCustomObject]$results
    }
}

function Get-Credential
{
    param (
        [string]$UserName,
        [string]$Password
    )

    process
    {
        if (  ${UserName} )
        {
            $PasswordSec = ConvertTo-SecureString ${Password} -AsPlainText -Force
            $Credential  = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ".\${UserName}", ${PasswordSec}
        }
        else
        {
            $PasswordSec = New-Object System.Security.SecureString
            $Credential  = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\SYSTEM", ${PasswordSec}
        }

        return $Credential
    }
    
}
function New-Docker-Volume
{
    param
    (
        [Parameter(Mandatory)][string]$VolumeName,
        [string]$MountPoint
    )

    Process
    {
        docker volume create "${VolumeName}"
        if ($MountPoint)
        {
            $CurrentMountpoint=(docker volume inspect "${VolumeName}" | ConvertFrom-Json).Mountpoint
            Remove-Item -Path "${CurrentMountpoint}" -Recurse -Force
            New-Item -ItemType Directory -Path "${MountPoint}" -Force
            junction "${CurrentMountpoint}" "${MountPoint}"
        }
    }
}

function Remove-Docker-Volume
{
    param
    (
        [Parameter(Mandatory)][string]$VolumeName
    )

    Process
    {
        $CurrentMountpoint=(docker volume inspect ${VolumeName} | ConvertFrom-Json).Mountpoint
        $ItemCurrentMountpoint = Get-Item "${CurrentMountpoint}"
        if ($ItemCurrentMountpoint.LinkType -eq "Junction") {
            junction -d "${CurrentMountpoint}"
            New-Item -ItemType Directory -Path "${CurrentMountpoint}" -Force
        }
        docker volume rm "${VolumeName}"
    }
}