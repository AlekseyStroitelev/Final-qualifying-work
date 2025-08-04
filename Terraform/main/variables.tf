variable "cloud_id" {
  type        = string
  default     = "b1gj2n9n1isp9elpqjgg"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gaq0q0qlsinbdr072s"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

#Network
variable "vpc_name" {
  type        = string
  default     = "Kubernetes"
  description = "VPC network & subnet name"
}

#Subnet
variable "subnet" {
  type = map(object({
    name = string
    zone = string
    cidr = list(string) 
  }))
  default = {
    k8s-a = {
      name = "k8s-a"
      zone = "ru-central1-a"
      cidr = ["192.168.10.0/24"]
    }
    k8s-b = {
      name = "k8s-b"
      zone = "ru-central1-b"
      cidr = ["192.168.20.0/24"]
    }
    k8s-d = {
      name = "k8s-d"
      zone = "ru-central1-d"
      cidr = ["192.168.30.0/24"]
    }
  }
}
