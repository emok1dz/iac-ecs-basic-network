variable "region" {
  description = "区域，默认华南-广州"
  type        = string
  default     = "cn-south-1"
}

variable "name_prefix" {
  description = "资源名前缀"
  type        = string
  default     = "iac-basic"
}

variable "vpc_cidr" {
  description = "VPC 网段"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "子网网段（须在 VPC 网段内）"
  type        = string
  default     = "192.168.1.0/24"
}

variable "allowed_source_ip" {
  description = "允许访问 8080 端口的源 IP，格式 x.x.x.x/32（用 curl -s ifconfig.me 查询）"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_source_ip, 0)) && var.allowed_source_ip != "0.0.0.0/0"
    error_message = "allowed_source_ip 必须是合法 CIDR（如 1.2.3.4/32），且不能是 0.0.0.0/0。"
  }
}

variable "app_port" {
  description = "开放的入站端口"
  type        = number
  default     = 8080
}

variable "ecs_cpu" {
  description = "ECS vCPU 数"
  type        = number
  default     = 2
}

variable "ecs_memory_gb" {
  description = "ECS 内存（GB）"
  type        = number
  default     = 4
}

variable "ecs_flavor_id" {
  description = "指定 ECS 规格 ID（如 s6.large.2）；留空则自动选择符合 CPU/内存的规格"
  type        = string
  default     = ""
}

variable "image_name_regex" {
  description = "镜像名称正则，默认 Huawei Cloud EulerOS 2.0"
  type        = string
  default     = "^Huawei Cloud EulerOS 2\\.0 Standard 64 bit$"
}

variable "system_disk_size" {
  description = "系统盘大小（GB）"
  type        = number
  default     = 40
}
