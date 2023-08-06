variable "instance_type"{
  type    = string
  default = "t3a.nano"
}

variable "ingress_ports"{
  type    = list(number)
  default = [22,8500,8200,8300]
}

variable "cluster_machine_number"{
    type = number
    default = 3
}