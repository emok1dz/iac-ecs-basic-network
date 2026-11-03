output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.this.id
}

output "subnet_id" {
  description = "子网 ID"
  value       = huaweicloud_vpc_subnet.this.id
}

output "security_group_id" {
  description = "安全组 ID"
  value       = huaweicloud_networking_secgroup.this.id
}

output "ecs_instance_id" {
  description = "ECS 实例 ID"
  value       = huaweicloud_compute_instance.this.id
}

output "ecs_private_ip" {
  description = "ECS 私网 IP"
  value       = huaweicloud_compute_instance.this.access_ip_v4
}

output "ecs_flavor" {
  description = "实际使用的 ECS 规格"
  value       = huaweicloud_compute_instance.this.flavor_id
}

output "image_name" {
  description = "实际使用的镜像"
  value       = data.huaweicloud_images_image.hce.name
}
