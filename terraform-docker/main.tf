terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.7"

    }
  }
}


provider "docker" {}

variable "ext_port" {
type = number
default = 1880
}

variable "int_port" {
type = number
default = 1880
}

variable "container_count" {
type = number
default = 1
}
# download nodered image
resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count = var.container_count
  length = 4
  special = false
  upper = false
}

# INITIALIZE THE CONTAINERS

resource "docker_container" "nodered_container" {
  count = var.container_count
  name  = join("-",["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = var.int_port
    external = var.ext_port
  }
}

#=========================
# OUTPUTS SECTION
#=========================

output "container-name" {
  value       = docker_container.nodered_container[*].name
  description = "The name of the container 1"
}

output "ip-address" {
  value       = [for i in  docker_container.nodered_container[*]: join(":", [i.ip_address],i.ports[*]["external"])]
  description = "The private IP address and port of node_red server instance."
}

