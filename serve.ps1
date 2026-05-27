$path = "c:\Users\mjros\OneDrive\Documents\GitHub\PokerRanges"
$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:8000/")
$http.Start()
Write-Host "Server started at http://localhost:8000/"
while ($http.IsListening) {
    $context = $http.GetContext()
    $request = $context.Request
    $response = $context.Response
    $localPath = $request.Url.LocalPath
    if ($localPath -eq "/") { $localPath = "/index.html" }
    $filePath = Join-Path $path $localPath.TrimStart('/')
    if (Test-Path $filePath -PathType Leaf) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $mimeType = switch ([IO.Path]::GetExtension($filePath)) {
            ".html" { "text/html" }
            ".css" { "text/css" }
            default { "text/plain" }
        }
        $response.ContentType = $mimeType
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } else {
        $response.StatusCode = 404
        $notFound = "404 Not Found"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFound)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    $response.OutputStream.Close()
}
$http.Stop()