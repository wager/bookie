$username = ENV[Vagrant::Util::Platform.windows? ? "UserName" : "USER"]

Vagrant.configure("2") do |config|
  # Provision a Ubuntu 20.04 LTS box.
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.ssh.extra_args = ["-t", "cd wager; bash --login"]
  config.ssh.forward_agent = true
  config.ssh.private_key_path = "~/.ssh/id_rsa"
  config.ssh.username = $username

  config.vm.provision :docker
  config.vm.provision "shell", inline: <<-SHELL
    # Configure provisioning script.
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update --yes

    # Install system dependencies.
    apt-get install --yes --no-install-recommends \
      curl=7.68.0-1ubuntu2.4 \
      default-jdk=2:1.11-72 \
      python-is-python3=3.8.2-4

    curl -sO https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz
    tar xvf spark-3.0.2-bin-hadoop3.2.tgz
    mv spark-3.0.2-bin-hadoop3.2 /opt/spark
    rm spark-3.0.2-bin-hadoop3.2.tgz
    curl -sO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.969/aws-java-sdk-bundle-1.11.969.jar
    mv aws-java-sdk-bundle-1.11.969.jar /opt/spark/jars/
    curl -sO https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar
    mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/
    curl -sO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar
    mv hadoop-aws-3.2.2.jar /opt/spark/jars/
    curl -sO https://github.com/GoogleCloudDataproc/spark-bigquery-connector/releases/download/0.19.1/spark-bigquery-with-dependencies_2.12-0.19.1.jar
    mv spark-bigquery-with-dependencies_2.12-0.19.1.jar /opt/spark/jars/

    # Clone source code.
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    git clone git@github.com:wager/wager.git

    # Install development dependencies.
    apt-get install --yes --no-install-recommends \
      git-all=1:2.25.1-1ubuntu3 \
      golang-go=2:1.13~1ubuntu2 \
      golang-golang-x-tools=1:0.0~git20191118.07fc4c7+ds-1 \
      node-gyp=6.1.0-3 \
      npm=6.14.4+ds-1ubuntu2 \
      python3-pip=20.0.2-5ubuntu1.1

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
    override.ssh.username = ENV["GOOGLE_USERNAME"] || $username

    google.enable_secure_boot = true
    google.google_json_key_location = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    google.google_project_id = ENV["GOOGLE_PROJECT_ID"] || "wager-233003"
    google.image_family = "ubuntu-2004-lts"
    google.machine_type = ENV["GOOGLE_MACHINE_TYPE"] || "e2-standard-4"
    google.name = "vagrant-#{$username}"
    google.network = "vpc"
    google.subnetwork = "vpc"
    google.tags = ["vagrant"]
    google.zone = "us-east1-b"
  end

  # Provide an EC2s VM if --provider=aws.
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.ssh.username = "ubuntu"

    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.ami = "ami-042e8287309f5df03"
    aws.associate_public_ip = true
    aws.instance_type = ENV["AWS_INSTANCE_TYPE"] || "t3.xlarge"
    aws.keypair_name = ENV["AWS_KEYPAIR_NAME"] || $username
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.tags = {"Name" => "vagrant-#{$username}"}
  end
end
