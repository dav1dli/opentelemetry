# Infrastructure setup
This directory contains Terraform configuration for the infrastructure setup necessary for the application deployment.
In this configuration application components are deployed to Azure Container App environment running in a private VNET and exposed with a public ingress.

Pre-requirements:
* Azure subscription
* Resource group
* SPN with a Contributor role on the resource group
* Current user Data contributor on TFSTATE storage role assigned
* Bootstrap created backend storage (see `../bootstrap/` directory)

Created infrastructure resources:
* Log Analytics Workspace
* VNET + subnets + private endpoints
* ACR for container images storage
* Persistent storage for Apps DB
* Container Apps environment

## Infrastructure Deployment
Login to Azure: `az login`

If needed select a subscription: `az account set --subscription XXX-YYY-ZZZ`

Run terraform:
```
terraform -chdir=azure/terraform/infra init -var-file=../../conf/dev/env.tfvars \
  -backend-config=../../conf/dev/backend-infra.tfvars
terraform -chdir=azure/terraform/infra plan -var-file=../../conf/dev/env.tfvars -out=infra.tfplan
terraform -chdir=azure/terraform/infra apply -input=false -auto-approve infra.tfplan
```
Where `dev` is the environment for which the infrastructure is created.

To destroy the infrastructure:
```
terraform -chdir=azure/terraform/infra destroy \
  var-file=../../conf/${{ parameters.environment }}/env.tfvars \
  -input=false -auto-approve
```

## Azure DevOps pipelines
Deployment pipeline is provided in `azure/pipelines/infra-build.yaml`.

The pipeline is configurable via `azure/conf/dev/env.yaml` where `dev` is the environment for which the infrastructure is created. The pipeline supports a parameter selecting the environment.

The pipeline relies on a service connection providing credentials for the SPN with sufficient permissions on the resource group where the infrastructure is deployed.