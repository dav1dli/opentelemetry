# Observability
This is an example of how to use observability with NodeJS and Python codebases. The application code is derrived from [mastering-observability-with-opentelemetry](https://github.com/LinkedInLearning/mastering-observability-with-opentelemetry-4515650)

See files in `docs/` for more details.

## Components

```
                                      ---------
                                 |--->| Green | \
-------------      -----------   |    ---------  \-----------
| Forntend  | ---> | Gateway |---|                | MongoDB |
-------------      -----------   |    ---------  /-----------
                                 |--->| Blue  | /
                                      ---------
```

## Infrastructure
### Local Docker
The application with all its components can run locally on a local container engine. Docker composer configuration is provided in `docker-compose.yml`.

### Azure Container Apps
Azure Container Apps Environment and dependent services run application containers. The application fromtend is exposed via a public ingress. Container App Environment is private, i.e. all backend services run within the private VNET.

## Application
The application made from several microservices and using MongoDB for data management.

Microservices written in Python and NodeJS are containerized. Application elements are configurable using environment variables.

## Jaeger + Collector
The service used to collect the telemetry data and present it with a Web UI is Jaeger, for simplicity deployed next to the app.

To collect telemetry data app elements have to be instrumented and configured with environment variables telling the instrumentation where to send the data.