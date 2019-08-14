output "ip" {
  value = "${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

output "public-ip" {
  value = "${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

output "private-ip" {
  value = "${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

output "ansible" {
  value = "[nameserver]\n${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}\n[teuthology]\n${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}\n[paddles]\n${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}\n[pulpito]\n${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

variable "nodes" {
  description = "Number of nodes"
  type = "string"
  default = "1"
}

variable "os_keyname" {
  description = "Openstack keypair to inject into this server"
  type = "string"
  default = "storage-automation"
}

variable "os_image" {
  description = "Openstack Image Name"
  type = "string"
  default = "teuthology-opensuse-42.3-x86_64"
}

variable "os_flavor" {
  description = "Openstack Flavor Name"
  type = "string"
  default = "s1-8"
}

variable "target_id" {
  description = "Openstack Target Id"
  type = "string"
  default = "server"
}

resource "openstack_compute_instance_v2" "node" {
    count = "${var.nodes}"
    name = "teuth-${var.target_id}"
    image_name = "${var.os_image}"
    flavor_name = "${var.os_flavor}"
    security_groups = ["default"]
    key_pair = "${var.os_keyname}"
    user_data = "${file("${path.module}/../../../openstack/userdata-ovh.yaml")}"
    network {
        name = "Ext-Net"
    }
}

