# Cleanup script for Client Funds API
# This script removes all AWS resources for the project

param(
    [switch]$Force
)

$STACK_NAME = "client-funds-stack"
$REGION = "us-east-1"

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

# Confirm deletion unless -Force is used
if (-not $Force) {
    Write-Warning "This will delete ALL AWS resources for the Client Funds API project."
    Write-Warning "Stack: $STACK_NAME"
    Write-Warning "Region: $REGION"
    $confirmation = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Info "Cleanup cancelled."
        exit 0
    }
}

Write-Info "Starting cleanup of Client Funds API resources..."

# Delete CloudFormation stack
Write-Info "Deleting CloudFormation stack: $STACK_NAME"
try {
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Stack deletion initiated successfully"
        
        # Wait for stack deletion to complete
        Write-Info "Waiting for stack deletion to complete..."
        aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Stack deleted successfully"
        } else {
            Write-Error "Stack deletion timed out or failed"
        }
    } else {
        Write-Error "Failed to initiate stack deletion"
    }
} catch {
    Write-Error "Error deleting stack: $_"
}

# Clean up ECR repositories
Write-Info "Cleaning up ECR repositories..."
$repos = @("client-funds-backend", "client-funds-frontend")
foreach ($repo in $repos) {
    try {
        Write-Info "Deleting ECR repository: $repo"
        aws ecr delete-repository --repository-name $repo --region $REGION --force 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "ECR repository $repo deleted"
        } else {
            Write-Warning "ECR repository $repo not found or already deleted"
        }
    } catch {
        Write-Warning "Could not delete ECR repository $repo"
    }
}

Write-Success "Cleanup completed!"
Write-Info "All Client Funds API resources have been removed from AWS."
