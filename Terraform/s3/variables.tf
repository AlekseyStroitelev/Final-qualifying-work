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

#Storage
variable "netology_bucket" {
  type = object({
    bucket                = string
    max_size              = number
    default_storage_class = string
  })
  default = {
    bucket                = "alexey1406"
    max_size              = 1073741824
    default_storage_class = "STANDARD"
  }
}
