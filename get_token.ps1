[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [String]$Server, # Puppet Server with the RBAC endpoint (usually the Monolithic main Puppet server)
  [String]$APIEndpoint="/rbac-api/v1/auth/token",
  [Int]$Port=4433,
  [Parameter(Mandatory=$True)]
  [String]$Login,
  [Parameter(Mandatory=$True)]
  [Security.SecureString]$Password,
  [String]$Lifetime="1h",
  [String]$Label = "Token"
)

$Uri = "https://" + $Server + ":" + $Port + $APIEndpoint

## Helper function to work with secure input string
function ConvertFrom-SecureToPlain {
    param( [Parameter(Mandatory=$true)][System.Security.SecureString] $SecurePassword)
    $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
    $PlainTextPassword
}

## Form the request for the API call
$Body = @{ 
    "login"    = $Login; 
    "password" = ConvertFrom-SecureToPlain $Password;
    "lifetime" = $Lifetime;
    "label"    = $Label;

} | ConvertTo-Json

## Make the request
try {
  $Response = Invoke-WebRequest -Uri $uri -Headers @{ 'Content-Type' = "application/json"; }  -Method POST -Body $Body
} catch {
    $_.Exception.Message
}

## Deal with the response if we got one, and dump the token and 
## servername into local config files for use with other scripts
if ($Response) {
    $Token = ($Response | ConvertFrom-Json).token
    write-host "Token: ${Token}"
    Set-Content -Path ".\\token" -Value $Token
    Set-Content -Path ".\\server" -Value $Server
}


