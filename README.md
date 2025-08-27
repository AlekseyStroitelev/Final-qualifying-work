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

1. Так как на первом этапе мы не воспользовались [Terraform Cloud](https://app.terraform.io/), то настроим на автоматический запуск и применение конфигурации terraform из нашего git-репозитория в GitHub. Для демонстрации даннго функционала внесем изменения в `network.tf` и добавим еще одну подсеть с именем `test-actions`. Результат:

<details>
    <summary>RAW_LOGS</summary>

2025-08-27T10:15:56.4801562Z Current runner version: '2.328.0'
2025-08-27T10:15:56.4824907Z ##[group]Runner Image Provisioner
2025-08-27T10:15:56.4826034Z Hosted Compute Agent
2025-08-27T10:15:56.4826602Z Version: 20250818.377
2025-08-27T10:15:56.4827620Z Commit: 3c593e9f75fe0b87e893bca80d6e12ba089c61fc
2025-08-27T10:15:56.4828344Z Build Date: 2025-08-18T14:52:18Z
2025-08-27T10:15:56.4828904Z ##[endgroup]
2025-08-27T10:15:56.4829516Z ##[group]Operating System
2025-08-27T10:15:56.4830099Z Ubuntu
2025-08-27T10:15:56.4830596Z 24.04.2
2025-08-27T10:15:56.4831129Z LTS
2025-08-27T10:15:56.4831623Z ##[endgroup]
2025-08-27T10:15:56.4832164Z ##[group]Runner Image
2025-08-27T10:15:56.4832804Z Image: ubuntu-24.04
2025-08-27T10:15:56.4833351Z Version: 20250818.1.0
2025-08-27T10:15:56.4834390Z Included Software: https://github.com/actions/runner-images/blob/ubuntu24/20250818.1/images/ubuntu/Ubuntu2404-Readme.md
2025-08-27T10:15:56.4836038Z Image Release: https://github.com/actions/runner-images/releases/tag/ubuntu24%2F20250818.1
2025-08-27T10:15:56.4837537Z ##[endgroup]
2025-08-27T10:15:56.4838662Z ##[group]GITHUB_TOKEN Permissions
2025-08-27T10:15:56.4840807Z Contents: read
2025-08-27T10:15:56.4841417Z Metadata: read
2025-08-27T10:15:56.4841966Z Packages: read
2025-08-27T10:15:56.4842544Z ##[endgroup]
2025-08-27T10:15:56.4844688Z Secret source: Actions
2025-08-27T10:15:56.4845421Z Prepare workflow directory
2025-08-27T10:15:56.5413589Z Prepare all required actions
2025-08-27T10:15:56.5450549Z Getting action download info
2025-08-27T10:15:56.9655916Z Download action repository 'actions/checkout@v4' (SHA:08eba0b27e820071cde6df949e0beb9ba4906955)
2025-08-27T10:15:57.1367609Z Download action repository 'hashicorp/setup-terraform@v2' (SHA:633666f66e0061ca3b725c73b2ec20cd13a8fdd1)
2025-08-27T10:15:57.9114966Z Download action repository 'actions/upload-artifact@v4' (SHA:ea165f8d65b6e75b540449e92b4886f43607fa02)
2025-08-27T10:15:58.0933292Z Complete job name: Terraform
2025-08-27T10:15:58.1609151Z ##[group]Run actions/checkout@v4
2025-08-27T10:15:58.1610120Z with:
2025-08-27T10:15:58.1610749Z   repository: AlekseyStroitelev/final-qualifying-work
2025-08-27T10:15:58.1611603Z   token: ***
2025-08-27T10:15:58.1612098Z   ssh-strict: true
2025-08-27T10:15:58.1612584Z   ssh-user: git
2025-08-27T10:15:58.1613087Z   persist-credentials: true
2025-08-27T10:15:58.1613641Z   clean: true
2025-08-27T10:15:58.1614144Z   sparse-checkout-cone-mode: true
2025-08-27T10:15:58.1614723Z   fetch-depth: 1
2025-08-27T10:15:58.1615201Z   fetch-tags: false
2025-08-27T10:15:58.1615693Z   show-progress: true
2025-08-27T10:15:58.1616205Z   lfs: false
2025-08-27T10:15:58.1616888Z   submodules: false
2025-08-27T10:15:58.1617414Z   set-safe-directory: true
2025-08-27T10:15:58.1618208Z env:
2025-08-27T10:15:58.1618677Z   TF_VERSION: 1.5.0
2025-08-27T10:15:58.1619176Z   TF_DIR: terraform/main
2025-08-27T10:15:58.1619967Z   TF_VAR_token: ***
2025-08-27T10:15:58.1620497Z   TF_VAR_cloud_id: ***
2025-08-27T10:15:58.1621082Z   TF_VAR_folder_id: ***
2025-08-27T10:15:58.1621660Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:15:58.1622363Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:15:58.1622899Z ##[endgroup]
2025-08-27T10:15:58.2672881Z Syncing repository: AlekseyStroitelev/final-qualifying-work
2025-08-27T10:15:58.2674848Z ##[group]Getting Git version info
2025-08-27T10:15:58.2675823Z Working directory is '/home/runner/work/final-qualifying-work/final-qualifying-work'
2025-08-27T10:15:58.2677540Z [command]/usr/bin/git version
2025-08-27T10:15:58.2758270Z git version 2.51.0
2025-08-27T10:15:58.2783869Z ##[endgroup]
2025-08-27T10:15:58.2803636Z Temporarily overriding HOME='/home/runner/work/_temp/4b8247fa-90f4-4f42-8468-a917a52764c4' before making global git config changes
2025-08-27T10:15:58.2805170Z Adding repository directory to the temporary git global config as a safe directory
2025-08-27T10:15:58.2809249Z [command]/usr/bin/git config --global --add safe.directory /home/runner/work/final-qualifying-work/final-qualifying-work
2025-08-27T10:15:58.2842669Z Deleting the contents of '/home/runner/work/final-qualifying-work/final-qualifying-work'
2025-08-27T10:15:58.2845467Z ##[group]Initializing the repository
2025-08-27T10:15:58.2849808Z [command]/usr/bin/git init /home/runner/work/final-qualifying-work/final-qualifying-work
2025-08-27T10:15:58.2963356Z hint: Using 'master' as the name for the initial branch. This default branch name
2025-08-27T10:15:58.2964627Z hint: is subject to change. To configure the initial branch name to use in all
2025-08-27T10:15:58.2965629Z hint: of your new repositories, which will suppress this warning, call:
2025-08-27T10:15:58.2966511Z hint:
2025-08-27T10:15:58.2967435Z hint: 	git config --global init.defaultBranch <name>
2025-08-27T10:15:58.2968107Z hint:
2025-08-27T10:15:58.2968737Z hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
2025-08-27T10:15:58.2970308Z hint: 'development'. The just-created branch can be renamed via this command:
2025-08-27T10:15:58.2971828Z hint:
2025-08-27T10:15:58.2972734Z hint: 	git branch -m <name>
2025-08-27T10:15:58.2973817Z hint:
2025-08-27T10:15:58.2975213Z hint: Disable this message with "git config set advice.defaultBranchName false"
2025-08-27T10:15:58.2977995Z Initialized empty Git repository in /home/runner/work/final-qualifying-work/final-qualifying-work/.git/
2025-08-27T10:15:58.2985102Z [command]/usr/bin/git remote add origin https://github.com/AlekseyStroitelev/final-qualifying-work
2025-08-27T10:15:58.3023298Z ##[endgroup]
2025-08-27T10:15:58.3024849Z ##[group]Disabling automatic garbage collection
2025-08-27T10:15:58.3028125Z [command]/usr/bin/git config --local gc.auto 0
2025-08-27T10:15:58.3056891Z ##[endgroup]
2025-08-27T10:15:58.3058554Z ##[group]Setting up auth
2025-08-27T10:15:58.3064454Z [command]/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
2025-08-27T10:15:58.3095595Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
2025-08-27T10:15:58.3443935Z [command]/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
2025-08-27T10:15:58.3473439Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
2025-08-27T10:15:58.3689072Z [command]/usr/bin/git config --local http.https://github.com/.extraheader AUTHORIZATION: basic ***
2025-08-27T10:15:58.3723571Z ##[endgroup]
2025-08-27T10:15:58.3725222Z ##[group]Fetching the repository
2025-08-27T10:15:58.3733921Z [command]/usr/bin/git -c protocol.version=2 fetch --no-tags --prune --no-recurse-submodules --depth=1 origin +6aebce652a831ad733a93dce62b596fdf2da7a5d:refs/remotes/origin/main
2025-08-27T10:15:59.1784278Z From https://github.com/AlekseyStroitelev/final-qualifying-work
2025-08-27T10:15:59.1785707Z  * [new ref]         6aebce652a831ad733a93dce62b596fdf2da7a5d -> origin/main
2025-08-27T10:15:59.1815315Z ##[endgroup]
2025-08-27T10:15:59.1816454Z ##[group]Determining the checkout info
2025-08-27T10:15:59.1818295Z ##[endgroup]
2025-08-27T10:15:59.1822769Z [command]/usr/bin/git sparse-checkout disable
2025-08-27T10:15:59.1863121Z [command]/usr/bin/git config --local --unset-all extensions.worktreeConfig
2025-08-27T10:15:59.1891392Z ##[group]Checking out the ref
2025-08-27T10:15:59.1895153Z [command]/usr/bin/git checkout --progress --force -B main refs/remotes/origin/main
2025-08-27T10:15:59.2864911Z Switched to a new branch 'main'
2025-08-27T10:15:59.2868009Z branch 'main' set up to track 'origin/main'.
2025-08-27T10:15:59.2878548Z ##[endgroup]
2025-08-27T10:15:59.2915515Z [command]/usr/bin/git log -1 --format=%H
2025-08-27T10:15:59.2937962Z 6aebce652a831ad733a93dce62b596fdf2da7a5d
2025-08-27T10:15:59.3175049Z ##[group]Run hashicorp/setup-terraform@v2
2025-08-27T10:15:59.3176229Z with:
2025-08-27T10:15:59.3177152Z   terraform_version: 1.5.0
2025-08-27T10:15:59.3178238Z   cli_config_credentials_hostname: app.terraform.io
2025-08-27T10:15:59.3179754Z   terraform_wrapper: true
2025-08-27T10:15:59.3180642Z env:
2025-08-27T10:15:59.3181357Z   TF_VERSION: 1.5.0
2025-08-27T10:15:59.3182175Z   TF_DIR: terraform/main
2025-08-27T10:15:59.3183831Z   TF_VAR_token: ***
2025-08-27T10:15:59.3184730Z   TF_VAR_cloud_id: ***
2025-08-27T10:15:59.3185663Z   TF_VAR_folder_id: ***
2025-08-27T10:15:59.3186799Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:15:59.3188086Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:15:59.3189039Z ##[endgroup]
2025-08-27T10:16:00.2466929Z [command]/usr/bin/unzip -o -q /home/runner/work/_temp/ec2ee6c1-ecb6-4561-92a8-ef2e15fd544a
2025-08-27T10:16:00.7288554Z ##[group]Run terraform -chdir=terraform/main init \
2025-08-27T10:16:00.7289075Z [36;1mterraform -chdir=terraform/main init \[0m
2025-08-27T10:16:00.7289721Z [36;1m  -backend-config="access_key=***" \[0m
2025-08-27T10:16:00.7290228Z [36;1m  -backend-config="secret_key=***" \[0m
2025-08-27T10:16:00.7290632Z [36;1m  -backend-config="skip_credentials_validation=true" \[0m
2025-08-27T10:16:00.7291070Z [36;1m  -backend-config="skip_region_validation=true" \[0m
2025-08-27T10:16:00.7291482Z [36;1m  -backend-config="skip_metadata_api_check=true" \[0m
2025-08-27T10:16:00.7291860Z [36;1m  -backend-config="force_path_style=true"[0m
2025-08-27T10:16:00.7374243Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:00.7374560Z env:
2025-08-27T10:16:00.7374792Z   TF_VERSION: 1.5.0
2025-08-27T10:16:00.7375047Z   TF_DIR: terraform/main
2025-08-27T10:16:00.7375507Z   TF_VAR_token: ***
2025-08-27T10:16:00.7375809Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:00.7376151Z   TF_VAR_folder_id: ***
2025-08-27T10:16:00.7376514Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:00.7377069Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:00.7377489Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:00.7377918Z ##[endgroup]
2025-08-27T10:16:02.1904866Z [command]/home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572/terraform-bin -chdir=terraform/main init -backend-config=access_key=*** -backend-config=secret_key=*** -backend-config=skip_credentials_validation=true -backend-config=skip_region_validation=true -backend-config=skip_metadata_api_check=true -backend-config=force_path_style=true
2025-08-27T10:16:02.2107476Z 
2025-08-27T10:16:02.2108424Z [0m[1mInitializing the backend...[0m
2025-08-27T10:16:03.1459992Z [0m[32m
2025-08-27T10:16:03.1460714Z Successfully configured the backend "s3"! Terraform will automatically
2025-08-27T10:16:03.1463496Z use this backend unless the backend configuration changes.[0m
2025-08-27T10:16:04.4958008Z 
2025-08-27T10:16:04.4958504Z [0m[1mInitializing provider plugins...[0m
2025-08-27T10:16:04.4959082Z - Finding latest version of yandex-cloud/yandex...
2025-08-27T10:16:05.3208608Z - Installing yandex-cloud/yandex v0.154.0...
2025-08-27T10:16:06.7618655Z - Installed yandex-cloud/yandex v0.154.0 (self-signed, key ID [0m[1mE40F590B50BB8E40[0m[0m)
2025-08-27T10:16:06.7619513Z 
2025-08-27T10:16:06.7619910Z Partner and community providers are signed by their developers.
2025-08-27T10:16:06.7620886Z If you'd like to know more about provider signing, you can read about it here:
2025-08-27T10:16:06.7621848Z https://www.terraform.io/docs/cli/plugins/signing.html
2025-08-27T10:16:06.7622393Z 
2025-08-27T10:16:06.7623064Z Terraform has created a lock file [1m.terraform.lock.hcl[0m to record the provider
2025-08-27T10:16:06.7624122Z selections it made above. Include this file in your version control repository
2025-08-27T10:16:06.7625134Z so that Terraform can guarantee to make the same selections by default when
2025-08-27T10:16:06.7626078Z you run "terraform init" in the future.[0m
2025-08-27T10:16:06.7626932Z 
2025-08-27T10:16:06.7627729Z [0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
2025-08-27T10:16:06.7628381Z [0m[32m
2025-08-27T10:16:06.7628936Z You may now begin working with Terraform. Try running "terraform plan" to see
2025-08-27T10:16:06.7629843Z any changes that are required for your infrastructure. All Terraform commands
2025-08-27T10:16:06.7630786Z should now work.
2025-08-27T10:16:06.7631047Z 
2025-08-27T10:16:06.7631369Z If you ever set or change modules or backend configuration for Terraform,
2025-08-27T10:16:06.7632213Z rerun this command to reinitialize your working directory. If you forget, other
2025-08-27T10:16:06.7633202Z commands will detect it and remind you to do so if necessary.[0m
2025-08-27T10:16:06.7942525Z ##[group]Run terraform -chdir=terraform/main fmt -check -recursive
2025-08-27T10:16:06.7943021Z [36;1mterraform -chdir=terraform/main fmt -check -recursive[0m
2025-08-27T10:16:06.7982649Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:06.7982885Z env:
2025-08-27T10:16:06.7983060Z   TF_VERSION: 1.5.0
2025-08-27T10:16:06.7983269Z   TF_DIR: terraform/main
2025-08-27T10:16:06.7983679Z   TF_VAR_token: ***
2025-08-27T10:16:06.7983915Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:06.7984152Z   TF_VAR_folder_id: ***
2025-08-27T10:16:06.7984416Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:06.7984743Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:06.7985103Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:06.7985470Z ##[endgroup]
2025-08-27T10:16:06.8395042Z [command]/home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572/terraform-bin -chdir=terraform/main fmt -check -recursive
2025-08-27T10:16:06.8745371Z ##[group]Run terraform -chdir=terraform/main validate
2025-08-27T10:16:06.8745759Z [36;1mterraform -chdir=terraform/main validate[0m
2025-08-27T10:16:06.8785313Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:06.8785548Z env:
2025-08-27T10:16:06.8785724Z   TF_VERSION: 1.5.0
2025-08-27T10:16:06.8785921Z   TF_DIR: terraform/main
2025-08-27T10:16:06.8786334Z   TF_VAR_token: ***
2025-08-27T10:16:06.8786582Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:06.8787023Z   TF_VAR_folder_id: ***
2025-08-27T10:16:06.8787275Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:06.8787578Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:06.8787932Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:06.8788314Z ##[endgroup]
2025-08-27T10:16:06.9197871Z [command]/home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572/terraform-bin -chdir=terraform/main validate
2025-08-27T10:16:07.4542586Z [32m[1mSuccess![0m The configuration is valid.
2025-08-27T10:16:07.4543182Z [0m
2025-08-27T10:16:07.4657041Z ##[group]Run terraform -chdir=terraform/main plan -input=false -out=tfplan \
2025-08-27T10:16:07.4657602Z [36;1mterraform -chdir=terraform/main plan -input=false -out=tfplan \[0m
2025-08-27T10:16:07.4658159Z [36;1m  -var="token=***" \[0m
2025-08-27T10:16:07.4658463Z [36;1m  -var="cloud_id=***" \[0m
2025-08-27T10:16:07.4658754Z [36;1m  -var="folder_id=***" \[0m
2025-08-27T10:16:07.4697766Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:07.4698002Z env:
2025-08-27T10:16:07.4698173Z   TF_VERSION: 1.5.0
2025-08-27T10:16:07.4698378Z   TF_DIR: terraform/main
2025-08-27T10:16:07.4698771Z   TF_VAR_token: ***
2025-08-27T10:16:07.4699029Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:07.4699267Z   TF_VAR_folder_id: ***
2025-08-27T10:16:07.4699519Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:07.4699838Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:07.4700194Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:07.4700583Z ##[endgroup]
2025-08-27T10:16:07.5107810Z [command]/home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572/terraform-bin -chdir=terraform/main plan -input=false -out=tfplan -var=token=*** -var=cloud_id=*** -var=folder_id=***
2025-08-27T10:16:12.2813830Z [0m[1mdata.yandex_compute_image.ubuntu: Reading...[0m[0m
2025-08-27T10:16:12.2814963Z [0m[1myandex_vpc_network.kubernetes: Refreshing state... [id=enpi1a56agdvf1ajqtgu][0m
2025-08-27T10:16:13.5045705Z [0m[1mdata.yandex_compute_image.ubuntu: Read complete after 2s [id=fd8r4l3beu0odt9244b3][0m
2025-08-27T10:16:13.6677536Z [0m[1myandex_vpc_subnet.k8s-b: Refreshing state... [id=e2l2ibtbrh12oaebaebf][0m
2025-08-27T10:16:13.6678984Z [0m[1myandex_vpc_subnet.k8s-a: Refreshing state... [id=e9btisop7a6tlafmrojp][0m
2025-08-27T10:16:13.6679923Z [0m[1myandex_vpc_subnet.k8s-d: Refreshing state... [id=fl871p97bueequg2bqc8][0m
2025-08-27T10:16:13.8708701Z [0m[1myandex_compute_instance.master: Refreshing state... [id=fhm8oesaf7ufbevfpmrl][0m
2025-08-27T10:16:13.8741962Z [0m[1myandex_compute_instance.worker-1: Refreshing state... [id=epdga2bh98un6ig1m38r][0m
2025-08-27T10:16:13.8843726Z [0m[1myandex_compute_instance.worker-2: Refreshing state... [id=fv48ddu7oq8i51sjuisd][0m
2025-08-27T10:16:14.4315409Z [0m[1mdata.yandex_compute_instance.worker-1: Reading...[0m[0m
2025-08-27T10:16:14.4688043Z [0m[1mdata.yandex_compute_instance.master: Reading...[0m[0m
2025-08-27T10:16:14.5538028Z [0m[1mdata.yandex_compute_instance.worker-2: Reading...[0m[0m
2025-08-27T10:16:14.9434156Z [0m[1mdata.yandex_compute_instance.master: Read complete after 1s [id=fhm8oesaf7ufbevfpmrl][0m
2025-08-27T10:16:15.0227626Z [0m[1mdata.yandex_compute_instance.worker-2: Read complete after 0s [id=fv48ddu7oq8i51sjuisd][0m
2025-08-27T10:16:15.0382263Z [0m[1mdata.yandex_compute_instance.worker-1: Read complete after 1s [id=epdga2bh98un6ig1m38r][0m
2025-08-27T10:16:15.0557898Z 
2025-08-27T10:16:15.0558493Z Terraform used the selected providers to generate the following execution
2025-08-27T10:16:15.0559496Z plan. Resource actions are indicated with the following symbols:
2025-08-27T10:16:15.0560347Z   [32m+[0m create[0m
2025-08-27T10:16:15.0560617Z 
2025-08-27T10:16:15.0560870Z Terraform will perform the following actions:
2025-08-27T10:16:15.0561332Z 
2025-08-27T10:16:15.0561761Z [1m  # yandex_vpc_subnet.test-actions[0m will be created
2025-08-27T10:16:15.0562643Z [0m  [32m+[0m[0m resource "yandex_vpc_subnet" "test-actions" {
2025-08-27T10:16:15.0563501Z       [32m+[0m[0m created_at     = (known after apply)
2025-08-27T10:16:15.0564278Z       [32m+[0m[0m folder_id      = (known after apply)
2025-08-27T10:16:15.0565039Z       [32m+[0m[0m id             = (known after apply)
2025-08-27T10:16:15.0565812Z       [32m+[0m[0m labels         = (known after apply)
2025-08-27T10:16:15.0566566Z       [32m+[0m[0m name           = "test-actions1"
2025-08-27T10:16:15.0567761Z       [32m+[0m[0m network_id     = "enpi1a56agdvf1ajqtgu"
2025-08-27T10:16:15.0568920Z       [32m+[0m[0m v4_cidr_blocks = [
2025-08-27T10:16:15.0569633Z           [32m+[0m[0m "192.168.40.0/24",
2025-08-27T10:16:15.0570151Z         ]
2025-08-27T10:16:15.0570717Z       [32m+[0m[0m v6_cidr_blocks = (known after apply)
2025-08-27T10:16:15.0571486Z       [32m+[0m[0m zone           = "ru-central1-d"
2025-08-27T10:16:15.0571955Z     }
2025-08-27T10:16:15.0572116Z 
2025-08-27T10:16:15.0572499Z [1mPlan:[0m 1 to add, 0 to change, 0 to destroy.
2025-08-27T10:16:15.0573002Z [0m[90m
2025-08-27T10:16:15.0573619Z ─────────────────────────────────────────────────────────────────────────────[0m
2025-08-27T10:16:15.0574020Z 
2025-08-27T10:16:15.0574163Z Saved the plan to: tfplan
2025-08-27T10:16:15.0574426Z 
2025-08-27T10:16:15.0574737Z To perform exactly these actions, run the following command to apply:
2025-08-27T10:16:15.0575358Z     terraform apply "tfplan"
2025-08-27T10:16:15.0740380Z ##[group]Run actions/upload-artifact@v4
2025-08-27T10:16:15.0740670Z with:
2025-08-27T10:16:15.0740855Z   name: terraform-plan
2025-08-27T10:16:15.0741075Z   path: terraform/main/tfplan
2025-08-27T10:16:15.0741307Z   if-no-files-found: warn
2025-08-27T10:16:15.0741515Z   compression-level: 6
2025-08-27T10:16:15.0741712Z   overwrite: false
2025-08-27T10:16:15.0741912Z   include-hidden-files: false
2025-08-27T10:16:15.0742133Z env:
2025-08-27T10:16:15.0742305Z   TF_VERSION: 1.5.0
2025-08-27T10:16:15.0742502Z   TF_DIR: terraform/main
2025-08-27T10:16:15.0742892Z   TF_VAR_token: ***
2025-08-27T10:16:15.0743111Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:15.0743331Z   TF_VAR_folder_id: ***
2025-08-27T10:16:15.0743570Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:15.0743871Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:15.0744388Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:15.0744757Z ##[endgroup]
2025-08-27T10:16:15.2816180Z With the provided path, there will be 1 file uploaded
2025-08-27T10:16:15.2821213Z Artifact name is valid!
2025-08-27T10:16:15.2822325Z Root directory input is valid!
2025-08-27T10:16:15.6556547Z Beginning upload of artifact content to blob storage
2025-08-27T10:16:15.9470422Z Uploaded bytes 12473
2025-08-27T10:16:16.0192226Z Finished uploading artifact content to blob storage!
2025-08-27T10:16:16.0195949Z SHA256 digest of uploaded artifact zip is 0d8e5a19e0ecfc6ab2cff91d632a49247fba7fc8b299f925c407bc0d02b744c0
2025-08-27T10:16:16.0197624Z Finalizing artifact upload
2025-08-27T10:16:16.1653933Z Artifact terraform-plan.zip successfully finalized. Artifact ID 3862181526
2025-08-27T10:16:16.1654963Z Artifact terraform-plan has been successfully uploaded! Final size is 12473 bytes. Artifact ID is 3862181526
2025-08-27T10:16:16.1661695Z Artifact download URL: https://github.com/AlekseyStroitelev/final-qualifying-work/actions/runs/17263897965/artifacts/3862181526
2025-08-27T10:16:16.1774907Z ##[group]Run terraform -chdir=terraform/main apply -input=false -auto-approve
2025-08-27T10:16:16.1775456Z [36;1mterraform -chdir=terraform/main apply -input=false -auto-approve[0m
2025-08-27T10:16:16.1814346Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:16.1814583Z env:
2025-08-27T10:16:16.1814761Z   TF_VERSION: 1.5.0
2025-08-27T10:16:16.1814962Z   TF_DIR: terraform/main
2025-08-27T10:16:16.1815346Z   TF_VAR_token: ***
2025-08-27T10:16:16.1815579Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:16.1815818Z   TF_VAR_folder_id: ***
2025-08-27T10:16:16.1816070Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:16.1816411Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:16.1816954Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:16.1817340Z ##[endgroup]
2025-08-27T10:16:16.2223739Z [command]/home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572/terraform-bin -chdir=terraform/main apply -input=false -auto-approve
2025-08-27T10:16:20.7197125Z [0m[1mdata.yandex_compute_image.ubuntu: Reading...[0m[0m
2025-08-27T10:16:20.7200815Z [0m[1myandex_vpc_network.kubernetes: Refreshing state... [id=enpi1a56agdvf1ajqtgu][0m
2025-08-27T10:16:21.7530760Z [0m[1mdata.yandex_compute_image.ubuntu: Read complete after 1s [id=fd8r4l3beu0odt9244b3][0m
2025-08-27T10:16:21.9139053Z [0m[1myandex_vpc_subnet.k8s-d: Refreshing state... [id=fl871p97bueequg2bqc8][0m
2025-08-27T10:16:21.9140467Z [0m[1myandex_vpc_subnet.k8s-b: Refreshing state... [id=e2l2ibtbrh12oaebaebf][0m
2025-08-27T10:16:21.9142496Z [0m[1myandex_vpc_subnet.k8s-a: Refreshing state... [id=e9btisop7a6tlafmrojp][0m
2025-08-27T10:16:22.1163643Z [0m[1myandex_compute_instance.worker-2: Refreshing state... [id=fv48ddu7oq8i51sjuisd][0m
2025-08-27T10:16:22.1252846Z [0m[1myandex_compute_instance.master: Refreshing state... [id=fhm8oesaf7ufbevfpmrl][0m
2025-08-27T10:16:22.1508905Z [0m[1myandex_compute_instance.worker-1: Refreshing state... [id=epdga2bh98un6ig1m38r][0m
2025-08-27T10:16:22.6115125Z [0m[1mdata.yandex_compute_instance.worker-2: Reading...[0m[0m
2025-08-27T10:16:22.6275565Z [0m[1mdata.yandex_compute_instance.master: Reading...[0m[0m
2025-08-27T10:16:22.7125468Z [0m[1mdata.yandex_compute_instance.worker-1: Reading...[0m[0m
2025-08-27T10:16:23.1188002Z [0m[1mdata.yandex_compute_instance.master: Read complete after 0s [id=fhm8oesaf7ufbevfpmrl][0m
2025-08-27T10:16:23.1792128Z [0m[1mdata.yandex_compute_instance.worker-1: Read complete after 0s [id=epdga2bh98un6ig1m38r][0m
2025-08-27T10:16:23.2402104Z [0m[1mdata.yandex_compute_instance.worker-2: Read complete after 0s [id=fv48ddu7oq8i51sjuisd][0m
2025-08-27T10:16:23.2544372Z 
2025-08-27T10:16:23.2545096Z Terraform used the selected providers to generate the following execution
2025-08-27T10:16:23.2545935Z plan. Resource actions are indicated with the following symbols:
2025-08-27T10:16:23.2547195Z   [32m+[0m create[0m
2025-08-27T10:16:23.2547425Z 
2025-08-27T10:16:23.2547648Z Terraform will perform the following actions:
2025-08-27T10:16:23.2548021Z 
2025-08-27T10:16:23.2548367Z [1m  # yandex_vpc_subnet.test-actions[0m will be created
2025-08-27T10:16:23.2549116Z [0m  [32m+[0m[0m resource "yandex_vpc_subnet" "test-actions" {
2025-08-27T10:16:23.2549839Z       [32m+[0m[0m created_at     = (known after apply)
2025-08-27T10:16:23.2550469Z       [32m+[0m[0m folder_id      = (known after apply)
2025-08-27T10:16:23.2551079Z       [32m+[0m[0m id             = (known after apply)
2025-08-27T10:16:23.2551686Z       [32m+[0m[0m labels         = (known after apply)
2025-08-27T10:16:23.2552288Z       [32m+[0m[0m name           = "test-actions1"
2025-08-27T10:16:23.2552927Z       [32m+[0m[0m network_id     = "enpi1a56agdvf1ajqtgu"
2025-08-27T10:16:23.2553522Z       [32m+[0m[0m v4_cidr_blocks = [
2025-08-27T10:16:23.2554062Z           [32m+[0m[0m "192.168.40.0/24",
2025-08-27T10:16:23.2554489Z         ]
2025-08-27T10:16:23.2554953Z       [32m+[0m[0m v6_cidr_blocks = (known after apply)
2025-08-27T10:16:23.2555904Z       [32m+[0m[0m zone           = "ru-central1-d"
2025-08-27T10:16:23.2556388Z     }
2025-08-27T10:16:23.2556562Z 
2025-08-27T10:16:23.2557033Z [1mPlan:[0m 1 to add, 0 to change, 0 to destroy.
2025-08-27T10:16:25.7753419Z [0m[0m[1myandex_vpc_subnet.test-actions: Creating...[0m[0m
2025-08-27T10:16:27.4089535Z [0m[1myandex_vpc_subnet.test-actions: Creation complete after 1s [id=fl80agpgr74uvu6o44pe][0m
2025-08-27T10:16:28.3653882Z [0m[1m[32m
2025-08-27T10:16:28.3654464Z Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
2025-08-27T10:16:28.3655070Z [0m[0m[1m[32m
2025-08-27T10:16:28.3655384Z Outputs:
2025-08-27T10:16:28.3655549Z 
2025-08-27T10:16:28.3655718Z [0mnode_ips = {
2025-08-27T10:16:28.3656051Z   "master_private" = "192.168.10.10"
2025-08-27T10:16:28.3656465Z   "master_public" = "89.169.159.219"
2025-08-27T10:16:28.3657107Z   "worker1_private" = "192.168.20.10"
2025-08-27T10:16:28.3657543Z   "worker1_public" = "89.169.186.184"
2025-08-27T10:16:28.3657966Z   "worker2_private" = "192.168.30.10"
2025-08-27T10:16:28.3658376Z   "worker2_public" = "158.160.167.145"
2025-08-27T10:16:28.3658766Z }
2025-08-27T10:16:28.3806943Z ##[group]Run rm -f terraform/main/tfplan
2025-08-27T10:16:28.3807338Z [36;1mrm -f terraform/main/tfplan[0m
2025-08-27T10:16:28.3807647Z [36;1mrm -f terraform/main/.terraform.lock.hcl[0m
2025-08-27T10:16:28.3846573Z shell: /usr/bin/bash -e {0}
2025-08-27T10:16:28.3847105Z env:
2025-08-27T10:16:28.3847352Z   TF_VERSION: 1.5.0
2025-08-27T10:16:28.3847557Z   TF_DIR: terraform/main
2025-08-27T10:16:28.3847944Z   TF_VAR_token: ***
2025-08-27T10:16:28.3848171Z   TF_VAR_cloud_id: ***
2025-08-27T10:16:28.3848401Z   TF_VAR_folder_id: ***
2025-08-27T10:16:28.3848645Z   AWS_ACCESS_KEY_ID: ***
2025-08-27T10:16:28.3848955Z   AWS_SECRET_ACCESS_KEY: ***
2025-08-27T10:16:28.3849310Z   TERRAFORM_CLI_PATH: /home/runner/work/_temp/c8321ad8-9761-4396-a7bc-b1cbb37ee572
2025-08-27T10:16:28.3849692Z ##[endgroup]
2025-08-27T10:16:28.3974287Z Post job cleanup.
2025-08-27T10:16:28.4883029Z [command]/usr/bin/git version
2025-08-27T10:16:28.4917424Z git version 2.51.0
2025-08-27T10:16:28.4960482Z Temporarily overriding HOME='/home/runner/work/_temp/b7607607-31f0-458b-8891-58fa8b5a2209' before making global git config changes
2025-08-27T10:16:28.4961781Z Adding repository directory to the temporary git global config as a safe directory
2025-08-27T10:16:28.4967212Z [command]/usr/bin/git config --global --add safe.directory /home/runner/work/final-qualifying-work/final-qualifying-work
2025-08-27T10:16:28.5001509Z [command]/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
2025-08-27T10:16:28.5033314Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
2025-08-27T10:16:28.5259396Z [command]/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
2025-08-27T10:16:28.5279221Z http.https://github.com/.extraheader
2025-08-27T10:16:28.5291490Z [command]/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
2025-08-27T10:16:28.5321231Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
2025-08-27T10:16:28.5642760Z Cleaning up orphan processes

    </details></br>

![1_12](https://github.com/AlekseyStroitelev/final-qualifying-work/blob/main/screenshots/1_12.png)</br>

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