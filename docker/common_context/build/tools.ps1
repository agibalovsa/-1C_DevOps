function Set-Vars-From-File
{
    param
    (
        [Parameter(Mandatory)][string]$FilePath,
        [string]$VarName = ""
    )

    Process
    {
        Get-Content $FilePath | foreach {
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
function Create-Docker-Volume
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