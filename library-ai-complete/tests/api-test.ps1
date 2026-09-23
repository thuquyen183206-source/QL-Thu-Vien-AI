$ErrorActionPreference = 'Stop'
$base = if ($env:API_URL) { $env:API_URL.TrimEnd('/') } else { 'http://localhost:8000/api' }

function Call-Api([string]$Path, [string]$Method = 'GET', $Body = $null, [hashtable]$Headers = @{}) {
    $params = @{ Uri = "$base$Path"; Method = $Method; Headers = $Headers; ErrorAction = 'Stop' }
    if ($null -ne $Body) {
        $params.ContentType = 'application/json'
        $params.Body = ($Body | ConvertTo-Json -Compress)
    }
    try {
        $response = Invoke-WebRequest @params
        $status = [int]$response.StatusCode
        $content = $response.Content
    } catch {
        $response = $_.Exception.Response
        if ($null -eq $response) { throw }
        $status = [int]$response.StatusCode
        $content = (New-Object IO.StreamReader($response.GetResponseStream())).ReadToEnd()
    }
    $json = $null
    if ($content) { $json = $content | ConvertFrom-Json }
    return [pscustomobject]@{ Status = $status; Json = $json }
}

function Assert-Status($Response, [int]$Expected, [string]$Name) {
    if ($Response.Status -ne $Expected) { throw "${Name}: expected $Expected, got $($Response.Status)" }
    Write-Host "PASS $Name ($Expected)"
}

Assert-Status (Call-Api '/health') 200 'health'
$login = Call-Api '/login' 'POST' @{ email = 'thuthu@library.local'; password = 'ThuThu@123' }
Assert-Status $login 200 'librarian login'
$headers = @{ Authorization = "Bearer $($login.Json.token)" }
Assert-Status (Call-Api '/stats' 'GET' $null $headers) 200 'stats'
Assert-Status (Call-Api '/books?q=Clean&status=available' 'GET' $null $headers) 200 'book search/filter'
Assert-Status (Call-Api '/books' 'POST' @{ title = ''; author = 'Test'; category = 'Test'; year = 2026; quantity = 1 } $headers) 422 'book validation'
$ai = Call-Api '/ai' 'POST' @{ prompt = 'recommend books' } $headers
Assert-Status $ai 200 'AI local/model response'
if ([string]::IsNullOrWhiteSpace($ai.Json.answer)) { throw 'AI response must contain answer' }
if (@($ai.Json.sources).Count -lt 1) { throw 'AI response must contain at least one allowed source' }
Write-Host 'PASS AI response schema'
Assert-Status (Call-Api '/ai' 'POST' @{ prompt = '' } $headers) 422 'AI empty prompt validation'
$longPrompt = ('x' * 12001) -join ''
Assert-Status (Call-Api '/ai' 'POST' @{ prompt = $longPrompt } $headers) 422 'AI prompt length limit'
Assert-Status (Call-Api '/ai' 'POST' @{ prompt = 'test' }) 401 'unauthenticated AI access'

$readerLogin = Call-Api '/login' 'POST' @{ email = 'docgia@library.local'; password = 'DocGia@123' }
Assert-Status $readerLogin 200 'reader login'
$readerHeaders = @{ Authorization = "Bearer $($readerLogin.Json.token)" }
Assert-Status (Call-Api '/books' 'POST' @{ title = 'Forbidden'; author = 'Test'; category = 'Test'; year = 2026; quantity = 1 } $readerHeaders) 403 'reader management authorization'
Assert-Status (Call-Api '/ai' 'POST' @{ prompt = 'recommend books' } $readerHeaders) 200 'reader AI access'
$readerLoans = Call-Api '/loans' 'GET' $null $readerHeaders
Assert-Status $readerLoans 200 'reader loan access'
if (($readerLoans.Json | Where-Object { $_.reader -ne 'Nguyễn Minh Anh' }).Count -gt 0) { throw 'reader can only see own loans' }
Write-Host 'PASS reader loan isolation'
Assert-Status (Call-Api '/me') 401 'unauthenticated access'
Write-Host 'All API tests passed.'
