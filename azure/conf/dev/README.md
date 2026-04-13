# Environment setup
```
az account set -s d7d0b744-7dd4-494d-b357-0e13c93cf89e
```

Deploy infrastructure:
```
terraform -chdir=azure/terraform/infra init -var-file=../../conf/dev/env.tfvars
terraform -chdir=azure/terraform/infra plan -var-file=../../conf/dev/env.tfvars -out=infra.tfplan
terraform -chdir=azure/terraform/infra apply -input=false -auto-approve infra.tfplan
```

The IaC configuration is automated by an ADO pipeline `azure/pipelines/infra-build.yaml`. 

# Application images build
Application images are built by `azure/pipelines/images-build.yaml` pipeline all at once and published to an ACR in a resource group.

# Application deploy
Deploy app components:
```
terraform -chdir=azure/terraform/app init \
  -var-file=../../conf/dev/env.tfvars \
  -backend-config=../../conf/dev/backend-app.tfvars
terraform -chdir=azure/terraform/app plan -var-file=../../conf/dev/env.tfvars -out=apps.tfplan
terraform -chdir=azure/terraform/app apply -input=false -auto-approve apps.tfplan
```