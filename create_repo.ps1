# Create GitHub repository using PowerShell
$token = "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"
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github.v3+json"
}

$body = @{
    name = "green-commits"
    private = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Repository created successfully: $($response.html_url)"
    
    # Now push to the repository
    git push -u origin master
} catch {
    Write-Host "Error creating repository: $_"
}
