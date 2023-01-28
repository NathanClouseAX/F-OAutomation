# Update these values for your situation
$authurl = "https://login.microsoftonline.com/{DOMAIN}/oauth2/v2.0/token"       
$clientId = 'f023fce0-5987-00d0-bb86-176fbd0c5ca9'
$username = '{USER@DOMAIN.COM}'
$password = '{PASSWORD}'
$LcsApiUri = "https://lcsapi.lcs.dynamics.com"
$ProjectId = '1234567890'
$SourceEnvironmentId = '098c0ad0-f897-2A80-80e0-91bffa01e181'
$BackupName = "UAT $(Get-Date -Format "MM-dd-yyyy")"

# Install Azure PowerShell
Install-Module -Name AZ -AllowClobber -Scope CurrentUser -Force -Confirm:$False -SkipPublisherCheck
write-host "Azure PowerShell installed"

# Install D365FO.Tools
Install-Module -Name d365fo.tools -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "D365FO.Tools installed"

# Install D365FO.Integrations
Install-Module -Name d365fo.integrations  -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "D365FO.Integrations installed"

Get-D365LcsApiToken -ClientId $ClientId -Username $Username -Password $Password -LcsApiUri $LcsApiUri -Verbose | Set-D365LcsApiConfig

Invoke-D365LcsDatabaseExport -ProjectId $ProjectId -SourceEnvironmentId $SourceEnvironmentId -BackupName $BackupName -LcsApiUri $LcsApiUri -Verbose
