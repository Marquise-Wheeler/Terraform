terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.7"

    }
  }
}


provider "docker" {}

# download nodered image
resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count = 2
  length = 4
  special = false
  upper = false
}


# INITIALIZE THE CONTAINERS

resource "docker_container" "nodered_container" {
  count = 2
  name  = join("-",["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
   # external = 1880
  }
}

#=========================
# OUTPUTS SECTION
#=========================

output "ip-address1" {
  value       = join(":", [docker_container.nodered_container[0].ip_address, docker_container.nodered_container[0].ports[0].external])
  description = "The private IP address and port of node_red server instance."
}

output "container-name1" {
  value       = docker_container.nodered_container[0].name
  description = "The name of the container 1"
}

output "ip-address2" {
  value       = join(":", [docker_container.nodered_container[1].ip_address, docker_container.nodered_container[1].ports[0].external])
  description = "The private IP address and port of node_red server instance."
}

output "container-name2" {
  value       = docker_container.nodered_container[1].name
  description = "The name of the container 2"
}

