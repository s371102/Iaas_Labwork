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
resource "openstack_compute_instance_v2" "install_instance" {
    name = "Master-VM-AR"
    image_name = "ubuntu-22.04"
    flavor_name = "l2.c2r4.100"
    key_pair = "Akash_Test001"
    
    network {
    name = "public"
    }
}