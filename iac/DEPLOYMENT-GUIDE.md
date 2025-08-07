# Client Funds Management - Deployment Guide

## Two-Stage Deployment Process

### Stage 1: Build & Push Images
```powershell
.\build.ps1 all
```
This command:
- ✅ Checks AWS CLI and Docker
- ✅ Creates ECR repositories if needed
- ✅ Logs into ECR
- ✅ Builds backend Docker image
- ✅ Builds frontend Docker image (with current Load Balancer URL if available)
- ✅ Pushes both images to ECR

### Stage 2: Deploy CloudFormation Stack
```powershell
.\deploy.ps1 all
```
This command:
- ✅ Deploys CloudFormation stack using pre-built images
- ✅ Waits for stack completion
- ✅ Returns the Load Balancer URL

## Individual Commands

### Build Commands (build.ps1)
```powershell
.\build.ps1 all         # Build and push all images (default)
.\build.ps1 backend     # Build and push only backend
.\build.ps1 frontend    # Build and push only frontend
.\build.ps1 status      # Show Load Balancer URL
.\build.ps1 help        # Show help
```

### Deploy Commands (deploy.ps1)
```powershell
.\deploy.ps1 all        # Deploy and wait (default)
.\deploy.ps1 stack      # Deploy stack only
.\deploy.ps1 wait       # Wait for stack completion
.\deploy.ps1 url        # Get Load Balancer URL
.\deploy.ps1 status     # Show stack status
```

## Complete Deployment Example

```powershell
# Step 1: Build and push images
.\build.ps1 all

# Step 2: Deploy infrastructure
.\deploy.ps1 all

# Step 3: Load test data (optional) - use old script for now
.\deploy-old.ps1 load-data
```

## Current Status

- ✅ **Stack**: `CREATE_COMPLETE`
- ✅ **URL**: `http://client-funds-alb-23935731.us-east-1.elb.amazonaws.com`
- ✅ **Backend**: Deployed and running
- ✅ **Frontend**: Deployed (with placeholder URL)
- ✅ **DynamoDB**: Tables created and ready

## Next Steps

To complete the frontend with correct API URL:
1. Run `.\deploy.ps1 build` to rebuild frontend with correct URL
2. The stack will automatically use the updated image
