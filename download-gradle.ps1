# PowerShell script to manually download Gradle distribution
# This is a fallback solution if the automatic download fails

$gradleVersion = "8.14.3"
$gradleUrl = "https://downloads.gradle.org/distributions/gradle-$gradleVersion-bin.zip"
$gradleHome = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-$gradleVersion-bin"
$zipFile = "$gradleHome\gradle-$gradleVersion-bin.zip"

Write-Host "Downloading Gradle $gradleVersion..." -ForegroundColor Green

# Create directory if it doesn't exist
if (!(Test-Path $gradleHome)) {
    New-Item -ItemType Directory -Path $gradleHome -Force
}

try {
    # Download with longer timeout
    $webClient = New-Object System.Net.WebClient
    $webClient.Timeout = 300000  # 5 minutes
    
    Write-Host "Downloading from: $gradleUrl" -ForegroundColor Yellow
    $webClient.DownloadFile($gradleUrl, $zipFile)
    
    Write-Host "Download completed successfully!" -ForegroundColor Green
    Write-Host "File saved to: $zipFile" -ForegroundColor Yellow
    
    # Extract the zip file
    Write-Host "Extracting Gradle..." -ForegroundColor Green
    Expand-Archive -Path $zipFile -DestinationPath $gradleHome -Force
    
    Write-Host "Gradle $gradleVersion is ready to use!" -ForegroundColor Green
    
} catch {
    Write-Host "Error downloading Gradle: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to:" -ForegroundColor Yellow
    Write-Host "1. Check your internet connection" -ForegroundColor Yellow
    Write-Host "2. Try using a VPN if you're behind a corporate firewall" -ForegroundColor Yellow
    Write-Host "3. Download manually from: $gradleUrl" -ForegroundColor Yellow
}

