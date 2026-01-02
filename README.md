# Observability with OpenTelemetry
This is an example of how to use OpenTelemetry observability with NodeJS and Python codebases. The application code is derrived from [mastering-observability-with-opentelemetry](https://github.com/LinkedInLearning/mastering-observability-with-opentelemetry-4515650)

See the HOWTO file for setup instructions.

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