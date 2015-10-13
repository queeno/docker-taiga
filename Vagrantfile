VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Define memory and cpu
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 1
  end

  # Mount the current directory on /vagrant
  config.vm.synced_folder '.', '/vagrant'

  config.vm.define "taiga" do |machine|

    # Define hostname
    machine.vm.hostname = "taiga.vagrant"

    # Define IP address
    machine.vm.network :private_network, :ip => '192.168.33.10'

    # Define template
    machine.vm.box = 'ubuntu/trusty64'

    # Starting provisioners
    machine.vm.provision :shell, :path => "assets/vagrant/vagrant_preamble.sh"
  end
end
