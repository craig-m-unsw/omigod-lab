Vagrant.require_version ">= 2.2.14"

Vagrant.configure("2") do |config|
    config.vm.box = "generic/ubuntu2004"
    config.vm.box_version = "3.4.2"
    config.vm.synced_folder ".", "/vagrant", type: "rsync"

    config.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "/vagrant/playbook.yml"
        ansible.extra_vars = { ansible_python_interpreter: "/usr/bin/python3" }
        ansible.verbose = true
    end

    config.vm.network :forwarded_port, 
        guest: 5986, 
        host_ip: '127.0.0.1', 
        host: 5986, protocol: "tcp"
end