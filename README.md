# AWS Static web Solution

## Architecture diagram
![Architecture Diagram](./Diagram/Architecture%20Diagram.png)


This a static web or CSR (Client-Side Rendering) solution on AWS, it uses Route53 for DNS managment, Cloudfront for CDN to reduce latency of static content, S3 as the origin that stores and hosts the website and it's content, lambda as a backend API that communicates with a DynamoDB.

This solution can be used to host a simple blog, resume, portfolio or a CSR app.
Any dynamic or SSR (Server-Side Rendering) web app would require a compute service.

You can fully automate `terraform apply` and `terraform plan` with an automation or CI/CD server like GitHub Actions and using Terraform Cloud to store, manage, lock, encrypt and version tf state.

## Requirments
- AWS Account
- Terraform Cloud Account
- GitHub Account
- Terraform CLI (`tfenv` or `terraform`)

### Terraform Providers
- AWS
- Local
- Archive
- Null

## Installing Terraform

installing `terraform`

```bash
$ brew install terraform
```

installing `tfenv`

```bash
$ brew install tfenv
```

## Steps to run

1. Create a project in Terraform Cloud and create a workspace in that project.
2. Go to your TFC account settings and create an API token.
3. Go to AWS IAM console and create a temporary Access Key to a user with [least privilage](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)(ideally).
4. Add the AWS credentials as a secret env var to your TFC workspace
5. Add the TF variables as HCL vars to your TFC workspace

### TF CLI workflow
1. Add the cloud block in your TF config to use TFC as your TF backend.
2. Run the command `terraform login` and use the API token to auth to TFC.
3. Run `terraform plan` then `terraform apply` to provision your resources on AWS from TFC linux runner.
### TF API workflow
1. Add `TF_API_TOKEN` to secrets in your GitHub Repo.
2. Push to the main branch to trigger `terraform apply` action.
3. Create a branch and push to upstream to trigger `terraform plan` action.

## Components

### Frontend
- TODO
### Backend
- TODO
### DevOps
- The CI/CD only automates the terraform apply and terraform plan operation, but it can be extended to add a build and test step, depending on the app. 
The build can be handed to TF to upload it to the S3 bucket.

