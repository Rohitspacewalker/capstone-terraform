variable "instance_type" {
	type = string
}

variable "ami" {
	type = string
}

variable "instance_count" {
	type = string
}

variable "pub_sub_id" {
        type = string
}


variable "secgrp" {
        type = list(string)
}
