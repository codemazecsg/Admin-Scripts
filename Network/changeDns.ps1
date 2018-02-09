
param (

    [Parameter(Mandatory=$true)] [string] $virtualNetworkName,
    [Parameter(Mandatory=$true)] [string] $resourceGroupName,
    [Parameter(Mandatory=$true)] [string] $dnsServersIpAddress
)

$vnet = Get-AzureRMVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName
$vnet.DhcpOptions.DnsServers = $dnsServersIpAddress
Set-AzureRMVirtualNetwork -VirtualNetwork $vnet