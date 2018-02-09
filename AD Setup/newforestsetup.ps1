
param (
    [parameter(Mandatory=$true)] [string] $databasePath,
    [parameter(Mandatory=$true)] [string] $domainMode,
    [parameter(Mandatory=$true)] [string] $domainName,
    [parameter(Mandatory=$true)] [string] $domainNetBiosName,
    [parameter(Mandatory=$true)] [string] $forestMode,
    [parameter(Mandatory=$true)] [string] $logPath,
    [parameter(Mandatory=$true)] [string] $sysVolPath
)

Install-windowsfeature AD-domain-services
Install-WindowsFeature RSAT-ADDS

Import-Module ADDSDeployment

Install-ADDSForest -CreateDnsDelegation: $false `
                    -DatabasePath $databasePath `
                    -DomainMode $domainMode `
                    -DomainName $domainName `
                    -DomainNetbiosName $domainNetBiosName.ToUpper() `
                    -ForestMode $forestMode `
                    -InstallDns: $true `
                    -LogPath $logPath `
                    -NoRebootOnCompletion: $false `
                    -SysvolPath $sysVolPath `
                    -Force: $true