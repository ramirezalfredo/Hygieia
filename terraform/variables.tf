variable "ssh_key_private" {
  type    = "string"
  default = "/Users/alfredo/cloudmaster.pem"
}

variable "k8s_master_ip" {
  type    = "string"
  default = "192.168.1.200"
}

variable "mongodb_ip" {
  type    = "string"
  default = "192.168.3.200"
}

variable "images" {
  type = "map"

  default = {
    us-east-2 = "image-1234"
    us-west-2 = "image-4567"
  }
}

variable "zones" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
