# IaC搭建ECS基础网络环境

ICT 大赛实践赛题 **1.18「基于 IaC 在华为云上搭建 ECS 服务基础网络环境」** 作品。

用 Terraform 在华为云**华南-广州（cn-south-1）**一次性创建并绑定 4 类资源：

| 资源 | Terraform 资源 | 配置 |
| --- | --- | --- |
| VPC | `huaweicloud_vpc` | 网段 `192.168.0.0/16` |
| 子网 | `huaweicloud_vpc_subnet` | `192.168.1.0/24`，网关 `.1` |
| 安全组 + 入站规则 | `huaweicloud_networking_secgroup` / `_rule` | 只允许**指定 IP** 访问 TCP **8080** |
| ECS | `huaweicloud_compute_instance` | **2 核 4G**（自动查询可用规格），**Huawei Cloud EulerOS 2.0**（自动查询最新公共镜像），40GB SSD，绑定上面的子网和安全组 |

```
              ┌──────────────── VPC 192.168.0.0/16 ────────────────┐
指定IP/32 ──► │ 安全组: 入站 TCP 8080 ← 指定IP   ┌─ 子网 192.168.1.0/24 ─┐ │
              │                                   │  ECS 2C4G · HCE 2.0  │ │
              │                                   └──────────────────────┘ │
              └────────────────────────────────────────────────────────────┘
```

## 文件

| 文件 | 作用 |
| --- | --- |
| `versions.tf` | Terraform / Provider 版本与 Provider 配置（凭证走环境变量） |
| `variables.tf` | 变量定义；`allowed_source_ip` 带校验，禁止 `0.0.0.0/0` |
| `main.tf` | 资源定义；规格和镜像通过 data source 自动查询 |
| `outputs.tf` | 输出 vpc_id、subnet_id、security_group_id、ecs_instance_id、ecs_private_ip 等 |
| `terraform.tfvars.example` | 参数示例，复制为 `terraform.tfvars` 后修改 |
| `terraform.tfstate` | **apply 后生成并提交**，是资源真实创建的证明 |
| `docs/run-log.md` | 验证链与 apply/destroy 的真实运行记录 |

## 使用

```bash
# 1. 凭证（PowerShell 用 $env:HW_ACCESS_KEY="..."）
export HW_ACCESS_KEY="你的AK"
export HW_SECRET_KEY="你的SK"

# 2. 参数：把 allowed_source_ip 改成自己的公网 IP（curl -s ifconfig.me）
cp terraform.tfvars.example terraform.tfvars

# 3. 验证链：先预览再创建
terraform fmt -recursive
terraform init
terraform validate
terraform plan          # 预期新建 5 个资源：vpc、subnet、secgroup、secgroup_rule、compute_instance
terraform apply

# 4. 实验完成并判题通过后清理，避免持续计费
terraform destroy
```

费用：VPC、子网、安全组免费；2C4G 按需 ECS 约 0.2 元/小时。

## 安全设计

- AK/SK 只通过环境变量 `HW_ACCESS_KEY` / `HW_SECRET_KEY` 传入，代码和 tfvars 中都没有凭证；
- 安全组只放通单个源 IP 的 8080 端口，变量校验拒绝 `0.0.0.0/0`；
- ECS 不设置登录密码、不绑定公网 IP，state 中不包含任何口令。
