# How to run the application stack

Requirements:
* Docker runtime

## MacOS
Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/). It picks certificates including Zscaler CA autoatically.

*Note:* alternatives like brew installation will fail to pick Zscaler certificates automatically.

Start Docker Desktop client to have docker service available for command line interactions.

# Local environment
In project root run `docker compose up --build`
This command will print all outputs / logs to the console. To run in backgroud execute `docker compose up -d`

The application is available at http://localhost:8080/

When finished, execute `docker compose down`

# Azure Container Apps with Terraform
See `azure/terraform/infra/README.md` for detailed instructions and information about the cloud infrastructure.

See `azure/terraform/app/README.md` for detailed instructions and information about the application.

# Azure DevOps
The infrastructure is managed with Terraform in `azure/terraform/infra`.

Azure DevOps pipeline building the infrastructure is provided in `azure/pipelines/infra-build.yaml`.

Application images are built and published to ACR using `azure/pipelines/images-build.yaml` pipeline.

Application components deployments are configured using Terrafrom in `azure/terraform/app` and deployed by `azure/pipelines/app-deploy.yaml` pipeline.