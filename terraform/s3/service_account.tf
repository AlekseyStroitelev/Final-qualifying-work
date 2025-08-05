#Заведение сервисного аккаунта
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "Service account for S3 Bucket"
}

#Назначение ролей сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_binding" "bucket-sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "bucket-sa-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
  ]
}

#Генерация статического ключа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}
