terraform {
  required_providers {
    openstack = {
        source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
    cloud = "openstack"
}

resource "openstack_compute_instance_v2" "puppet_master" {
    name = "puppet_master-AK"
    image_name = "ubuntu-22.04"
    flavor_name = "l2.c2r4.100"
    key_pair = "VM170-Key"
    network {
      name = "public"
    }

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = openstack_compute_instance_v2.puppet_master.access_ip_v4
    }

    provisioner "file" {
      source = "./manifest.pp" # This file contains the hping3 to be install in the system
      destination = "/home/ubuntu/manifest.pp" 
    }

    provisioner "remote-exec" {
        inline = [
          "sleep 50",
          "sudo apt update -y",
          "sudo bash -c 'echo \"${openstack_compute_instance_v2.puppet_master.access_ip_v4} puppetmaster.openstacklocal puppetmaster\" >> /etc/hosts'",
          "sudo curl -LO https://apt.puppet.com/puppet7-release-focal.deb",
          "sudo dpkg -i ./puppet7-release-focal.deb",
          "sudo apt update",
          "sudo apt -y install puppetserver",
          "sudo bash -c 'echo -e \"dns_alt_names=puppetmaster.openstacklocal,puppetmaster\n\n[main]\ncertname=puppetmaster.openstacklocal\nserver=puppetmaster.openstacklocal\nenvironment=production\nruninterval=3m\" >> /etc/puppetlabs/puppet/puppet.conf'",
          "sudo /opt/puppetlabs/bin/puppetserver ca setup",
          "sudo mv /home/ubuntu/manifest.pp /etc/puppetlabs/code/environments/production/manifests/manifest.pp",
          "sudo systemctl start puppetserver",
          "sudo apt-get install puppet-agent -y",
          "sudo /opt/puppetlabs/bin/puppet config set server puppetmaster",
          "sudo /opt/puppetlabs/puppet/bin/puppet agent",
        ]
    }
}

output "puppet_master_ip" {
  value = openstack_compute_instance_v2.puppet_master.access_ip_v4
}