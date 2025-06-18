@echo off
echo %time%
echo Tearing down AWS CloudFormation stack

set SUFFIX=%1
set BASE_STACK_NAME=sheep-dog-aws
set REGION=us-east-1
set ACCOUNT_ID=013372624673

if "%SUFFIX%"=="" (
    echo Usage: aws-teardown-stack.bat [suffix]
    echo Example with suffix: aws-teardown-stack.bat 1
    exit /b 1
) else (
    set STACK_NAME=%BASE_STACK_NAME%-%SUFFIX%
)

echo Using stack name with suffix: %STACK_NAME%

echo Checking if AWS CLI is installed...
aws --version
if %ERRORLEVEL% neq 0 (
    echo AWS CLI is not installed. Please install it first.
    exit /b 1
)

echo Checking if you are logged in to AWS...
aws sts get-caller-identity
if %ERRORLEVEL% neq 0 (
    echo You are not logged in to AWS. Please run 'aws configure' first.
    exit /b 1
)

echo Are you sure you want to delete the CloudFormation stack %STACK_NAME%? (y/n)
set /p CONFIRM=
if /i "%CONFIRM%" neq "y" (
    echo Operation cancelled.
    exit /b 0
)

REM For EKS, we need to clean up Kubernetes resources first
echo Checking if kubectl is installed...
kubectl version --client
if %ERRORLEVEL% neq 0 (
    echo kubectl is not installed. Please install it first.
    exit /b 1
)

echo Getting EKS cluster name...
for /f "tokens=*" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='ClusterName'].OutputValue" --output text --region %REGION%') do set CLUSTER_NAME=%%i

if not "%CLUSTER_NAME%"=="" (
    echo Configuring kubectl to connect to the EKS cluster...
    aws eks update-kubeconfig --name %CLUSTER_NAME% --region %REGION%

    echo Checking for lingering load balancers...
    aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, '%STACK_NAME%')].LoadBalancerName" --output text
    if %ERRORLEVEL% neq 0 (
        echo WARNING: Found lingering load balancers that may prevent VPC deletion.
        echo You may need to delete these manually before proceeding.
        exit /b 0
    )
)


REM Set these variables as needed
set ROLE_NAME=EBSCSIDriverRole

echo Deleting EBS policies...

REM Detach the policy from the role
aws iam detach-role-policy --role-name %ROLE_NAME% --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

REM Delete the IAM role
aws iam delete-role --role-name %ROLE_NAME%

REM Get the OIDC URL from the EKS cluster
for /f "delims=" %%i in ('aws eks describe-cluster --name %CLUSTER_NAME% --query "cluster.identity.oidc.issuer" --output text') do set OIDC_URL=%%i

REM Check if OIDC_URL is empty
if "%OIDC_URL%"=="" (
    echo Failed to get OIDC URL from EKS Cluster.
    exit /b 1
)

echo Deleting OIDC provider...

REM Extract the OIDC provider ID (the last part after the last slash)
for %%A in ("%OIDC_URL%") do set "OIDC_PROVIDER_ID=%%~nxA"

aws iam delete-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::%ACCOUNT_ID%:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/%OIDC_PROVIDER_ID%

if %ERRORLEVEL% neq 0 (
    echo Failed to delete OIDC provider.
    exit /b 1
) 

echo Deleting CloudFormation stack...
aws cloudformation delete-stack --stack-name %STACK_NAME% --region %REGION%

echo Waiting for stack deletion to complete...
aws cloudformation wait stack-delete-complete --stack-name %STACK_NAME% --region %REGION%

if %ERRORLEVEL% neq 0 (
    echo Failed to delete CloudFormation stack.
    exit /b 1
) else (
    echo CloudFormation stack deleted successfully!
)

echo %time%
