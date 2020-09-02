[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
  [String]$Target,
  [String]$Server = (Get-Content -Path ".\\server"),
  [Int]$Port = 8081,
  [String]$APIEndpoint = "/pdb/query/v4",
  [String]$Token = (Get-Content -Path ".\\token")
)

$Uri = "https://" + $Server + ":" + $Port + $APIEndpoint

$Query = '["from", "catalogs",   ["=","certname", "' + $Target +'"],    ["order_by", [    ["catalog_uuid", "desc"]  ]],["limit", 1]]'

try {
  $Response = Invoke-WebRequest -Uri $Uri -Headers @{ 'X-Authentication' = $Token }  -Method GET -Body @{query=$Query}
} catch {
  $_.Exception.Message
}

if ($Response) {
  $Response = $Response | ConvertFrom-Json | ConvertTo-Json -depth 100
  Set-Content -Path ".\\${Target}.catalog.json" -Value $Response
}





































###########################################################################################
# Workaround used to allow non-trusted SSL certificate, similar to "curl -k"
# This is a workaround for demo purposes only, proper certificates should be used instead
class TrustAllCertsPolicy : System.Net.ICertificatePolicy { [bool] CheckValidationResult([System.Net.ServicePoint] $a,[System.Security.Cryptography.X509Certificates.X509Certificate] $b,[System.Net.WebRequest] $c,[int] $d) { return $true } }
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
###########################################################################################

