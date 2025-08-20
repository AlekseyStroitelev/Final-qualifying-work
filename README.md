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
2. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок, так же в результате работы kubespray и последующего запуска sh скрипта c master-ноды, получаем kubernetes кластер с задеплоиным web-приложением и системой мониторинга, которые в свою очередь доступны из вне по 80 порту: </br>
   ![1_9](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_9.png) </br>

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform
---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)