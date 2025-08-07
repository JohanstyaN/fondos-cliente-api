# Deploy Script - Deploys CloudFormation stack using pre-built images
# Use this after running: .\build.ps1 all
param(
    [string]$Step = "help"
)

# Configuration
$global:STACK_NAME = "client-funds-stack"
$global:REGION = "us-east-1"
$global:ACCOUNT_ID = "259711294275"
$global:ECR_BASE = "$global:ACCOUNT_ID.dkr.ecr.$global:REGION.amazonaws.com"
$global:BACKEND_REPO = "client-funds-backend"
$global:FRONTEND_REPO = "client-funds-frontend"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

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

function Deploy-StackOnly {
    param([string]$FrontendTag = "latest")
    
    $stackStatus = Get-StackStatus
    $backendImageUri = "$($global:ECR_BASE)/$($global:BACKEND_REPO):latest"
    $frontendImageUri = "$($global:ECR_BASE)/$($global:FRONTEND_REPO):$FrontendTag"
    
    $templatePath = "f:\Github\fondos-cliente-api\iac\template.yaml"
    
    # Create parameters file
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
    
    # Upload template to S3
    $bucketName = "client-funds-cf-templates-551203550"
    aws s3 cp $templatePath "s3://$bucketName/template.yaml"
    $templateUrl = "https://$bucketName.s3.$($global:REGION).amazonaws.com/template.yaml"
    
    if ($stackStatus -eq "DOES_NOT_EXIST") {
        Write-Info "Creating new stack: $global:STACK_NAME"
        Write-Info "Backend image: $backendImageUri"
        Write-Info "Frontend image: $frontendImageUri"
        
        Write-Info "Creating CloudFormation stack..."
        aws cloudformation create-stack `
            --stack-name $global:STACK_NAME `
            --template-url $templateUrl `
            --parameters "file://$paramsFile" `
            --capabilities CAPABILITY_NAMED_IAM `
            --region $global:REGION
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Stack creation initiated successfully"
        } else {
            Write-Error "Stack creation failed"
            Remove-Item $paramsFile -Force -ErrorAction SilentlyContinue
            return $false
        }
    } elseif ($stackStatus -eq "CREATE_COMPLETE" -or $stackStatus -eq "UPDATE_COMPLETE") {
        Write-Info "Stack exists. Updating with latest images..."
        Write-Info "Backend image: $backendImageUri"
        Write-Info "Frontend image: $frontendImageUri"
        
        Write-Info "Updating CloudFormation stack..."
        aws cloudformation update-stack `
            --stack-name $global:STACK_NAME `
            --template-url $templateUrl `
            --parameters "file://$paramsFile" `
            --capabilities CAPABILITY_NAMED_IAM `
            --region $global:REGION
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Stack update initiated successfully"
        } else {
            Write-Warning "No changes detected or update failed"
        }
    } else {
        Write-Info "Stack exists with status: $stackStatus"
    }
    
    Remove-Item $paramsFile -Force -ErrorAction SilentlyContinue
    return $true
}

function Wait-ForStackCreation {
    Write-Info "Waiting for stack operation to complete..."
    
    while ($true) {
        $status = Get-StackStatus
        Write-Host "Current status: $status"
        
        switch ($status) {
            "CREATE_COMPLETE" {
                Write-Success "Stack creation completed successfully"
                return $true
            }
            "UPDATE_COMPLETE" {
                Write-Success "Stack update completed successfully"
                return $true
            }
            "CREATE_FAILED" {
                Write-Error "Stack creation failed"
                return $false
            }
            "UPDATE_FAILED" {
                Write-Error "Stack update failed"
                return $false
            }
            "ROLLBACK_COMPLETE" {
                Write-Error "Stack creation failed and rolled back"
                return $false
            }
            "UPDATE_ROLLBACK_COMPLETE" {
                Write-Error "Stack update failed and rolled back"
                return $false
            }
            "CREATE_IN_PROGRESS" {
                Write-Host "." -NoNewline
                Start-Sleep 30
            }
            "UPDATE_IN_PROGRESS" {
                Write-Host "." -NoNewline
                Start-Sleep 30
            }
            "DOES_NOT_EXIST" {
                Write-Error "Stack does not exist"
                return $false
            }
            default {
                Write-Host "." -NoNewline
                Start-Sleep 30
            }
        }
    }
}

function Get-LoadBalancerURL {
    $stackStatus = Get-StackStatus
    
    if ($stackStatus -eq "CREATE_COMPLETE" -or $stackStatus -eq "UPDATE_COMPLETE") {
        Write-Info "Getting Load Balancer URL..."
        $url = aws cloudformation describe-stacks `
            --stack-name $global:STACK_NAME `
            --region $global:REGION `
            --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' `
            --output text
        
        if ($url -and $url -ne "None") {
            Write-Success "Load Balancer URL: $url"
            return $url
        } else {
            Write-Error "Could not retrieve Load Balancer URL"
            return $null
        }
    } else {
        Write-Error "Stack is not complete. Status: $stackStatus"
        return $null
    }
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

# Main execution
switch ($Step) {
    "stack" {
        Write-Info "Deploying/Updating CloudFormation stack..."
        if (Deploy-StackOnly) {
            Write-Success "Stack operation initiated"
        } else {
            Write-Error "Stack operation failed"
            exit 1
        }
    }
    "wait" {
        Write-Info "Waiting for stack completion..."
        if (Wait-ForStackCreation) {
            $url = Get-LoadBalancerURL
            if ($url) {
                Write-Success "Stack is ready! URL: $url"
            }
        }
    }
    "url" {
        $url = Get-LoadBalancerURL
        if ($url) {
            Write-Host $url
        }
    }
    "status" {
        $status = Get-StackStatus
        Write-Host "Stack status: $status"
    }
    "load-data" {
        Write-Info "Loading test data..."
        Load-TestData
    }
    "all" {
        Write-Info "Starting deployment/update process..."
        
        # Deploy or update stack
        if (Deploy-StackOnly) {
            Write-Info "Stack operation initiated, waiting for completion..."
            
            # Wait for completion
            if (Wait-ForStackCreation) {
                
                # Get URL
                $url = Get-LoadBalancerURL
                if ($url) {
                    Write-Success "Operation completed successfully!"
                    Write-Success "Application URL: $url"
                    
                    # If this was the first deployment and frontend was built with placeholder,
                    # rebuild frontend with correct URL and update again
                    $currentStatus = Get-StackStatus
                    if ($currentStatus -eq "CREATE_COMPLETE") {
                        Write-Info "Checking if frontend needs to be rebuilt with correct URL..."
                        
                        # Check if we need to rebuild frontend (this is hacky but works)
                        $needsRebuild = $true # For now, always rebuild after first create
                        
                        if ($needsRebuild) {
                            Write-Info "Rebuilding frontend with correct URL: $url"
                            
                            # Go to root directory and rebuild frontend
                            $currentDir = Get-Location
                            Set-Location "f:\Github\fondos-cliente-api"
                            
                            # Call build script for frontend only
                            & ".\iac\build.ps1" "frontend"
                            
                            # Return to iac directory
                            Set-Location $currentDir
                            
                            if ($LASTEXITCODE -eq 0) {
                                Write-Info "Frontend rebuilt successfully. Updating stack again..."
                                
                                # Update stack with new frontend image
                                if (Deploy-StackOnly) {
                                    if (Wait-ForStackCreation) {
                                        Write-Success "Final update completed! Frontend now has correct URL."
                                        Write-Success "Application URL: $url"
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Write-Error "Could not get application URL"
                    exit 1
                }
            } else {
                Write-Error "Stack operation failed"
                exit 1
            }
        } else {
            Write-Error "Stack operation failed"
            exit 1
        }
    }
    default {
        Write-Host "Deploy Script - CloudFormation stack deployment"
        Write-Host ""
        Write-Host "Usage: .\deploy.ps1 [COMMAND]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  stack     Deploy or update CloudFormation stack"
        Write-Host "  wait      Wait for stack completion"
        Write-Host "  url       Get Load Balancer URL"
        Write-Host "  status    Show stack status"
        Write-Host "  load-data Load test data into DynamoDB tables"
        Write-Host "  all       Complete deployment/update process (default)"
        Write-Host ""
        Write-Host "Pre-requisite: Run .\build.ps1 all first to build images"
        Write-Host "Note: 'all' command will auto-fix frontend URL on first deployment"
    }
}
