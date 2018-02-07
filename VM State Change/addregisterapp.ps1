
param (
    [parameter (Mandatory=$true)] [string] $subscriptionName,
    [parameter (Mandatory=$true)] [string] $resourceGroup,
    [parameter (Mandatory=$true)] [string] $applicationDisplayName,
    [parameter (Mandatory=$true)] [string] $certSubject
)

# get certificate
$certificate = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match $certSubject})

# login
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionName

$keyValue = [System.Convert]::ToBase64String($certificate.GetRawCertData())
$scope = (Get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction Stop).ResourceId

 # Use Key credentials
 $application = New-AzureRmADApplication -DisplayName $applicationDisplayName -HomePage ("http://" + $applicationDisplayName) -IdentifierUris ("http://" + $applicationDisplayName) -CertValue $keyValue -EndDate $certificate.NotAfter -StartDate $certificate.NotBefore

 $servicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $application.ApplicationId 
 Get-AzureRmADServicePrincipal -ObjectId $servicePrincipal.Id 

 $newRole = $null
 $retries = 0;
 While ($newROle -eq $null -and $retries -le 6)
 {
    # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
    Start-Sleep -Seconds 15
    New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $application.ApplicationId -Scope $scope | Write-Verbose -ErrorAction SilentlyContinue
    $newRole = Get-AzureRMRoleAssignment -ServicePrincipalName $application.ApplicationId -ErrorAction SilentlyContinue
    $retries++;
 }