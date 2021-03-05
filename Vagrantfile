Vagrant.configure("2") do |config|
  # Provision a Ubuntu 20.04 LTS box.
  config.vm.box = "ubuntu/focal64"
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

  # Create a local VM by default.
  config.vm.provider :virtualbox do |virtualbox, override|
    override.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true  # Docsify
    override.vm.network "forwarded_port", guest: 8888, host: 8888, auto_correct: true  # Jupyter
  end

  # Create a Google Cloud VM if --provider=google and GOOGLE_APPLICATION_CREDENTIALS is set.
  config.vm.provider :google do |google, override|
    override.vm.box = "google/gce"
    google.enable_secure_boot = true
    google.google_json_key_location = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    google.google_project_id = "wager-233003"
    google.image_family = "ubuntu-2004-lts"
    google.machine_type = "e2-standard-4"
    google.name = "vagrant-#{ENV["UserName"] || ENV["USER"]}"
    google.tags = ["vagrant"]
  end

  # Configure SSH.
  config.ssh.username = ENV["UserName"] || ENV["USER"]
  config.ssh.private_key_path = "~/.ssh/id_rsa"
  config.ssh.extra_args = ["-t", "cd /wager; bash --login"]

  # Disable synced folders.
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
