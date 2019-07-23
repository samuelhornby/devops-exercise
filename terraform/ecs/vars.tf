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

#######################
### Additional Vars ###
#######################

variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a"]
}
