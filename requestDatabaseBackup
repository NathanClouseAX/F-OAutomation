# Update these values for your situation
$authurl = "https://login.microsoftonline.com/{DOMAIN}/oauth2/v2.0/token"       
$clientId = 'f023fce0-5987-00d0-bb86-176fbd0c5ca9'
$username = '{USER@DOMAIN.COM}'
$password = '{PASSWORD}'
$LcsApiUri = "https://lcsapi.lcs.dynamics.com"
$ProjectId = '1234567890'
$SourceEnvironmentId = '098c0ad0-f897-2A80-80e0-91bffa01e181'
$BackupName = "UAT $(Get-Date -Format "MM-dd-yyyy")"

# Set the request method to POST
$method = "POST"

# Set the grant type to password
$grantType = "password"

# Set the scope
$scope = "https://lcsapi.lcs.dynamics.com//.default"

# Set the request body with the client ID, scope, username, password, and grant type
$requestBody = "client_id=$clientId&scope=$scope&username=$username&password=$password&grant_type=$grantType"

# Set the content type and accept headers
$headers = @{
  "Content-Type" = "application/x-www-form-urlencoded"
  "Accept" = "application/json"
}


# Send the request and get the response
$response = Invoke-WebRequest -Uri $authurl -Method $method -Body $requestBody -Headers $headers

#$tokenResponse = Invoke-WebRequest -Uri "https://login.microsoftonline.com/atomicax.com/oauth2/v2.0/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body "client_id=f423fce0-5987-44d4-bb86-176fbd0c5ca9&scope=https://lcsapi.lcs.dynamics.com//.default&username=testasdf@atomicax.com&password=Coldsteel_55!!&grant_type=password" -verbose
$tokenResponseJSON = ConvertFrom-Json $response.Content
$token = $tokenResponseJSON.access_token 


# Install Azure PowerShell
Install-Module -Name AZ -AllowClobber -Scope CurrentUser -Force -Confirm:$False -SkipPublisherCheck
write-host "Azure PowerShell installed"

# Install D365FO.Tools
Install-Module -Name d365fo.tools -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "D365FO.Tools installed"

# Install D365FO.Integrations
Install-Module -Name d365fo.integrations  -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "D365FO.Integrations installed"

# This doesn't work, not sure why
#$token = Get-D365LcsApiToken -ClientId $ClientId -Username $Username -Password $Password -LcsApiUri $LcsApiUri -Verbose

Invoke-D365LcsDatabaseExport -ProjectId $ProjectId -SourceEnvironmentId $SourceEnvironmentId -BackupName $BackupName -BearerToken $token -LcsApiUri $LcsApiUri -Verbose
