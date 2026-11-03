# ECS 基础网络环境：VPC → 子网 → 安全组（入站 8080 仅放通指定 IP）→ ECS（绑定子网与安全组）

data "huaweicloud_availability_zones" "this" {}

locals {
  az = data.huaweicloud_availability_zones.this.names[0]
}

# 自动查询该可用区内满足 CPU/内存要求的规格
data "huaweicloud_compute_flavors" "this" {
  availability_zone = local.az
  cpu_core_count    = var.ecs_cpu
  memory_size       = var.ecs_memory_gb
}

# 自动查询最新的 Huawei Cloud EulerOS 2.0 公共镜像
data "huaweicloud_images_image" "hce" {
  name_regex   = var.image_name_regex
  visibility   = "public"
  architecture = "x86"
  most_recent  = true
}

resource "huaweicloud_vpc" "this" {
  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "this" {
  name       = "${var.name_prefix}-subnet"
  vpc_id     = huaweicloud_vpc.this.id
  cidr       = var.subnet_cidr
  gateway_ip = cidrhost(var.subnet_cidr, 1)
}

resource "huaweicloud_networking_secgroup" "this" {
  name        = "${var.name_prefix}-sg"
  description = "Managed by Terraform: allow TCP ${var.app_port} from ${var.allowed_source_ip}"
}

resource "huaweicloud_networking_secgroup_rule" "app_ingress" {
  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = tostring(var.app_port)
  remote_ip_prefix  = var.allowed_source_ip
  description       = "allow app port from specified IP only"
}

resource "huaweicloud_compute_instance" "this" {
  name               = "${var.name_prefix}-ecs"
  availability_zone  = local.az
  flavor_id          = var.ecs_flavor_id != "" ? var.ecs_flavor_id : data.huaweicloud_compute_flavors.this.ids[0]
  image_id           = data.huaweicloud_images_image.hce.id
  security_group_ids = [huaweicloud_networking_secgroup.this.id]
  system_disk_type   = "SSD"
  system_disk_size   = var.system_disk_size

  network {
    uuid = huaweicloud_vpc_subnet.this.id
  }

  # 规格列表顺序可能变化，避免因此触发重建
  lifecycle {
    ignore_changes = [flavor_id, image_id]
  }
}
