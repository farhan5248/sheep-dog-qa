@echo off
echo AWS Permissions Setup Guide for CloudFormation Deployment

REM Check if AWS CLI is installed
aws --version
if %ERRORLEVEL% neq 0 (
    echo AWS CLI is not installed. Please install it first.
    exit /b 1
)

REM Check if user is logged in to AWS
aws sts get-caller-identity
if %ERRORLEVEL% neq 0 (
    echo You are not logged in to AWS. Please run 'aws configure' first.
    exit /b 1
)

echo.
echo ========================================================================
echo IMPORTANT: You need administrator permissions to set up AWS permissions
echo ========================================================================
echo.
echo It appears you don't have sufficient permissions to create IAM policies.
echo Here are two options to resolve this issue:
echo.
echo OPTION 1: Ask your AWS administrator to grant you these permissions:
echo   - cloudformation:*
echo   - iam:PassRole
echo   - ec2:*
echo   - elasticloadbalancing:*
echo   - ecs:*
echo   - eks:*
echo   - ecr:*
echo   - logs:*
echo   - application-autoscaling:*
echo   - Specific VPC deletion permissions:
echo     - ec2:DeleteVpc
echo     - ec2:DeleteSubnet
echo     - ec2:DeleteRouteTable
echo     - ec2:DeleteNetworkAcl
echo     - ec2:DeleteSecurityGroup
echo     - ec2:DeleteInternetGateway
echo     - ec2:DetachInternetGateway
echo     - ec2:RevokeSecurityGroupIngress
echo     - ec2:RevokeSecurityGroupEgress
echo     - ec2:DescribeNetworkInterfaces
echo     - ec2:DetachNetworkInterface
echo     - ec2:DeleteNetworkInterface
echo     - ec2:DeleteVpcEndpoints
echo     - ec2:DescribeVpcEndpoints
echo     - ec2:DescribeDhcpOptions
echo     - ec2:DeleteDhcpOptions
echo     - ec2:DescribeVpcAttribute
echo     - ec2:ModifyVpcAttribute
echo   - Specific Load Balancer deletion permissions:
echo     - elasticloadbalancing:DeleteLoadBalancer
echo     - elasticloadbalancing:DeleteTargetGroup
echo     - elasticloadbalancing:DeleteListener
echo     - elasticloadbalancing:DeregisterTargets
echo     - elasticloadbalancing:DescribeLoadBalancers
echo     - elasticloadbalancing:DescribeTargetGroups
echo     - elasticloadbalancing:DescribeListeners
echo     - elasticloadbalancing:DescribeTargetHealth
echo     - elasticloadbalancing:ModifyLoadBalancerAttributes
echo     - elasticloadbalancing:RemoveListenerCertificates
echo     - elasticloadbalancing:RemoveTags
echo.
echo OPTION 2: Set up the permissions manually through the AWS Console:
echo   1. Log in to the AWS Management Console
echo   2. Go to IAM service
echo   3. Select your user
echo   4. Click "Add permissions" and choose "Attach policies directly"
echo   5. Search for and attach these AWS managed policies:
echo      - AmazonECS-FullAccess
echo      - AmazonEKSClusterPolicy
echo      - AmazonEKSServicePolicy
echo      - AmazonEKS_CNI_Policy
echo      - AmazonEC2ContainerRegistryFullAccess
echo      - CloudWatchLogsFullAccess
echo      - AmazonVPCFullAccess
echo      - AWSCloudFormationFullAccess
echo      - IAMFullAccess (or a more restricted policy with PassRole permissions)
echo.
echo OPTION 3: Use AWS CloudShell to deploy instead (if available in your region)
echo   1. Log in to the AWS Management Console
echo   2. Open CloudShell
echo   3. Upload your CloudFormation template and deployment scripts
echo   4. Run the deployment from CloudShell, which uses the console permissions
echo.
echo After setting up permissions, try running deploy-to-aws.bat again.
echo.
echo ========================================================================
echo.
echo Would you like to test if you have the necessary permissions now? (Y/N)
set /p TEST_PERMISSIONS=

if /i "%TEST_PERMISSIONS%"=="Y" (
    echo.
    echo Testing CloudFormation permissions...
    aws cloudformation list-stacks --max-items 1
    
    if %ERRORLEVEL% neq 0 (
        echo You still don't have CloudFormation permissions.
    ) else (
        echo CloudFormation permissions look good!
    )
    
    echo.
    echo Testing ECS permissions...
    aws ecs list-clusters --max-items 1
    
    if %ERRORLEVEL% neq 0 (
        echo You still don't have ECS permissions.
    ) else (
        echo ECS permissions look good!
    )
    
    echo.
    echo Testing EKS permissions...
    aws eks list-clusters --max-items 1
    
    if %ERRORLEVEL% neq 0 (
        echo You still don't have EKS permissions.
    ) else (
        echo EKS permissions look good!
    )
)

echo.
echo For more information, see the AWS documentation:
echo https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html
echo.
