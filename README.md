<p align="center">
  A development and runtime platform for <a href="https://github.com/wager/wager">Wager</a>.
</p>

<p align="center">
  <a href="https://github.com/wager/bookie/actions/workflows/ci.yml">
    <img
      src="https://github.com/wager/bookie/workflows/ci/badge.svg?branch=main"
      alt="Continuous Integration"
    />
  </a>
  <a href="https://github.com/wager/bookie/actions/workflows/cd.yml">
    <img
      src="https://github.com/wager/bookie/workflows/cd/badge.svg?branch=main"
      alt="Continuous Delivery"
    />
  </a>
  <a href="https://github.com/pre-commit/pre-commit">
    <img
      src="https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit"
      alt="pre-commit"
    />
  </a>
  <a href="https://hub.docker.com/r/wager/runtime">
    <img
      src="https://img.shields.io/docker/image-size/wager/runtime/latest?label=runtime"
      alt="Runtime"
    />
  </a>
  <a href="https://wager.help">
    <img
      src="https://img.shields.io/badge/docs-wager.help-informational"
      alt="Documentation"
    />
  </a>
</p>

# Structure

```bash
bookie/
├── .github/                        Continuous integration and delivery workflows.
├── .pre-commit-config.yaml         Linters.
├── terraform/                      Cloud infrastructure.
├── toolchain/                      Installation scripts.
└── Dockerfile                      Base platform.
```

# Features

The base platform is built by [Docker].

```bash
# Docker Hub.
docker pull wager/runtime

# GitHub Packages.
docker pull ghcr.io/wager/runtime
```

The cloud infrastructure is provisioned by [Terraform].

```bash
# Google Cloud.
terraform -chdir=terraform/google/setup apply
terraform -chdir=terraform/google apply

# Amazon Web Services.
terraform -chdir=terraform/aws/setup apply
terraform -chdir=terraform/aws apply
```

[Docker]:
  https://www.docker.com/
[Terraform]:
  https://www.terraform.io/
