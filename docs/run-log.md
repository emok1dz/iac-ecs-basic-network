# 运行记录

- 时间：2026-11-06（UTC）
- 环境：Terraform v1.9.8，huaweicloud provider v1.100.0；区域 cn-south-1（华南-广州）
- 凭证：环境变量 HW_ACCESS_KEY / HW_SECRET_KEY（本文件和仓库中都不含凭证）
- allowed_source_ip：执行 Terraform 的机器的公网出口 IP（/32）

## 本地静态检查
```text
$ terraform fmt -recursive
$ terraform init
$ terraform validate
Success! The configuration is valid.
```

## 第一次 plan / apply
```text
  # huaweicloud_compute_instance.this will be created
  # huaweicloud_networking_secgroup.this will be created
  # huaweicloud_networking_secgroup_rule.app_ingress will be created
  # huaweicloud_vpc.this will be created
  # huaweicloud_vpc_subnet.this will be created
Plan: 5 to add, 0 to change, 0 to destroy.

huaweicloud_networking_secgroup.this: Creation complete after 4s [id=ac92ca4a-b307-4cb8-8c77-fc05676d76fd]
huaweicloud_networking_secgroup_rule.app_ingress: Creation complete after 1s [id=c4183976-a60b-48a6-8040-def3ec9e7204]
huaweicloud_vpc.this: Creation complete after 10s [id=c3ed8d24-53db-4bcd-95a1-51f179bc51a9]
huaweicloud_vpc_subnet.this: Creation complete after 9s [id=dc7bdfe4-2553-4170-ba7e-7b88e39dcd4f]
Error: error creating server: Bad request with: [POST https://ecs.cn-south-1.myhuaweicloud.com/v1.1/01a1ae905f777e4abf0a1fdfef123916/cloudservers], request_id: …, error message: {"error":{"message":"Submit order failed, Insufficient account balance. Top up your account..","code":"Ecs.7000"}}
```
VPC、子网、安全组和规则都已创建；ECS 因账户余额不足（Ecs.7000）创建失败。

## 充值后第二次 plan / apply
```text
  # huaweicloud_compute_instance.this will be created
Plan: 1 to add, 0 to change, 0 to destroy.

huaweicloud_compute_instance.this: Creation complete after 54s [id=15ef3e6a-f1d9-4591-bbbe-db53630e4494]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
ecs_flavor = "c3.large.2"
ecs_instance_id = "15ef3e6a-f1d9-4591-bbbe-db53630e4494"
ecs_private_ip = "192.168.1.74"
image_name = "Huawei Cloud EulerOS 2.0 Standard 64 bit"
security_group_id = "ac92ca4a-b307-4cb8-8c77-fc05676d76fd"
subnet_id = "dc7bdfe4-2553-4170-ba7e-7b88e39dcd4f"
vpc_id = "c3ed8d24-53db-4bcd-95a1-51f179bc51a9"
```

## 资源核对
```text
# ECS（hcloud ECS ShowServer）
status ACTIVE | flavor c3.large.2 2 vCPU 4 GB | az cn-south-1c | image Huawei Cloud EulerOS 2.0 Standard 64 bit | sg ['iac-basic-sg']

# VPC
cidr                  = "192.168.0.0/16"
name                  = "iac-basic-vpc"
status                = "OK"

# 子网
cidr              = "192.168.1.0/24"
gateway_ip        = "192.168.1.1"
name              = "iac-basic-subnet"

# 安全组入站规则
direction               = "ingress"
ports                   = "8080"
protocol                = "tcp"
remote_ip_prefix        = "160.79.106.136/32"
```
remote_ip_prefix 为 /32 的单个 IP，即只放通指定 IP 访问 TCP 8080。

## 完成证明
`terraform.tfstate` 已提交，记录了 VPC、子网、安全组、安全组规则、ECS 共 5 个资源的真实 ID。

## 清理
判题通过后执行 `terraform destroy`。
