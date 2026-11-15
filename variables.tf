#variáveis para nome, região e endereço da rede - CIDR.

variable "project_name" {
  description = "Nome usado para identificar os recursos do projeto"
  type        = string
  default     = "atividade-final-aws"
}

variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Faixa de endereços da rede do projeto"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Faixa de endereços da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_cidr" {
  description = "Endereco IP autorizado a acessar a EC2 por SSH"
  type        = string
  default     = "127.0.0.1/32"
}

# Define o tamanho do computador virtual na AWS.
variable "instance_type" {
  description = "Tipo da instancia EC2 que executara as APIs"
  type        = string
  default     = "t3.micro"
}