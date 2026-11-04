param(
    [Parameter(Mandatory=$true)][string]$Origin,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$OutboundDate,
    [string]$ReturnDate = "",
    [int]$MaxDurationMinutes = 900,
    [int]$Stops = 2,
    [int]$TravelClass = 1,
    [string]$Currency = "BRL",
    [string]$Gl = "br"
)

$ErrorActionPreference = 'Stop'

# Load SERPAPI_API_KEY from .env if not in environment
$envFile = Join-Path (Split-Path -Parent $PSScriptRoot) ".env"
$apiKey = $env:SERPAPI_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey) -and (Test-Path $envFile)) {
    foreach ($line in Get-Content $envFile) {
        if ($line -match '^\s*SERPAPI_API_KEY\s*=\s*(.+?)\s*$') {
            $apiKey = $Matches[1].Trim('"').Trim("'")
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Error "SERPAPI_API_KEY não encontrada em $envFile nem nas variáveis de ambiente."
    exit 1
}

$type = if ([string]::IsNullOrWhiteSpace($ReturnDate)) { 2 } else { 1 }
$url = "https://serpapi.com/search.json?engine=google_flights&departure_id=$Origin&arrival_id=$Destination&outbound_date=$OutboundDate&type=$type&travel_class=$TravelClass&stops=$Stops&max_duration=$MaxDurationMinutes&currency=$Currency&gl=$Gl&hl=pt-br&sort_by=2&api_key=$apiKey"
if ($type -eq 1) {
    $url += "&return_date=$ReturnDate"
}

$resp = Invoke-RestMethod -Uri $url -Method Get
$resp | ConvertTo-Json -Depth 10
