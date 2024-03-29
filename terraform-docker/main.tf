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
  count = 1
  length = 4
  special = false
  upper = false
}


# INITIALIZE THE CONTAINERS

resource "docker_container" "nodered_container" {
  count = 1
  name  = join("-",["nodereeeeed", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
   # external = 1880
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

