# CCF Infrastructure Setup (AWS/Terraform)

## Overview

This directory contains basic infrastructure code to setup the application in AWS using basic services such as EC2, IAM, Athena, Glue, Lambda. The goal is to have a simple and generic setup that can be configured to each customer needs.

## Architecture
The general architecture consists of the following components:

- EC2 instance and instance profile
- IAM Policies and Roles
- S3 Buckets (cur reports, athena queries output, carbon emission reports)
- Lambda functions (glue crawler initializer, athena scheduled trigger, carbon emission run CLI app)
- Glue database and crawler
- EventBridge rule for triggering scheduled athena queries
- CUR report definition

### Prerequisites

- Terraform >= 0.14.9 (tip: use [tfenv](https://github.com/tfutils/tfenv)) to manage multiple Terraform versions)

## How to use (basic step by step guide)

1. Make sure you have created an S3 bucket for the remote Terraform state file.
2. Go to `variables.tf` and adjust the variables using the provided example
3. Repeat step 2 for the files: `terraform.tf`, `provider.tf`, `locals.tf` and `data.tf`
4. Adjust the `install.sh` script based on your needs. You may want to configure the nodejs version and the repository that holds the actual code. If you're using only the CLI functionality the .env related section can be removed
5. Run `terraform init`
6. Run `terraform validate` and make sure the configuration is valid 
7. Run `terraform plan` and `terraform apply` against your cloud provider

## Debugging

To work out if the `install.sh` script succeeds, you can SSH into the instance using the key pair specified in "key_name" variable (or connect via the AWS console), and tail the initialization logs with:

```
$ sudo su
$ tail -f /var/log/cloud-init-output.log 
```

## Other considerations

- You might not have access to apply Terraform infrastructure directly against your cloud. This has been tested as well with PR-based systems such as Atlantis, but might still need some tweaking on your part.

- The overall architecture might not suit your needs e.g. you might want the application running on an Internet facing compute instance, or you might not keep your application code in codecommit, etc. We understand there are multiple context specific needs that you can work out using this solution as a foundation.
