terraform {
  required_version = ">= 1.9.0"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.60.0"
    }
  }
}

# 凭证从环境变量读取：HW_ACCESS_KEY / HW_SECRET_KEY（不写进代码）
provider "huaweicloud" {
  region = var.region
}
