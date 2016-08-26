variable "name" {
    description = "Name of the default instance. Used to build the DNS name."
    default     = "dev"
}

variable "myvpc_id" {}

variable "mysubnet_id" {}

variable "mysecurity_groups" {}

variable "myfs_id" {}

variable "myhome_ip" {}

variable "mykey_name" {}

variable "myinstance_type" {
    default = "r3.2xlarge"
}

variable "myspot_price" {}

variable "block_duration" {
    description = "Length of time to run the spot instance in minutes (must be multiple of 60)."
    default = 360
}

variable "zone_id" {}