<p align="center">
  <a href="https://github.com/wager/bookie/actions/workflows/cd.yml">
    <img
      src="https://github.com/wager/bookie/workflows/cd/badge.svg"
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

A development and runtime platform for [Wager].

# Structure

```bash
platform/                           https://github.com/wager/platform
├── .github/                        Continuous integration and delivery workflows.
├── .pre-commit-config.yaml         Linters.
├── terraform                       Cloud infrastructure.
├── Dockerfile                      Runtime platform.
└── Vagrantfile                     Development platform.
```

# Features

The development platform is built with [Vagrant].

```bash
# Start the development environment.
vagrant up
# Enter the development environment.
vagrant ssh
# Exit the development environment.
exit
# Shutdown the development environment.
vagrant suspend
```

The development platform runs on [VirtualBox], [Google Cloud], and [AWS].

```bash
vagrant up  # VirtualBox
vagrant up --provider=google  # Google Compute Engine
vagrant up --provider=aws  # AWS EC2.
```

The runtime platform is built with [Docker].

```bash
docker build . -t ghcr.io/wager/runtime
```

[AWS]:
  https://aws.amazon.com/ec2
[Docker]:
  https://www.docker.com/
[Google Cloud]:
  https://cloud.google.com/compute
[Vagrant]:
  https://www.vagrantup.com
[VirtualBox]:
  https://www.virtualbox.org
[Wager]:
  https://github.com/wager/wager
