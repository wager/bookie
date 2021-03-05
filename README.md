A development and runtime platform for [Wager].

# Structure

```bash
platform/                           https://github.com/wager/platform
├── .github/                        Continuous delivery workflows.
├── Dockerfile                      Runtime platform.
└── Vagrantfile                     Development platform.
```

# Development

The development platform is built by [Vagrant].

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

The development platform is compatible with [VirtualBox] and [Google Compute Engine].

```bash
vagrant up  # VirtualBox
vagrant up --provider=google  # Google Compute Engine
```

Install [Visual Studio Code] and use the following configuration for the optimal experience.

```bash
# Make the Vagrant VM directly available over ssh.
vagrunt up && vagrant ssh-config >> ~/.ssh/config

# Install the recommended Visual Studio Code extensions.
code --install-extension BazelBuild.vscode-bazel
code --install-extension bbenoist.vagrant
code --install-extension golang.go
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-toolsai.jupyter
code --install-extension xyz.local-history
code --install-extension yzhang.markdown-all-in-one
code --install-extension zxh404.vscode-proto3
```

# Runtime

The runtime platform is built by [Docker].

```bash
docker build . -t ghcr.io/wager/runtime
```

[Docker]:
  https://www.docker.com/
[Google Compute Engine]:
  https://cloud.google.com/compute
[Remote SSH]:
  https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
[Vagrant]:
  https://www.vagrantup.com/
[VirtualBox]:
  https://www.virtualbox.org/
[Visual Studio Code]:
  https://code.visualstudio.com/download
[Wager]:
  https://github.com/wager/wager
