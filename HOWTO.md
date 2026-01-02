# System issues

Requirements:
* Docker runtime

## MacOS
Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/). It picks certificates including Zscaler CA autoatically.

*Note:* alternatives like brew installation will fail to pick Zscaler certificates automatically.

# Local environment
In project root run `docker compose up --build`
This command will print all outputs / logs to the console. To run in backgroud execute `docker compose up -d`

The application is available at http://localhost:8080/