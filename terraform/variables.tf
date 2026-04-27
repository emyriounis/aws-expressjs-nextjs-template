variable "name" {
  type    = string
  default = "fs-template"
}

variable "enviroment" {
  type    = string
  default = "prod"
}

variable "base_domain" {
  type = string
}

variable "runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "logs_retention" {
  type    = number
  default = 30
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "global_region" {
  type    = string
  default = "us-east-1"
}

# variable "azs" {
#   type    = list(string)
#   default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
# }
# 
# variable "cidr" {
#   type    = string
#   default = "10.0.0.0/16"
# }
#
# variable "public_subnets" {
#   type    = list(string)
#   default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }
# 
# variable "private_subnets" {
#   type    = list(string)
#   default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
# }
# 
# variable "database_subnets" {
#   type    = list(string)
#   default = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
# }

variable "lambda_memory_size" {
  type    = number
  default = 2048
}