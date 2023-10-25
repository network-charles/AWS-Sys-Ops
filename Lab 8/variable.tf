variable "account_id" {
  type    = string
  default = ""
}

variable "FederatedUserARN" {
  type    = string
  default = ""
}

variable "ubuntu" {
  type    = string
  default = "ami-0505148b3591e4c07"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "username" {
  type    = string
  default = "foo"
}

variable "password" {
  type    = string
  default = "foobarbaz"
}
