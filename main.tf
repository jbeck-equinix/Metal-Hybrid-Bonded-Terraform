terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
      version = "2.1.0"
      }
  }
}

provider "metal" {
  auth_token = local.auth_token
}

locals {
    auth_token = "your_auth_token"
    project_id = "your_project_id"
}

#user-data script
data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh.tpl")}"
}

#create metal vlan
resource "metal_vlan" "vlan1" {
  metro       = "dc"
  project_id  = local.project_id
  description = "HB-demo"
  vxlan       = "3001"
  }

#deploy metal intance
resource "metal_device" "HB-Demo" {
  hostname         = "HB-Demo-Instance"
  plan             = "c3.medium.x86"
  metro            = "dc"
  operating_system = "centos_7"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  user_data        = "${data.template_file.user_data.rendered}"
}

#set metal instance to hybrid bonded network mode
resource "metal_device_network_type" "HB-Demo" {
  device_id = metal_device.HB-Demo.id
  type = "hybrid-bonded"
}

#attach instance to metal vlan1
resource "metal_port_vlan_attachment" "router_vlan_attach" {
  device_id = metal_device.HB-Demo.id
  port_name = "bond0"
  vlan_vnid = metal_vlan.vlan1.vxlan
}


output "Public_IP" {
    value = metal_device.HB-Demo.access_public_ipv4
  }
