# Determine the name of the remote user from the comment in the SSH public key.
$public_key = File.read(File.expand_path("~/.ssh/id_rsa.pub"))
$username = $public_key.split(" ")[2].split("@")[0]

Vagrant.configure("2") do |config|
  # Provision a Ubuntu 20.04 LTS box.
  config.vm.box = "ubuntu/focal64"
  config.vm.provision :docker
  config.vm.provision "shell", path: "./toolchain/apt.sh", privileged: false
  config.vm.provision "shell", path: "./toolchain/spark.sh", privileged: false
  config.vm.provision "shell", path: "./toolchain/wager.sh", privileged: false
  config.vm.provision "shell", path: "./toolchain/prompt.sh", privileged: false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.ssh.extra_args = ["-t", "cd ~/wager; bash --login"]
  config.ssh.forward_agent = true
  config.ssh.private_key_path = "~/.ssh/id_rsa"
  config.ssh.username = "#{$username}"

  # Provide a VirtualBox VM by default.
  config.vm.provider :virtualbox do |virtualbox, override|
    override.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true  # Docsify
    override.vm.network "forwarded_port", guest: 8888, host: 8888, auto_correct: true  # Jupyter
    override.ssh.private_key_path = nil
    override.ssh.username = "vagrant"
  end

  # Provide a Google Compute Engine VM if --provider=google.
  config.vm.provider :google do |google, override|
    override.vm.box = "google/gce"

    google.enable_secure_boot = true
    google.google_json_key_location = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    google.google_project_id = ENV["GOOGLE_PROJECT_ID"] || "wager-233003"
    google.image_family = "ubuntu-2004-lts"
    google.machine_type = ENV["GOOGLE_MACHINE_TYPE"] || "e2-standard-4"
    google.name = "vagrant-#{$username.gsub!(/[^0-9A-Za-z]/, '-')}"
    google.network = "vpc"
    google.subnetwork = "vpc"
    google.tags = ["vagrant"]
    google.zone = ENV["GOOGLE_ZONE"] || "us-east1-b"
  end

  # Provide an EC2s VM if --provider=aws.
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.ssh.username = "ubuntu"

    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.ami = "ami-042e8287309f5df03"
    aws.associate_public_ip = true
    aws.instance_type = ENV["AWS_INSTANCE_TYPE"] || "t3.xlarge"
    aws.keypair_name = ENV["AWS_KEYPAIR_NAME"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.tags = {"Name" => "vagrant-#{aws.keypair_name}"}
  end
end
