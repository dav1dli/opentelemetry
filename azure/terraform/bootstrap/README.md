# Infrastructure state setup
This directory contains Terraform configuration for the initial infrastructure required to run Terraform, i.e. storage for the state.

Pre-requirements:
* Azure subscription
* Resource group
* SPN with a Contributor role on the resource group

Created infrastructure resources:
* Storage account
* Storage container
* Data plain role assignments

## Infrastructure Deployment
Login to Azure: `az login`

If needed select a subscription: `az account set --subscription XXX-YYY-ZZZ`

Run terraform:
```
terraform -chdir=azure/terraform/bootstrap init -var-file=../../conf/dev/env.tfvars
terraform -chdir=azure/terraform/bootstrap plan -var-file=../../conf/dev/env.tfvars -out=infra.tfplan
terraform -chdir=azure/terraform/bootstrap apply -input=false -auto-approve infra.tfplan
```
Where `dev` is an environment for which the infrastructure is created.