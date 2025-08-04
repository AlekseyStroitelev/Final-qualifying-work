# Создание бакета с использованием статического ключа
resource "yandex_storage_bucket" "netology_bucket" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = var.netology_bucket.bucket
  max_size              = var.netology_bucket.max_size
  default_storage_class = var.netology_bucket.default_storage_class
  versioning {
    enabled = true
  }
}
