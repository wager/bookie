# Get the username on Windows or Linux.
$username = ENV.fetch("UserName", ENV.fetch("USER"))

Vagrant.configure("2") do |config|
  # Provision a Ubuntu 20.04 LTS box.
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.ssh.username = $username
  config.ssh.private_key_path = "~/.ssh/id_rsa"
  config.ssh.extra_args = ["-t", "cd /wager; bash --login"]

  config.vm.provision :docker
  config.vm.provision "shell", inline: <<-SHELL
    # Install system dependencies.
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y curl default-jdk git python-is-python3

    curl -O https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz
    tar xvf spark-3.0.2-bin-hadoop3.2.tgz
    mv spark-3.0.2-bin-hadoop3.2 /opt/spark
    rm spark-3.0.2-bin-hadoop3.2.tgz
    curl -O https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar
    mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/

    # Clone source code.
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    git clone git@github.com:wager/wager.git

    # Install development dependencies.
    apt-get install -y git golang-go golang-golang-x-tools node-gyp npm python3-pip
    npm install -g @bazel/bazelisk
    (cd wager && pip3 install pre-commit && pre-commit install)
    npm install -g docsify-cli
  SHELL

  # Provide a VirtualBox VM by default.
  config.vm.provider :virtualbox do |virtualbox, override|
    override.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true  # Docsify
    override.vm.network "forwarded_port", guest: 8888, host: 8888, auto_correct: true  # Jupyter
  end

  # Provide a Google Compute Engine VM if --provider=google.
  config.vm.provider :google do |google, override|
    override.vm.box = "google/gce"

    google.enable_secure_boot = true
    google.google_project_id = ENV.fetch("GOOGLE_PROJECT_ID", "wager-233003")
    google.image_family = "ubuntu-2004-lts"
    google.machine_type = ENV.fetch("GOOGLE_MACHINE_TYPE", "e2-standard-4")
    google.network = "vpc"
    google.name = "vagrant-#{$username}"
    google.tags = ["vagrant"]
  end

  # Provide an EC2s VM if --provider=aws.
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.ssh.username = "ubuntu"

    aws.ami = "ami-042e8287309f5df03"
    aws.associate_public_ip = true
    aws.instance_type = ENV.fetch("AWS_INSTANCE_TYPE", "t3.xlarge")
    aws.keypair_name = ENV.fetch("AWS_KEYPAIR_NAME", $username)
    aws.tags = {"Name" => "vagrant-#{$username}"}
  end
end
