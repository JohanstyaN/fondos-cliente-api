# Build Script - Builds and pushes Docker images to ECR

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "backend", "frontend", "status", "help")]
    [string]$Command = "help"
)

# Configuration
$global:STACK_NAME = "client-funds-stack"
$global:REGION = "us-east-1"
$global:ACCOUNT_ID = "259711294275"
$global:ECR_BASE = "$global:ACCOUNT_ID.dkr.ecr.$global:REGION.amazonaws.com"
$global:BACKEND_REPO = "client-funds-backend"
$global:FRONTEND_REPO = "client-funds-frontend"

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if AWS CLI is installed and configured
function Test-AwsCli {
    Write-Info "Checking AWS CLI configuration..."
    
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error "AWS CLI not found. Please install AWS CLI."
        exit 1
    }
    
    try {
        $null = aws sts get-caller-identity 2>$null
        Write-Success "AWS CLI is configured"
    }
    catch {
        Write-Error "AWS CLI not configured. Please run 'aws configure'."
        exit 1
    }
}

# Check if Docker is running
function Test-Docker {
    Write-Info "Checking Docker..."
    
    try {
        $null = docker info 2>$null
        Write-Success "Docker is running"
    }
    catch {
        Write-Error "Docker is not running. Please start Docker."
        exit 1
    }
}

# Create ECR repositories if they don't exist
function New-EcrRepositories {
    Write-Info "Creating ECR repositories..."
    
    foreach ($repo in @($global:BACKEND_REPO, $global:FRONTEND_REPO)) {
        Write-Info "Checking repository: $repo"
        
        $repoExists = aws ecr describe-repositories --repository-names $repo --region $global:REGION --query 'repositories[0].repositoryName' --output text 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $repoExists -eq $repo) {
            Write-Info "ECR repository already exists: $repo"
        } else {
            Write-Info "Creating ECR repository: $repo"
            $result = aws ecr create-repository --repository-name $repo --region $global:REGION
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Created ECR repository: $repo"
            } else {
                Write-Error "Failed to create ECR repository: $repo"
                exit 1
            }
        }
    }
}

# Login to ECR
function Connect-Ecr {
    Write-Info "Logging into ECR..."
    $loginToken = aws ecr get-login-password --region $global:REGION
    $loginToken | docker login --username AWS --password-stdin $global:ECR_BASE
    Write-Success "Logged into ECR"
}

# Build and push backend image
function Build-PushBackend {
    Write-Info "Building backend image..."
    
    $originalLocation = Get-Location
    $projectRoot = "f:\Github\fondos-cliente-api"
    Set-Location $projectRoot
    
    $backendRepo = $global:BACKEND_REPO
    $ecrBase = $global:ECR_BASE
    
    Write-Info "Building image: $backendRepo`:latest"
    Write-Info "Current directory: $(Get-Location)"
    docker build -t "$backendRepo`:latest" -f Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Backend build failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Info "Tagging image: $ecrBase/$backendRepo`:latest"
    docker tag "$backendRepo`:latest" "$ecrBase/$backendRepo`:latest"
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Backend tag failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Info "Pushing backend image to ECR..."
    docker push "$ecrBase/$backendRepo`:latest"
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Backend push failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Success "Backend image pushed successfully"
    Set-Location $originalLocation
}

# Build and push frontend image
function Build-PushFrontend {
    param(
        [string]$ApiUrl,
        [string]$Tag = "latest"
    )
    
    Write-Info "Building frontend image with API URL: $ApiUrl"
    
    $originalLocation = Get-Location
    $frontendDir = "f:\Github\fondos-cliente-api\frontend"
    Set-Location $frontendDir
    
    $frontendRepo = $global:FRONTEND_REPO
    $ecrBase = $global:ECR_BASE
    
    Write-Info "Building image: $frontendRepo`:$Tag"
    Write-Info "Current directory: $(Get-Location)"
    docker build --no-cache --build-arg REACT_APP_API_URL="$ApiUrl" -t "$frontendRepo`:$Tag" -f Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Frontend build failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Info "Tagging image: $ecrBase/$frontendRepo`:$Tag"
    docker tag "$frontendRepo`:$Tag" "$ecrBase/$frontendRepo`:$Tag"
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Frontend tag failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Info "Pushing frontend image to ECR..."
    docker push "$ecrBase/$frontendRepo`:$Tag"
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Frontend push failed"
        Set-Location $originalLocation
        exit 1 
    }
    
    Write-Success "Frontend image pushed successfully: $Tag"
    Set-Location $originalLocation
    return "$ecrBase/$frontendRepo`:$Tag"
}

# Get Load Balancer URL from stack outputs
function Get-LoadBalancerURL {
    try {
        $status = aws cloudformation describe-stacks --stack-name $global:STACK_NAME --region $global:REGION --query 'Stacks[0].StackStatus' --output text 2>$null
        if ($LASTEXITCODE -eq 0 -and $status -in @("CREATE_COMPLETE", "UPDATE_COMPLETE")) {
            $url = aws cloudformation describe-stacks `
                --stack-name $global:STACK_NAME `
                --region $global:REGION `
                --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' `
                --output text
            
            if ($url -and $url -ne "None") {
                Write-Success "Load Balancer URL: $url"
                return $url
            }
        }
    }
    catch {}
    
    Write-Warning "Could not get Load Balancer URL. Stack may not be deployed yet."
    return $null
}

function Show-Help {
    Write-Host "Build Script - Docker image builder for Client Funds Management"
    Write-Host ""
    Write-Host "Usage: .\build.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  all       Build and push both backend and frontend (default when stack exists)"
    Write-Host "  backend   Build and push only backend image"
    Write-Host "  frontend  Build and push only frontend image"
    Write-Host "  status    Show current Load Balancer URL"
    Write-Host "  help      Show this help message (default)"
    Write-Host ""
    Write-Host "WORKFLOW:"
    Write-Host "  1. .\build.ps1 all      # Build and push images"
    Write-Host "  2. .\deploy.ps1 all     # Deploy CloudFormation stack"
    Write-Host ""
}

# Main execution
switch ($Command) {
    "all" {
        Write-Info "Building and pushing all images..."
        Test-AwsCli
        Test-Docker
        New-EcrRepositories
        Connect-Ecr
        Build-PushBackend
        
        # Get Load Balancer URL if stack exists
        $loadBalancerUrl = Get-LoadBalancerURL
        if ($loadBalancerUrl) {
            Build-PushFrontend -ApiUrl $loadBalancerUrl -Tag "latest"
        } else {
            Write-Warning "Stack not found. Frontend will be built with placeholder URL."
            Build-PushFrontend -ApiUrl "http://placeholder.com" -Tag "latest"
        }
        Write-Success "All images built and pushed!"
    }
    "backend" {
        Write-Info "Building and pushing backend image..."
        Test-AwsCli
        Test-Docker
        New-EcrRepositories
        Connect-Ecr
        Build-PushBackend
    }
    "frontend" {
        Write-Info "Building and pushing frontend image..."
        Test-AwsCli
        Test-Docker
        New-EcrRepositories
        Connect-Ecr
        
        $loadBalancerUrl = Get-LoadBalancerURL
        if ($loadBalancerUrl) {
            Build-PushFrontend -ApiUrl $loadBalancerUrl -Tag "latest"
        } else {
            Write-Warning "Stack not found. Frontend will be built with placeholder URL."
            Build-PushFrontend -ApiUrl "http://placeholder.com" -Tag "latest"
        }
    }
    "status" {
        Test-AwsCli
        $url = Get-LoadBalancerURL
        if ($url) {
            Write-Host "Current Load Balancer URL: $url"
        } else {
            Write-Host "No Load Balancer URL available (stack may not be deployed)"
        }
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
