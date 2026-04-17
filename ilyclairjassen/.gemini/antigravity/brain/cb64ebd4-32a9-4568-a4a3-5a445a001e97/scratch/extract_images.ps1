$content = Get-Content -Raw "index.html"
$matches = [regex]::Matches($content, 'data:image/jpeg;base64,([^"]+)')

for ($i = 0; $i -lt $matches.Count; $i++) {
    $base64 = $matches[$i].Groups[1].Value
    $bytes = [System.Convert]::FromBase64String($base64)
    $filename = "public/assets/gallery-$($i + 1).jpg"
    [System.IO.File]::WriteAllBytes($filename, $bytes)
    Write-Host "Extracted $filename"
}
