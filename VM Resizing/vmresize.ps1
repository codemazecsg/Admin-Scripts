
param (

    [Parameter(Mandatory=$true)] [string] $resourceGroupName,
    [Parameter(Mandatory=$true)] [string] $newVmSize,
    [Parameter(Mandatory=$true)] [string[]] $exclusions

)

$vms = Get-AzureRmVM -ResourceGroupName $resourceGroupName

foreach ($vm in $vms)
{
    if ($exclusions.Contains($vm.Name))
    {
        continue;
    }

    $vm.HardwareProfile.vmSize = $newVmSize
    Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $vm
}
