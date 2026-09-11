# Docker Base Images

This repository is responsible for building and publishing the base Docker images used across projects.

The goal is to centralize the Dockerfiles for these base images and automate their publication to Docker Hub through GitHub Actions.

## Available Images

The repository currently builds the following images:

| Image              | Dockerfile               | Description                   |
| ------------------ | ------------------------ | ----------------------------- |
| `php-8.5-fpm`      | `Dockerfile.fpm`         | PHP 8.5 with PHP-FPM          |
| `php-8.5-apache`   | `Dockerfile.apache`      | PHP 8.5 with Apache           |
| `php-8.5-composer` | `Dockerfile.phpcomposer` | PHP 8.5 with Composer         |
| `opencode-v1`      | `Dockerfile.opencode`    | Base environment for OpenCode |

Images are published to Docker Hub under the configured namespace:

```text
<docker-hub-namespace>/<image>:latest
```

For example:

```text
<docker-hub-namespace>/php-8.5-fpm:latest
<docker-hub-namespace>/php-8.5-apache:latest
<docker-hub-namespace>/php-8.5-composer:latest
<docker-hub-namespace>/opencode-v1:latest
```

## Repository Structure

```text
.
├── Dockerfile.apache
├── Dockerfile.fpm
├── Dockerfile.phpcomposer
├── Dockerfile.opencode
└── .github/
    └── workflows/
        └── docker.yml
```

## Local Build

Docker must be installed to build the images locally.

### Apache

```bash
docker build \
  -f Dockerfile.apache \
  -t <your-user>/php-8.5-apache:latest \
  .
```

### PHP-FPM

```bash
docker build \
  -f Dockerfile.fpm \
  -t <your-user>/php-8.5-fpm:latest \
  .
```

### Composer

```bash
docker build \
  -f Dockerfile.phpcomposer \
  -t <your-user>/php-8.5-composer:latest \
  .
```

### OpenCode

```bash
docker build \
  -f Dockerfile.opencode \
  -t <your-user>/opencode-v1:latest \
  .
```

## Manual Publishing

After building an image, authenticate with Docker Hub:

```bash
docker login
```

Then push the image:

```bash
docker push <your-user>/php-8.5-apache:latest
```

The same process can be used for the other images.

## GitHub Actions

Official image publishing is handled automatically through GitHub Actions.

The workflow runs whenever changes are pushed to the `main` branch.

The pipeline performs the following steps:

```text
Git push
   │
   ▼
GitGuardian
   │
   ├── PHP Apache ────────┐
   ├── PHP FPM ───────────┤
   ├── PHP Composer ──────┤
   └── OpenCode ──────────┤
                          ▼
                    Docker Hub
                          │
                          ▼
                    GitHub Release
```

Each image is built and published independently.

A GitHub Release is created only after all image builds and Docker Hub pushes complete successfully.

## Required Secrets

The GitHub Actions workflow requires the following repository secrets:

```text
DOCKER_HUB_USERNAME
DOCKER_HUB_ACCESS_TOKEN
DOCKER_HUB_NAMESPACE
GH_TOKEN
GITGUARDIAN_API_KEY
```

### Docker Hub

`DOCKER_HUB_USERNAME`

Docker Hub username used for authentication.

`DOCKER_HUB_ACCESS_TOKEN`

Docker Hub Access Token used by GitHub Actions to publish images.

`DOCKER_HUB_NAMESPACE`

Docker Hub namespace where the images will be published.

### GitHub

`GH_TOKEN`

Token used for GitHub release operations.

### GitGuardian

`GITGUARDIAN_API_KEY`

API key used by GitGuardian to scan the repository before building the images.

## Versioning

Images currently use the following tag:

```text
latest
```

GitHub Releases are generated automatically using the following format:

```text
vYYYY.MM.DD.N
```

For example:

```text
v2026.09.10.1
```

## Repository Purpose

This repository **does not contain final applications**.

It acts as an infrastructure layer that provides reusable Docker base images for other projects.

Changes to the Dockerfiles should, whenever possible, preserve:

* compatibility with projects consuming these images;
* reproducible builds;
* minimal configuration inside the images;
* project-specific configuration at runtime.

---

## License

See the `LICENSE` file for the terms and conditions of using this repository.