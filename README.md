# Дипломный практикум в Yandex.Cloud
Цели:
1. Подготовить облачную инфраструктуру на базе облачного провайдера Yandex Cloud.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

1. Создан сервисный аккаунт `bucket-sa` для S3 bucket. Данный бакет в дальнейшем будет использоватьяс для хранения state-файла terraform: </br>
    ![1_2](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_2.png)
2. Создан S3 bucket с целью использования в качестве бекенд для хранения стейт файла, так же создана VPC с подсетями в разных зонах доступности. Команды `terraform apply`, `terraform destroy` отрабатывают без дополнительных действий: </br>
    ![1_3](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_3.png) </br>
    ![1_4](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_4.png) </br>
    ![1_5](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_5.png) </br>
    ![1_6](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_6.png) </br>
    ![1_7](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_7.png) </br>

---
### Создание Kubernetes кластера

1. Так как данное задание не включает требование создания HA кластера, то упустим тот факт, что etcd работает по RAFT и создадим кластер из трех машин, одна master-нода и две worker-ноды:
   ![1_8](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_8.png) </br>
Манифесты на развертывание инфраструктцры находятся [здесь](https://github.com/AlekseyStroitelev/final-qualifying-work/tree/main/terraform), так же реализована функция автоматического создания inventory файла для kubespray. Не хитрыми действиями по средствам набора ansible ролей (kubespray) был развернут kubernetes кластер. В одну из ролей были добавлены функции копирования на master ноду некоторых манифестов для k8s и скрипт запуска их применения. Kubespray находится [здесь](https://github.com/AlekseyStroitelev/final-qualifying-work/tree/main/kubespray)
2. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок, так же в результате работы kubespray и последующего запуска sh скрипта c master-ноды, получаем kubernetes кластер с задеплоиным web-приложением и системой мониторинга, которые в свою очередь доступны из вне на 80 порту: </br>
   ![1_9](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_9.png) </br>
Листинг манифестов и скрипта [тут](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/kubespray/roles/kubernetes/client/tasks/main.yml) начиная со строки 116.

---
### Создание тестового приложения

1. Git репозиторий с тестовым приложением и Dockerfile [тут](https://github.com/AlekseyStroitelev/app-config)
2. Регистри с собранным docker image является [DockerHub](https://hub.docker.com/repository/docker/makaron7321/nginx-test-app/general)
3. Как описано в предыдущем пункте,приложение доступно на 80 порту, с добавлением в URL /app:</br>
  ![1_10](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_10.png)

---
### Подготовка cистемы мониторинга и деплой приложения

Приложение уже задеплоено, скриншот был в предыдущем пункте.
Система мониторинга развернута, UI Grafana доступен так же на 80 порту: </br>
  ![1_11](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_11.png)

### Деплой инфраструктуры в terraform pipeline

1. Так как на первом этапе мы не воспользовались [Terraform Cloud](https://app.terraform.io/), то настроим на автоматический запуск и применение конфигурации terraform из нашего git-репозитория в GitHub. Для демонстрации даннго функционала внесем изменения в `network.tf` и добавим еще одну подсеть с именем `test-action`. Результат:

![1_12](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_12.png)</br>

![1_13](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_13.png)</br>

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Будем использовать GitHub Actions.

Добавляем необходимые секреты в соотвествующий репозиторий и не забываем про `workflow`.
Делаем простой commit и push в репо с исходниками нашего app, в результате происходит сборка образа и его push в dockerhub, шаг с деплоем в кластер скипается:

![1_14](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_14.png)</br>

Далее пробуем внести изменения в наш `index.html`(для наглядности) и делаем `git tag v1.0.4` и `git push origin v1.0.4`, собирается новый образ, пушится в dockerhub и происходит деплой новой версии в кластер:</br>

![1_14](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_15.png)</br>

Видим, что надпись нат картинкой изменилась:</br>

![1_15](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_15.png)</br>

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)