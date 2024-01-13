# Deploy a managed AWS EKS cluster using Terraform

**Hashicorp's Terraform** is an industry best practice tool to deploy any infrastructure stack on any Public Cloud. Here we will use Terraform to deploy a Kubernetes cluster using AWS managed **EKS** service.

## Usage

Always use **secrets.tfvars** file to pass the following AWS credentials. You can also use a managed secrets service (from any Cloud provider) in order to store and pass them securely.
```
AWS_ACCESS_KEY_ID       = "<AKIAIOSFODNN7EXAMPLE>"
AWS_SECRET_ACCESS_KEY   = "<wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY>"
AWS_REGION              = "<us-east-1>"
```

## Commands

### Deployment
```
terraform init -upgrade
terraform validate
terraform fmt
terraform plan --var-file secrets.tfvars -out aws_eks_deployment.tfplan
terraform apply aws_eks_deployment.tfplan
```

### Destroy or Clean up
```
terraform plan --var-file secrets.tfvars -destroy -out aws_eks_deployment.destroy.tfplan
terraform apply aws_eks_deployment.destroy.tfplan
```