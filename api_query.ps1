[CmdletBinding()]
Param(
  [String]$Fact = 'facts.kernel',
  [String]$Value = 'Linux',
  [String]$Query = 'inventory[certname,' + $Fact + '] { ' + $Fact + '="' + $Value + '" }',
  [String]$Server = (Get-Content -Path ".\\server"),
  [Int]$Port = 8081,
  [String]$APIEndpoint = "/pdb/query/v4",
  [String]$Token = (Get-Content -Path ".\\token"),
  [String]$Outfile
)

$Uri = "https://" + $Server + ":" + $Port + $APIEndpoint

try {
  $Response = Invoke-WebRequest -Uri $Uri -Headers @{ 'X-Authentication' = $Token }  -Method GET -Body @{query=$Query}
} catch {
  $_.Exception.Message
}

if ($Response) {
  $Response = $Response | ConvertFrom-Json | ConvertTo-Json -depth 100

  if ($Outfile) {
    Set-Content -Path $Outfile -Value $Response
  } else {
    Write-Host $Response
  }
}

































###########################################################################################
# Workaround used to allow non-trusted SSL certificate, similar to "curl -k"
# This is a workaround for demo purposes only, proper certificates should be used instead
class TrustAllCertsPolicy : System.Net.ICertificatePolicy { [bool] CheckValidationResult([System.Net.ServicePoint] $a,[System.Security.Cryptography.X509Certificates.X509Certificate] $b,[System.Net.WebRequest] $c,[int] $d) { return $true } }
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
###########################################################################################
