output "ip" {
   value = "${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
}

output "public-ip" {
   value = "${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
}

output "private-ip" {
   value = "${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

output "ansible" {
  value = "[teuthology]\n${join(" ", openstack_networking_floatingip_v2.fip.*.address)}\n[paddles]\n${join(" ", openstack_networking_floatingip_v2.fip.*.address)}\n[pulpito]\n${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
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
  default = "teuthology-opensuse-15.1-x86_64"
}

variable "os_flavor" {
  description = "Openstack Flavor Name"
  type = "string"
  default = "m1.large"
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
    key_pair = "${var.os_keyname}"
    user_data = "${file("${path.module}/../../../openstack/userdata-ecp.yaml")}"
    security_groups = ["default", "sesci"]
    metadata {
        demo = "metadata"
    }
    network {
        name = "sesci"
    }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = "${var.nodes}"
  pool = "floating"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = "${var.nodes}"
  floating_ip = "${element(openstack_networking_floatingip_v2.fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.node.*.id, count.index)}"
}
