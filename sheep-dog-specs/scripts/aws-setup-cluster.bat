@echo off
echo %time%
echo Updating EKS cluster with new Docker image or Kubernetes configuration changes

set SUFFIX=%1
set BASE_STACK_NAME=sheep-dog-aws
set REGION=us-east-1
set NAMESPACE=prod

if "%SUFFIX%"=="" (
    echo Usage: aws-setup-stack.bat [suffix]
    echo Example with suffix: aws-setup-stack.bat 1
    exit /b 1
) else (
    set STACK_NAME=%BASE_STACK_NAME%-%SUFFIX%
)

echo Checking if AWS CLI is installed...
aws --version
if %ERRORLEVEL% neq 0 (
    echo AWS CLI is not installed. Please install it first.
    exit /b 1
)

echo Checking if kubectl is installed...
kubectl version --client
if %ERRORLEVEL% neq 0 (
    echo kubectl is not installed. Please install it first.
    exit /b 1
)

echo Checking if kustomize is installed...
kubectl kustomize --help > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Kustomize functionality is not available. It should be included with kubectl v1.14+.
    echo If you're using an older version, please install kustomize separately.
    exit /b 1
)

echo Checking if you are logged in to AWS...
aws sts get-caller-identity
if %ERRORLEVEL% neq 0 (
    echo You are not logged in to AWS. Please run 'aws configure' first.
    exit /b 1
)

echo Getting EKS cluster name from CloudFormation stack...
for /f "tokens=*" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='ClusterName'].OutputValue" --output text --region %REGION%') do set CLUSTER_NAME=%%i

if "%CLUSTER_NAME%"=="" (
    echo Failed to get EKS cluster name from CloudFormation stack.
    echo Make sure the stack %STACK_NAME% exists and has been deployed using deploy-to-eks.bat.
    exit /b 1
)

echo Configuring kubectl to connect to the EKS cluster %CLUSTER_NAME%...
aws eks update-kubeconfig --name %CLUSTER_NAME% --region %REGION%

if %ERRORLEVEL% neq 0 (
    echo Failed to configure kubectl.
    exit /b 1
)

echo Updating Kubernetes configuration...
echo Creating namespace if it doesn't exist...
kubectl create namespace %NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -

echo Applying Kustomize overlay...
cd ..
kubectl apply -k kubernetes/overlays/%NAMESPACE%/

if %ERRORLEVEL% neq 0 (
    echo Failed to apply Kubernetes configuration.
    exit /b 1
)
cd scripts

echo Restarting deployment to pull the latest image...
kubectl rollout restart deployment sheep-dog-dev-svc -n %NAMESPACE%

echo Waiting for rollout to complete...
kubectl rollout status deployment sheep-dog-dev-svc -n %NAMESPACE%

if %ERRORLEVEL% neq 0 (
    echo Deployment rollout failed.
    exit /b 1
)

echo Waiting for service to get an external IP...
echo This may take a few minutes...
timeout /t 30

echo Getting service URL...
kubectl get service -n %NAMESPACE% sheep-dog-dev-svc -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
echo.

echo Getting Ingress URL...
kubectl get ingress -n %NAMESPACE% sheep-dog-dev-ingress -o jsonpath="{.spec.rules[0].host}"
echo.

echo EKS cluster update completed successfully!

echo %time%
