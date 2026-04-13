# Application Deployment (Azure Container Apps)

This directory contains the Terraform configuration for a distributed microservices architecture (Node.js and Python) deployed on **Azure Container Apps (ACA)**.

## Architecture Overview
The system consists of a public-facing Node.js Frontend, a Python Gateway, and two backend services (Node-Blue and Python-Green) backed by MongoDB. All internal communication is secured within a private VNET.

### Prerequisites
* **Azure Subscription:** Active subscription with owner/contributor access.
* **Resource group**
* **Service Principal (SPN):** Assigned `Contributor` role on the target Resource Group.
* **Permissions:** Current user needs `Storage Blob Data Contributor` on the TFSTATE storage account.
* **Base Infra:** Networking and ACA Environment must be deployed (see `../infra/`).
* **Images:** Application containers must be published to the project Azure Container Registry (ACR).

## Deployment Steps

### 1. Login & Context
```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```
### App Deployment
Run the following commands from the root of the terraform directory:
```
# Initialize with remote backend
terraform -chdir=azure/terraform/app init \
  -var-file=../../conf/dev/env.tfvars \
  -backend-config=../../conf/dev/backend-app.tfvars

# Plan and Apply
terraform -chdir=azure/terraform/app plan -var-file=../../conf/dev/env.tfvars -out=apps.tfplan
terraform -chdir=azure/terraform/app apply -input=false -auto-approve apps.tfplan
```
Where `dev` is the environment where the app is deployed.

The configuration deploys the database, application elements as Container Apps from images published to the ACR and configures connctivity between elements.

### Teardown
To destroy the infrastructure:
```
terraform -chdir=azure/terraform/infra destroy \
  var-file=./../conf/dev/env.tfvars -input=false -auto-approve
```

## Azure DevOps pipelines
Deployment pipeline is provided in `azure/pipelines/app-deploy.yaml`.

The pipeline is configurable via `azure/conf/dev/env.yaml` where `dev` is the environment for which the infrastructure is created. The pipeline supports a parameter selecting the environment.

The pipeline relies on a service connection providing credentials for the SPN with sufficient permissions on the resource group where the infrastructure is deployed.

## Notes
### Differences between local Docker and Azure Container Apps
In a local Docker Compose setup, containers communicate directly via their exposed ports (e.g., 3020). In Azure Container Apps, this behavior changes:
* Internal Ingress: Services are exposed via an internal load balancer.
* Port Translation: Regardless of the targetPort defined in a container (e.g., 3020, 5001, or 8080), the Ingress exposes the service to other apps in the environment on HTTP Port 80.
* Connectivity Rule: Internal HTTP calls should always use the format http://<service-name> without appending a port number.

MongoDB protocol is not HTTP, thus its ingress is set as TCP transport and is accessible via the container port. It is not advised to use this method for services communicating using HTTP protocol.

### MongoDB persistence
In Azure Container Apps it is possible to setup persistent volumes for stateful apps like MongoDB. MongoDB requires POSIX-compliant filesystem features (like fsync and mmap). Azure Files (SMB) lacks these features, which can lead to database corruption.

Current Solution: Uses a `localDir` volume for ephemeral persistence.

Note: Data will be lost if the container restarts. For production, transition to Azure Cosmos DB (MongoDB API).


### Multi-Port Support (Jaeger/Collector)
Current Azure Web UI supports Additional Ports option. AzureRM Terraform provider currently only supports a single ingress port. For services like Jaeger that require a Web UI (80) and an OTLP Ingestion port (4318), we use the AzAPI Provider to patch the Container App with "Additional Ports" after creation.

### Collector
At the moment a separate Collector could not be used from within ACA environment because of how its ingresses are handled by ACA. First, gRPC could not be made working. And then the way how ACA Environment forces automatic probes on Collector ports leads to the result that the Collector is started successfully, but killed by the environment failing to probe it properly. It needs more debugging.

### Access restrictions
Backend application components including the DB define ingresses but those ingresses are internal, i.e. accessible only within the private VNET.

Frontend defines a public ingress, but implements whitelisted IP ACL.

## Testing
For testing purposes a configuration of a testing container `network-tester` is provided. It's a small container with popular network testing tools deployed into the private VNET and accessible via ACA web UI console (network-tester: Monitoring -> Console)

To test port connectivity to app elements use `netcat -zv mongodb 27017` (a better alternative to `telnet mongodb 27017`).

To test web connectivity use `curl node-service-blue`.

Note: use HTTP/80 and not TCP/3020 because the app is exposed with an ingress which serves requests on the HTTP port.

## Log streaming
To view live application logs and OTel initialization errors:
```
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow
```

## OpenTelemetry
OpenTelimetry is provided as Jaeger + Collector deployed in the same VNET for simplicity. In real world scenarios the monitoring service might be running outside of the VNET, which might require a dedicated OTel Collector running inside of it, it would collect the telemetry data and forward it to the external service, Jaeger or any other supporting OpenTelimetry protocols.

OTel Collector has 2 parts: an OTLP Receiver receiving dat from apps and an Exporter sending data to the OTel service like Jaeger.

The app code in this scope remains unchanged, instead it is autoinstrumented with language-specific agents.
* Python: opentelemetry-instrument wrapper
* NodeJS: load a pre-configured OTel SDK at runtime
These agents automatically intercept library calls (like requests, axios, flask, express, and pymongo) to generate traces.

Agents are configured via standard OTel environment variables, like `OTEL_EXPORTER_OTLP_ENDPOINT = http://otel-collector:4318`

Jaeger deployed to the VNET is exposed via the public ingress and accessible like the app frontend on its own URL. IP restrictions are part of the configuration.

Note: Jaeger has to publish 2 ports: the Web UI and OTel collector port. Right now `azurerm` provider does not support more than one ingress port. Thus it is added using AzAPI provider.

### Instrumentation
#### NodeJS
NodeJS OTel SDK is preloaded and configured using environment variables:
* NODE_OPTIONS: "--require @opentelemetry/auto-instrumentations-node/register" - pre-load the SDK
* OTEL_EXPORTER_OTLP_ENDPOINT - points to the OTel Collector endpoint

#### Python
Open Telemetry components are installed in the container from `requirements.txt`. Wrapper script `opentelemetry-instrument` as a container CMD in `Dockerfile`.

Then OTel is configured:
* OTEL_SERVICE_NAME: python-service-gateway
* OTEL_EXPORTER_OTLP_ENDPOINT: http://jaeger:4318"
* OTEL_EXPORTER_OTLP_PROTOCOL: "http/protobuf"
* OTEL_PROPAGATORS: "tracecontext,baggage"