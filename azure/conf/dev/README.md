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

# Application images build

# Application deploy