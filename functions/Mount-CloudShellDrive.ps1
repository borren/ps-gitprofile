function Mount-CloudShellDrive {
    switch ($true) {
        $isWindows {
            if (Get-PSDrive -name S) {
                Write-Verbose "Found S:\ drive."
                return "S:"
            }
            else {
                $acctUser = $env:storagePath.split('.')[0]
                $acctKey = ConvertTo-SecureString -String $env:storageKey -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$acctUser", $acctKey

                try {
                    New-PSDrive -Name S -PSProvider FileSystem -Root "\\$env:storagePath" -Credential $credential -Persist -Scope Global -ErrorAction Stop
                    Write-Verbose "Mapped drive \\$env:storagePath using $($credential.UserName)"
                    return "S:"
                }
                catch {
                    Write-Host -ForegroundColor Darkred "Error mapping cloudshell drive at $env:storagePath."
                    return split-path($env:LocalGitProfile).tostring()
                }
            }                
        }
        $isLinux {
            if (Get-PSDrive -name "cloudshell" -ErrorAction SilentlyContinue) {
                return "$home/cloudshell"
            }
            else {
                $acctUser = $env:storagePath.split('.')[0]
                $acctKey = ConvertTo-SecureString -String $env:storageKey -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$acctUser", $acctKey

                try {
                    # apparently New-PSDrive is still pretty broken, per https://github.com/PowerShell/PowerShell/issues/6629
                    #New-PSDrive -Name S -PSProvider FileSystem -Root "//$env:storagePath/$env:storageShare" -Credential $credential -Persist -Scope Global -ErrorAction Stop
                    #Write-Verbose "Mapped drive //$env:storagePath\$env:storageShare using $($credential.UserName)"

                    if (-not (test-path "$home/cloudshell")) { new-item -path $home/cloudshell -ItemType Directory | Out-Null }
                    try {
                        Invoke-Expression "sudo mount -t cifs -o username=$credential.UserName,password=$env:storageKey //$env:storagePath $home/cloudshell" -ErrorAction Stop
                    }
                    catch {
                        Write-Host -ForegroundColor DarkRed "Error mapping cloudshell drive at $env:storagePath."
                        return split-path($env:LocalGitProfile).tostring()
                    }
                    Write-Verbose "Mapped drive \\$env:storagePath using $($credential.UserName)"
                    return "$home/cloudshell"
                }
                catch {
                    Write-Host -ForegroundColor Darkred "Error mapping cloudshell drive at $env:storagePath."
                    return split-path($env:LocalGitProfile).tostring()
                }
            }                
        }
        $IsMacOS {
            Write-Host "Cloud Shell Mapping not yet enabled for MacOS, sorry."
            return split-path($env:LocalGitProfile).tostring()
        }
    }
    return $null
}
   