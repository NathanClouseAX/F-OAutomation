param 
(
    [Parameter(Mandatory = $true)] $tenantID,
    [Parameter(Mandatory = $true)] $resourceURI,
    [Parameter(Mandatory = $true)] $clientId,
    [Parameter(Mandatory = $true)] $clientSecret,
    [Parameter(Mandatory = $true)] $userFilePath
)

Write-Host $tenantID
Write-Host $resourceURI
Write-Host $clientId
Write-Host $userFilePath

if(!$tenantID -or !$resourceURI -or !$clientId)
{
    return
}

Install-PackageProvider nuget -Scope CurrentUser -Force -Confirm:$false
write-host "nuget installed"
  
Install-Module -Name AZ -AllowClobber -Scope CurrentUser -Force -Confirm:$False -SkipPublisherCheck
write-host "az installed"
  
Install-Module -Name d365fo.integrations  -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "d365fo.integrations installed"
  
Add-D365ODataConfig -Name "D365EnableUsers" -Tenant $tenantID -url $resourceURI -ClientId $clientId -ClientSecret $clientSecret -Force
write-host "Config added"
  
Set-D365ActiveODataConfig -Name D365EnableUsers 
write-host "Config as default"
 
$token = Get-D365ODataToken
write-host "Token generated"
 
$SystemUsers = Import-Csv -Path $userFilePath
 
$enablePayload = '{"Enabled": "true"}'
$createPayload = '{"UserID": ""}'

$filter = '$filter'
 
foreach ($user in $SystemUsers)
{
    $userID = $user.UserID
    #see if user exists
    $odataUser = Get-D365ODataEntityData -EntityName "SystemUsers" -ODataQuery "$filter=UserID eq '$UserID'" -Token $token

    #if not, create them
    if(! $odataUser)
    {
        $createUserPayload = '{"@odata.type" :"Microsoft.Dynamics.DataEntities.SystemUser","UserID": "' + $user.UserId + '", "UserName" : "' + $user.UserId + '", "Alias" : "' + $user.email + '", "NetworkDomain" : "' + $user.identityProvider +'", "Email" : "' + $user.email + '", "Company" : "DAT", "UserInfo_language" : "en-us", "Helplanguage" : "en-us", "ExternalUser" : "false", "AccountType":"ClaimsUser", "Enabled" : "true"}'

        Import-D365ODataEntity -EntityName "SystemUsers" -Payload $createUserPayload -Token $token
    }
    #if user exists, enable them, may be a pointless update if users already enabled
    else
    {
        $enablePayload = '{"Enabled": "true"}'
        $SystemUsersToUpdateNew = [PSCustomObject]@{Key = "UserID='$userId'"; Payload = $enablePayload}

        Update-D365ODataEntityBatchMode -EntityName "SystemUsers" -Payload $SystemUsersToUpdateNew -Token $token
    }
    #check if they need sysadmin
    $odataUserRole = Get-D365ODataEntityData -EntityName "SecurityUserRoles" -ODataQuery "$filter=UserId eq '$UserID' and SecurityRoleIdentifier eq '-SYSADMIN-'" -Token $token

    #if so, grant system admin
    if(! $odataUserRole)
    {
        $createRolePayload = '{"@odata.type" :"Microsoft.Dynamics.DataEntities.SecurityUserRoleAssociation","UserId": "' + $user.UserId + '", "SecurityRoleIdentifier" : "-SYSADMIN-", "AssignmentStatus" : "Enabled", "AssignmentMode" : "Manual", "SecurityRoleName" : "System administrator"}'

        Import-D365ODataEntity -EntityName "SecurityUserRoleAssociations" -Payload $createRolePayload -Token $token 
    }
}

