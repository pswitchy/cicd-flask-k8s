# A simple script for Windows users to build the Docker image locally.

$imageName = "flask-app-local"
$imageTag = "latest"

Write-Host "Building Docker image: ${imageName}:${imageTag}" -ForegroundColor Green

try {
    docker build -t "${imageName}:${imageTag}" .
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host "To run the container, use: docker run -p 5000:5000 ${imageName}:${imageTag}"
}
catch {
    Write-Host "❌ Build failed." -ForegroundColor Red
    Write-Host $_
}