function Set-Vars-From-File
{
    param
    (
        [string]$FilePath,
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
        [string]$FilePath
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