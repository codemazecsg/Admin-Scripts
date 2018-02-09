param (
	[string] $resourceGroupName,
	[string] $location,
	[string] $publicIPName,
	[string] $nicName
)

$pip = New-AzureRmPublicIPAddress -Name $publicIPName -ResourceGroupName $resourceGroupName -AllocationMethod Dynamic -location $location
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName
$nic.IpConfigurations[0].PublicIpAddress = $pip
Set-AzureRmNetworkInterface -NetworkInterface $nic