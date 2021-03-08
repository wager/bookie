A development and runtime platform for [Wager].

# Structure

```bash
platform/                           https://github.com/wager/platform
├── .github/                        Continuous delivery workflows.
├── Dockerfile                      Runtime platform.
├── terraform                       Cloud infrastructure.
└── Vagrantfile                     Development platform.
```

# Setup

1. Install [Git], [Vagrant], [VirtualBox].

```bash
# Install Visual Studio Code on Ubuntu.
sudo apt install git vagrant virtualbox
```

2. Generate an SSH key and grant it access to the [Wager] repository.

```bash
# Run from a terminal on macOS and Linux, and from Git Bash on Windows.
ssh-keygen
```

3. Launch the development environment.

```bash
# Launch the development environment.
vagrunt up
```

4. Install [Visual Studio Code] for the optimal experience. (optional)

```bash
# Install Visual Studio Code on Ubuntu.
sudo snap install --classic code

# Install recommended extensions.
code --install-extension BazelBuild.vscode-bazel
code --install-extension bbenoist.vagrant
code --install-extension golang.go
code --install-extension hashicorp.terraform
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-toolsai.jupyter
code --install-extension xyz.local-history
code --install-extension yzhang.markdown-all-in-one
code --install-extension zxh404.vscode-proto3

# Enable access to Vagrant through the Remote - SSH extension.
vagrant ssh-config >> ~/.ssh/config
```

# Features

The development platform is built on [Vagrant].

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

The development platform is compatible with [VirtualBox], [Google Compute Engine], and [AWS EC2].

```bash
vagrant up  # VirtualBox
vagrant up --provider=google  # Google Compute Engine
vagrant up --provider=aws  # AWS EC2.
```

The runtime platform is built on [Docker].

```bash
docker build . -t ghcr.io/wager/runtime
```

[AWS EC2]:
  https://aws.amazon.com/ec2
[Docker]:
  https://www.docker.com/
[Git]:
  https://git-scm.com/downloads
[Google Compute Engine]:
  https://cloud.google.com/compute
[Vagrant]:
  https://www.vagrantup.com/downloads
[VirtualBox]:
  https://www.virtualbox.org/wiki/Downloads
[Visual Studio Code]:
  https://code.visualstudio.com/Download
[Wager]:
  https://github.com/wager/wager
