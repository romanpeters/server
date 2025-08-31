locals {
  hosts    = yamldecode(file("${path.module}/../hosts.yml"))
  services = yamldecode(file("${path.module}/../services.yml"))
}
