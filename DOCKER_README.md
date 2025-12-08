# Lively4 Docker Image

This directory contains the configuration to build a Docker image running `lively4-server` and serving `lively4-core` along with `sandblocks-text-artifact`.

## Security Note

This Docker build process **exclusively clones public repositories** from GitHub. It does **not** copy any files from your local machine into the image. A `.dockerignore` file is included to ensure no local credentials or files are accidentally included in the build context.

## Prerequisites

- Docker installed on your system.

## Building the Image

Run the following command in this directory:

```bash
docker build -t lively4-artifact .
```

To **force a fresh clone** of the repositories (update to the latest versions), run:

```bash
docker build --no-cache -t lively4-artifact .
```

## Running the Container

Start the container and map the server port (9005) to port 8080 on your host:

```bash
docker run -p 8080:9005 lively4-artifact
```

## Kick the Tires

Once the container is running:

1.  Open your web browser.
2.  Navigate to the demo page:
    [http://localhost:8080/lively4-core/start.html?load=http://localhost:8080/sandblocks-text-artifact/lively-demo.md](http://localhost:8080/lively4-core/start.html?load=http://localhost:8080/sandblocks-text-artifact/lively-demo.md)
3.  You should see the Lively4 environment with the Sandblocks demo loaded.
