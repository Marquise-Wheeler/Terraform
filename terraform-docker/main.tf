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

# start the container

resource "docker_container" "nodered_container" {
  name  = "nodered"
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
    external = 1880
  }
}

# CONFIGURE OUTPUTS
output "instance_ip_addr" {
  value       = docker_container.nodered_container.ip_address
  description = "The private IP address of the main server instance."
}

