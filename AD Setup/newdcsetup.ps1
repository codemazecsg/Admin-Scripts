
param (
    [parameter(Mandatory=$true)] [string] $databasePath,
    [parameter(Mandatory=$true)] [string] $domainName,
    [parameter(Mandatory=$true)] [string] $logPath,
    [parameter(Mandatory=$true)] [string] $sysVolPath
)

Install-windowsfeature AD-domain-services
Install-WindowsFeature RSAT-ADDS

Import-Module ADDSDeployment

$psCred = Get-Credential

Install-ADDSDomainController -CreateDnsDelegation: $false `
                             -Credential $psCred `
                             -DatabasePath $databasePath `
                             -DomainName $domainName `
                             -InstallDns: $true `
                             -LogPath $logPath `
                             -NoRebootOnCompletion: $false `
                             -SysvolPath $sysVolPath `
                             -Force: $true
