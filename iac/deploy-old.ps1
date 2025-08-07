# Client Funds Management System - PowerShell Deployment Script
# This script builds, pushes images and deploys/updates the CloudFormation stack

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy", "build", "delete", "status", "events", "load-data", "help")]
    [string]$Command = "help"
)

# Configuration
$global:STACK_NAME = "client-funds-stack"
$global:REGION = "us-east-1"
$global:ACCOUNT_ID = "259711294275"
$global:ECR_BASE = "$global:ACCOUNT_ID.dkr.ecr.$global:REGION.amazonaws.com"
$global:BACKEND_REPO = "client-funds-backend"
$global:FRONTEND_REPO = "client-funds-frontend"
$global:TEMPLATE_FILE = "template.yaml"

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

# Check stack status
function Get-StackStatus {
    try {
        $status = aws cloudformation describe-stacks --stack-name $global:STACK_NAME --region $global:REGION --query 'Stacks[0].StackStatus' --output text 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $status
        } else {
            return "DOES_NOT_EXIST"
        }
    }
    catch {
        return "DOES_NOT_EXIST"
    }
}

# Wait for stack operation to complete
function Wait-ForStack {
    param([string]$Operation)
    
    Write-Info "Waiting for stack $Operation to complete..."
    
    while ($true) {
        $status = Get-StackStatus
        
        switch ($status) {
            { $_ -in @("CREATE_COMPLETE", "UPDATE_COMPLETE") } {
                Write-Success "Stack $Operation completed successfully"
                return $true
            }
            { $_ -in @("CREATE_FAILED", "UPDATE_FAILED", "ROLLBACK_COMPLETE", "UPDATE_ROLLBACK_COMPLETE") } {
                Write-Error "Stack $Operation failed with status: $status"
                return $false
            }
            { $_ -in @("CREATE_IN_PROGRESS", "UPDATE_IN_PROGRESS", "ROLLBACK_IN_PROGRESS", "UPDATE_ROLLBACK_IN_PROGRESS") } {
                Write-Host "." -NoNewline
                Start-Sleep 30
            }
            "DOES_NOT_EXIST" {
                if ($Operation -eq "delete") {
                    Write-Success "Stack deleted successfully"
                    return $true
                } else {
                    Write-Error "Stack does not exist"
                    return $false
                }
            }
            default {
                Write-Host "." -NoNewline
                Start-Sleep 30
            }
        }
    }
}

# Create or update stack
function Deploy-Stack {
    param([string]$FrontendImageUri = $null)
    
    $stackStatus = Get-StackStatus
    $backendImageUri = "$($global:ECR_BASE)/$($global:BACKEND_REPO):latest"
    
    # Use provided frontend URI or default to latest
    if (-not $FrontendImageUri) {
        $frontendImageUri = "$($global:ECR_BASE)/$($global:FRONTEND_REPO):latest"
    } else {
        $frontendImageUri = $FrontendImageUri
    }
    
    # Use absolute path to template.yaml
    $templatePath = "f:\Github\fondos-cliente-api\iac\template.yaml"
    
    if (-not (Test-Path $templatePath)) {
        Write-Error "Template file not found: $templatePath"
        return $false
    }
    
    if ($stackStatus -eq "DOES_NOT_EXIST") {
        Write-Info "Creating new stack: $global:STACK_NAME"
        Write-Info "Using template: $templatePath"
        Write-Info "Backend image: $backendImageUri"
        Write-Info "Frontend image: $frontendImageUri"
        
        # Create parameters file to avoid command line length issues
        $paramsFile = "stack-params.json"
        $params = @(
            @{
                ParameterKey = "BackendImageUri"
                ParameterValue = $backendImageUri
            },
            @{
                ParameterKey = "FrontendImageUri"
                ParameterValue = $frontendImageUri
            }
        )
        $params | ConvertTo-Json -Depth 3 | Out-File $paramsFile -Encoding ASCII
        
        # Upload template to S3 for deployment
        $bucketName = "client-funds-cf-templates-551203550"
        aws s3 cp $templatePath "s3://$bucketName/template.yaml"
        $templateUrl = "https://$bucketName.s3.$($global:REGION).amazonaws.com/template.yaml"
        
        aws cloudformation create-stack `
            --stack-name $global:STACK_NAME `
            --template-url $templateUrl `
            --parameters "file://$paramsFile" `
            --capabilities CAPABILITY_NAMED_IAM `
            --region $global:REGION
        
        # Cleanup params file
        Remove-Item $paramsFile -Force -ErrorAction SilentlyContinue
        $result = Wait-ForStack "creation"
    } else {
        Write-Info "Updating existing stack: $global:STACK_NAME"
        Write-Info "Using template: $templatePath"
        Write-Info "Backend image: $backendImageUri"
        Write-Info "Frontend image: $frontendImageUri"
        
        try {
        # Create parameters file to avoid command line length issues
        $paramsFile = "stack-params.json"
        $params = @(
            @{
                ParameterKey = "BackendImageUri"
                ParameterValue = $backendImageUri
            },
            @{
                ParameterKey = "FrontendImageUri"
                ParameterValue = $frontendImageUri
            }
        )
        $params | ConvertTo-Json -Depth 3 | Out-File $paramsFile -Encoding ASCII
        
        # Upload template to S3 for deployment
        $bucketName = "client-funds-cf-templates-551203550"
        aws s3 cp $templatePath "s3://$bucketName/template.yaml"
        $templateUrl = "https://$bucketName.s3.$($global:REGION).amazonaws.com/template.yaml"
        
        aws cloudformation update-stack `
                --stack-name $global:STACK_NAME `
                --template-url $templateUrl `
                --parameters "file://$paramsFile" `
                --capabilities CAPABILITY_NAMED_IAM `
                --region $global:REGION
            
        # Cleanup params file
        Remove-Item $paramsFile -Force -ErrorAction SilentlyContinue
            $result = Wait-ForStack "update"
        }
        catch {
            if ($_.Exception.Message -like "*No updates are to be performed*") {
                Write-Info "No updates needed for the stack"
                $result = $true
            } else {
                throw
            }
        }
    }
    
    return $result
}

# Delete stack
function Remove-Stack {
    $stackStatus = Get-StackStatus
    
    if ($stackStatus -ne "DOES_NOT_EXIST") {
        Write-Warning "Deleting stack: $STACK_NAME"
        $confirmation = Read-Host "Are you sure you want to delete the stack? (y/N)"
        if ($confirmation -eq "y" -or $confirmation -eq "Y") {
            aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
            Wait-ForStack "delete"
        } else {
            Write-Info "Stack deletion cancelled"
        }
    } else {
        Write-Warning "Stack does not exist: $STACK_NAME"
    }
}

# Get Load Balancer URL from stack outputs
function Get-LoadBalancerURL {
    $stackStatus = Get-StackStatus
    
    if ($stackStatus -in @("CREATE_COMPLETE", "UPDATE_COMPLETE")) {
        Write-Info "Getting Load Balancer URL from stack outputs..."
        $url = aws cloudformation describe-stacks `
            --stack-name $global:STACK_NAME `
            --region $global:REGION `
            --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' `
            --output text
        
        if ($url -and $url -ne "None") {
            Write-Success "Load Balancer URL: $url"
            return $url
        } else {
            Write-Error "Could not retrieve Load Balancer URL from stack outputs"
            return $null
        }
    } else {
        Write-Error "Stack is not in a complete state: $stackStatus"
        return $null
    }
}

# Get stack outputs
function Get-StackOutputs {
    $stackStatus = Get-StackStatus
    
    if ($stackStatus -in @("CREATE_COMPLETE", "UPDATE_COMPLETE")) {
        Write-Info "Stack outputs:"
        aws cloudformation describe-stacks `
            --stack-name $STACK_NAME `
            --region $REGION `
            --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' `
            --output table
    } else {
        Write-Warning "Stack is not in a complete state: $stackStatus"
    }
}

# View stack events
function Get-StackEvents {
    Write-Info "Recent stack events:"
    aws cloudformation describe-stack-events `
        --stack-name $STACK_NAME `
        --region $REGION `
        --query 'StackEvents[0:10].[Timestamp,LogicalResourceId,ResourceStatus,ResourceStatusReason]' `
        --output table
}

# Load test data into DynamoDB tables
function Load-TestData {
    Write-Info 'Loading test data into DynamoDB tables...'
    
    $data = Get-Content "data.json" | ConvertFrom-Json
    
    # Load clients
    foreach ($client in $data.clients) {
        $tempFile = "temp-client.json"
        $client | ConvertTo-Json -Depth 5 | Out-File $tempFile -Encoding ASCII
        
        aws dynamodb put-item --table-name "Clients" --item file://$tempFile --region us-east-1
        if ($LASTEXITCODE -eq 0) { 
            Write-Success "Client $($client.user_id.S) loaded" 
        } else { 
            Write-Warning "Client $($client.user_id.S) failed" 
        }
        
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
    
    # Load funds
    foreach ($fund in $data.funds) {
        $tempFile = "temp-fund.json"
        $fund | ConvertTo-Json -Depth 5 | Out-File $tempFile -Encoding ASCII
        
        aws dynamodb put-item --table-name "Funds" --item file://$tempFile --region us-east-1
        if ($LASTEXITCODE -eq 0) { 
            Write-Success "Fund $($fund.id_fund.S) loaded" 
        } else { 
            Write-Warning "Fund $($fund.id_fund.S) failed" 
        }
        
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
    
    Write-Success 'Test data loading completed!'
}

function Show-Help {
    Write-Host "Client Funds Management System - PowerShell Deployment Script"
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  build     Build and push Docker images to ECR (RECOMMENDED)"
    Write-Host "  deploy    Build images and deploy/update stack (may hang - use build instead)"
    Write-Host "  delete    Delete the CloudFormation stack"
    Write-Host "  status    Show stack status and outputs"
    Write-Host "  events    Show recent stack events"
    Write-Host "  load-data Load test data into DynamoDB tables"
    Write-Host "  help      Show this help message (default)"
    Write-Host ""
    Write-Host "RECOMMENDED WORKFLOW:"
    Write-Host "  1. .\deploy.ps1 build        # Build and push images"
    Write-Host "  2. .\stack-deploy.ps1 all    # Deploy CloudFormation stack"
    Write-Host "  3. .\deploy.ps1 load-data    # Load test data (optional)"
    Write-Host ""
}

# Main execution
switch ($Command) {
    "deploy" {
        Write-Warning "NOTICE: This command may hang during execution!"
        Write-Warning "For more reliable deployment, use:"
        Write-Warning "  1. .\deploy.ps1 build"
        Write-Warning "  2. .\stack-deploy.ps1 all"
        Write-Warning ""
        $continue = Read-Host "Continue with full deploy anyway? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Info "Deployment cancelled. Use the recommended workflow above."
            exit 0
        }
        
        Write-Info "Starting full deployment..."
        Test-AwsCli
        Test-Docker
        New-EcrRepositories
        Connect-Ecr
        Build-PushBackend
        
        # Generate unique timestamp for frontend image tag
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $placeholderTag = "placeholder-$timestamp"
        $finalTag = "final-$timestamp"
        
        # Build frontend with placeholder URL first
        Write-Info "Building frontend with placeholder URL..."
        $placeholderImageUri = Build-PushFrontend -ApiUrl "http://placeholder.com" -Tag $placeholderTag
        
        # Deploy stack with placeholder frontend
        if (Deploy-Stack -FrontendImageUri $placeholderImageUri) {
            # Get the Load Balancer URL
            $loadBalancerUrl = Get-LoadBalancerURL
            if ($loadBalancerUrl) {
                # Build frontend with correct URL and new tag
                Write-Info "Building frontend with correct URL: $loadBalancerUrl"
                $finalImageUri = Build-PushFrontend -ApiUrl $loadBalancerUrl -Tag $finalTag
                
                # Update stack with correct frontend (CloudFormation will detect the change due to different tag)
                Write-Info "Updating stack with corrected frontend..."
                if (Deploy-Stack -FrontendImageUri $finalImageUri) {
                    Get-StackOutputs
                    Write-Success "Deployment completed!"
                    
                    # Load test data after successful deployment
                    Write-Info "Loading test data..."
                    Load-TestData
                } else {
                    Write-Error "Frontend update failed!"
                    Get-StackEvents
                    exit 1
                }
            } else {
                Write-Error "Could not get Load Balancer URL!"
                exit 1
            }
        } else {
            Write-Error "Initial deployment failed!"
            Get-StackEvents
            exit 1
        }
    }
    "build" {
        Write-Info "Building and pushing images..."
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
            Write-Warning "Stack not found or not complete. Frontend will be built without API URL."
            Build-PushFrontend -ApiUrl "" -Tag "latest"
        }
        Write-Success "Images built and pushed!"
    }
    "delete" {
        Test-AwsCli
        Remove-Stack
    }
    "status" {
        Test-AwsCli
        Get-StackOutputs
    }
    "events" {
        Test-AwsCli
        Get-StackEvents
    }
    "load-data" {
        Write-Info "Loading test data..."
        Test-AwsCli
        Load-TestData
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
