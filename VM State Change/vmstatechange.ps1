
param (
  [Parameter(Mandatory=$true)] [String] $resourceGroupName,
  [Parameter(Mandatory=$true)] [String] $subscriptionId,
  [Parameter(Mandatory=$true)] [String] $certSubject,
  [Parameter(Mandatory=$true)] [String] $applicationId,
  [Parameter(Mandatory=$true)] [String] $tenantId,
  [Parameter(Mandatory=$true)] [String] $applicationKey,
  [Switch] $shutdown
)

workflow vmStateChange
{

    param(

        # Resource Group holding VMs
        [Parameter(Mandatory=$true)] [String] $resourceGroupName,

        # Subscription holding VMs
        [Parameter(Mandatory=$true)] [String] $subscriptionId,

        # Cert subject for auth
        [Parameter(Mandatory=$true)] [String] $certSubject,

        # AAD Application ID to call ARM REST API
        [Parameter(Mandatory=$true)] [String] $applicationId,

        # AAD Tenant ID
        [Parameter(Mandatory=$true)] [String] $tenantId,

        # Application Secret Key to get token
        [Parameter(Mandatory=$true)] [String] $applicationKey,

        # Shutdown or Startup
        [Switch] $shutdown

    )

    Get-Date

    # Endpoints for getting Oauth token and for calling management REST API
    $authEndPoint = "https://login.windows.net/$tenantId/oauth2/token"
    $armRestUri = "https://management.azure.com/"

    # Get Thumbprint from local store
    $thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match $certSubject }).Thumbprint

    # Add account for authentication
    Add-AzureRmAccount `
      -ServicePrincipal `
      -TenantId $tenantId `
      -ApplicationId $applicationId `
      -CertificateThumbprint $thumbprint 

    # Define POST body for call to get token
    $body = @{
      'resource' = $armRestUri
      'client_id' = $applicationId
      'grant_type' = 'client_credentials'
      'client_secret' = $applicationKey
      }

    # Define params necessary to get token for REST Method call
    $authContentType = 'application/x-www-form-urlencoded'
    $authHeaders = @{'accept'='application/json'}
    $authBody = $body
    $authMethod = 'POST'
    $authURI = $authEndPoint

    # Get token
    $token = Invoke-RestMethod -Uri $authURI -Method $authMethod -Body $authBody -Headers $authHeaders -ContentType $authContentType

    # using certificate, Get VM collection
    $vms = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Status
    $total = "Total VMs found: "
    $total += $vms.Count.ToString()
    Write-Output $total

    # Send REST API calls in parallel
    foreach -Parallel -throttlelimit 10 ($vm in $vms)
    {
        # Is there anything to do?
        if ($shutdown -and ($vm.PowerState -eq 'VM deallocated'))
        {
          Write-Output "Not shutting down $vm.Name.  VM already deallocated."
        }
        elseif (-not $Shutdown -and ($vm.PowerState -eq 'VM running'))
        {
          Write-Output "Not starting $vm.Name.  VM already running."
        }
        else
        {
            # Get VM Name
            $vmName = $vm.Name

            # construct URI for Azure ARM REST call based on whether we are shutting down or starting up
            if ($Shutdown)
            {
              $mgmtURI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/deallocate?api-version=2016-04-30-preview"
            }
            else
            {
              $mgmtURI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/start?api-version=2016-04-30-preview"  
            } 
          
            # define parameters - most importantly OAuth access token in the header
            $mgmtContentType = 'application/x-www-form-urlencoded'
            $mgmtHeaders = @{
              'authorization'="Bearer $($token.access_token)"
              }
            $mgmtMethod = 'POST'

            # make call
            $resp = Invoke-RestMethod -Uri $mgmtURI -Method $mgmtMethod -ContentType $mgmtContentType -Headers $mgmtHeaders
            $progress = "Processing: " 
            $progress += $vmName
            Write-Output $progress
          }

    }

    Get-Date

}


if ($shutdown)
{
    vmStateChange -resourceGroupName $resourceGroupName `
                  -subscriptionId $subscriptionId `
                  -certSubject $certSubject `
                  -applicationId $applicationId `
                  -tenantId $tenantId `
                  -applicationKey $applicationKey `
                  -shutdown
}
else 
{
    vmStateChange -resourceGroupName $resourceGroupName `
                  -subscriptionId $subscriptionId `
                  -certSubject $certSubject `
                  -applicationId $applicationId `
                  -tenantId $tenantId `
                  -applicationKey $applicationKey 
}

