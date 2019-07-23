#################
### Variables ###
#################

variable "access_key" {
  type        = "string"
  description = "AWS Access Key."
}

variable "secret_key" {
  type        = "string"
  description = "Your AWS Secret Key."
}

variable "ssh_public_key" {
  type        = "string"
  description = "Your public ssh key to access nodes"
}


##############
###  Nodes ###
##############
variable "worker_node_config" {
  type        = "map"
  description = "Configurable parameters specific to ec2 instance"

  default = {
    "instance"         = "t2.micro"    # 1 vCPU & 1 GB RAM
    "ami"              = "ami-005bdb005fb00e791"
    "root_volume_size" = 8
  }
}


#######################
### Additional Vars ###
#######################

variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a"]
}

variable "key_pair_name" {
  default = "aws_key"
}
