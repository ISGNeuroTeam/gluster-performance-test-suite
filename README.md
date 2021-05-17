# Инструменты тестирования Glusterfs

### Введение.
Для тестирования производительности предлагается использовать инструмент Gluster performance test suite (далее Test Suite):
https://github.com/ISGNeuroTeam/gluster-performance-test-suite

Это немного поправленный Gluster performance test suite. Оригинал здесь:
https://github.com/gluster/gluster-performance-test-suite.

Цель использования Test Suite:
- Получить сведения о времени выполнения основных файловых операций на распределенной файловой системе
- Получить профиль нагрузки  GlusterFS - сведения о задержке (latency) при выполнении операций GlusterFS 
- Дополнительно иметь возможность создать кластер GlusterFS  на “чистой” инфраструктуре, на котором впоследствии будут проводиться тесты.

### Описание
Test Suite осуществляет тесты на уже развернутой GlusterFS. Однако, есть возможность сначала развернуть GlusterFS в нужной конфигурации на “чистой” инфраструктуре, а затем на развернутой файловой системе выполнить тесты. 
GTS выполняет следующие тесты:
- Small file test 
- Large file test
- Профилирование нагрузки на GlusterFS во время выполнения тестов выше (синтетических тестов) или во время нагрузки приложения

### Small file test
Оригинальный репозиторий находится тут: https://github.com/distributed-system-analysis/smallfile . 
Тест выполняет типовые файловые операции: "create", "ls-l", "chmod", "stat", "read", "append", "rename", "delete-renamed", "mkdir", "rmdir", "cleanup". Тест файловой операции определяется ее параметрами: типом операции, количеством файлов, количество тредов на сервер, где выполняется тест. 
Результатами выполнения теста является: скорость выполнения файловых операций (файлов/сек, операций/сек, скорости выполнения операций в мб/сек), задержка (latency) при выполнении файловой операции.

### Large file test
***В РАЗРАБОТКЕ***

### Профилирование нагрузки во время проведения тестов.
Во время проведения тестов выполняется профилирование нагрузки на GlusterFs. Осуществляются следующие виды профилирования
- Профилирование на стороне сервера
- Профилирование на стороне клиента (***В РАЗРАБОТКЕ***)

Профилирование на стороне сервера это...
Профилирование на стороне клиента это…

Результатом профилирования является отчет по количеству файловых операций GlusterFs и средняя задержка при выполнении той или иной файловой операции. Список операций можно посмотреть тут: https://github.com/bengland2/gluster-profile-analysis
(appendix: detailed list of FOPs). Однако, для получения более точных сведений, вероятно, лучше обратиться к исходникам GlusterFs (https://github.com/gluster/glusterfs).


### Как это работает.
Test Suite использует ansible для выполнения задач развертывания инфраструктуры и тестирования. Все задачи (tasks) декларированы в файле gluster-performance-test-suite/perftest.yml.

#### Описание задач (tasks) :
| №  	| Имя задачи  	|  Описание 	|   Примечание	|
|---	|---	|---	|---	|
|  1 	| setup passwordless ssh from control machine to cluster  	| Распространяет ключи по серверам Gluster  и обеспечивает беспарольное подключение. Распространение ключей происходит с помощью предоставленного пользователем пароля. Пароль хранится в защищенном виде с использованием ansible password vault.  	|  Роль “отключена” (закомментирована). \ Кому хочется заморочиться с ansible password vault, необходимо раскомментировать секцию задачи (комментарий #  Distributing/deleting keys via password provided access (via ansible vault)) и ознакомиться с инструкцией по работе с ansible password vault в оригинальном репозитории Gluster performance test suite. \ Если использовать ansible password vault, то надо так же  раскомментировать задачу "distribute the ssh key to the remote hosts" в файле gluster-performance-test-suite/roles/gluster-client-setup/tasks/main.yml . Эта задача используется для распространения ключей на клиентские машины GlusterFs кластера	|
|  2 	|  delete the ssh key if specifically asked 	|    Удаляет ключи после проведения операций.	| Роль “отключена” (закомментирована).  \ Кому хочется заморочиться с ansible password vault, необходимо раскомментировать секцию задачи (комментарий #  Distributing/deleting keys via password provided access (via ansible vault)) и ознакомиться с инструкцией по работе с ansible password vault в оригинальном репозитории Gluster performance test suite. \ Если использовать ansible password vault, то надо так же  раскомментировать задачу "distribute the ssh key to the remote hosts" в файле gluster-performance-test-suite/roles/gluster-client-setup/tasks/main.yml . Эта задача используется для распространения ключей на клиентские машины GlusterFs кластера 	|
|  3 	|   Unmount glusterfs from clients \ Check if gluster is installed \ Cleanup delete gluster volume and lv \ Common setup on gluster machines \ Remove gluster and its repositories \ Setup upstream repository \ Subscribe to RHSM  \ Setup custom build repository  \ Install and start gluster \ Client specific setup on gluster machines \ Setting up backend and creating a volume  \ roles:      - gluster.infra       - gluster.cluster \ Mount gluster volume on all the clients	| Готовят инфраструктуру под GlusterFs и развертывают кластер GlusterFs на подготовленной инфраструктуре  	|  Отключена (закомментирована) по умолчанию. Если необходимо создать инфраструктуру и кластер, необходимо раскомментировать роли с комментарием “Gluster infra/cluster”   	|
|   4	|   	|   Проведение тестов производительности	|   	|

#  Где смотреть логи:

- var/log/ansible.log - лог Ansible. 
По умолчанию Ansible пишет вывод в консоль и не пишет в файл. Если требуется писать лог в файл, можно включить логирование здесь:

```
[root@mgmt gluster-performance-test-suite]# cat /root/gluster-performance-test-suite/ansible.cfg
[defaults]
...
log_path = /var/log/ansible.log
```

- /var/log/PerfTestClient.log - лог скрипта smallfile-test-for-fuse.sh. Это bash скрипт-обвязка вокруг smallfile_cli.py - основного скрипта small-files теста.
- Логи smallfiletest ...

### Использование
В Test Suite есть следующие логические роли для серверов:
- Сервер управления  - здесь будет располагаться репозиторий, отсюда будут запускаться тесты. Управляющий сервер должен быть один.
- Сервер распределенной файловой системы - десь будут установлен сервер GlusterFs, создан volume, GlusterFs будет подготовлена к экспорту.
- Клиент распределенной файловой системы - здесь будут установлены клиентские библиотеки GlusterFs, будет смонтировать GlusterFs ресурс.

Роли клиента может быть совмещена с ролью сервера могут быть совмещены. Роль управляющего сервера может быть совмещена как с ролью клиента, так и с ролью сервера, так и с ролями клиента и сервера одновременно. Роли и их совмещение определяются конфигурационным файлом hosts (описано ниже).
Packages gluster.infra, gluster.cluster should be present on control machine. The user executing this script has to have an ssh key configured. Python3 should be existing on the target machines.

### Пререквизиты:
1. Должен быть беспарольный доступ (по ключам) с сервера управления до серверов и клиентов GlusterFs. 
Если хочется автоматизировать распространение ключей с помощью Ansible, см “Описание задач (tasks) п.1”
2. На всех машинах должен быть python 3
3. На всех машинах должен быть настроен резолвинг имен (DNS или /etc/hosts).
4. На сервере управления установить ansible. Для этого:
```
sudo yum install epel-release
sudo yum install ansible
```
4. На сервере управления установить gluster-ansible. Для этого:
- Сконфигурировать репозиторий
Репозиториии взять тут :
https://copr-be.cloud.fedoraproject.org/results/sac/gluster-ansible/ https://download.copr.fedorainfracloud.org/results/sac/gluster-ansible/

Пример конфигурации:
```
# vi  /etc/yum.repos.d/gluster-ansible-repo.repo

[gluster-ansible-repo]
name= Gluster-ansible packages for CentOS 7
baseurl=https://copr-be.cloud.fedoraproject.org/results/sac/gluster-ansible/epel-7-x86_64/ 
gpgkey = https://copr-be.cloud.fedoraproject.org/results/sac/gluster-ansible/pubkey.gpg
```
- Установить репозиторий
```
yum install gluster-ansible
```
5. На серверах распределенной файловой системы должны быть установлены GlusterFS version 3.2 или выше
```
# sudo yum install wget centos-release-gluster -y
# sudo yum install glusterfs-server -y
```
6. На сервере с ролью master_server (см настройку файла hosts) должен быть установлен ansible. Для этого:
```
sudo yum install epel-release
sudo yum install ansible
```
7. На серверах-клиентах распределенной фс должен быть установлен репозиторий small files и размещен следующим образом:
```
git clone  https://github.com/distributed-system-analysis/smallfile
mkdir /small-files
mv /smallfile/ /small-files/
```

### Настройка теста:
Настройка и запуск теста будет вестись от пользователя root в директории /root.
1. Клонировать Test Suite и разместить его,  например, в директории root:

```
git clone https://github.com/ISGNeuroTeam/gluster-performance-test-suite
```

2. В случае, если планируется использовать  Test Suite для подготовки инфраструктуры под кластер Gluster fs и развернуть с помощью Test Suite кластер Gluster fs, необходимо:
- раскомментировать роли в gluster-performance-test-suite/perftest.yml помеченные как ‘Gluster infra/cluster’
- создать директорию для конфигурационных файлов и скопировать туда шаблоны конфигураций инфраструктуры (gluster infra) и кластера Glusterfs (gluster cluster) :
    
```
# mkdir ~/config-for-cluster1
# cp backend-vars.sample ~/config-for-cluster1/cluster1-backend-vars.yml
# cp cleanup-vars.sample ~/config-for-cluster1/cluster1-cleanup-vars.yml
# cp hosts.sample ~/config-for-cluster1/hosts
```
- Создать в файлах ~/config-for-cluster1/cluster1-backend-vars.yml и ~/config-for-cluster1/cluster1-cleanup-vars.yml конфигурацию для инфраструктуры (gluster infra) и кластера Glusterfs (gluster cluster). 

Пояснения к шаблону конфигурации backend-vars.sample. На физических дисках (JBOD - just a bunch of disks), имя устройства для которых /dev/vdb создается физический том pvname: '/dev/vdb', на котором создается LMV thinpool (тонкий/разреженный том) GLUSTER_pool1 объемом 5 Гб для данных и 1 Гб для метаданных. На пуле создается volume group vgname: ‘GLUSTER_vg1’, на котором создается логический том lvname: ‘GLUSTER_lv1’, на котором создается брик /gluster/brick1, который включается в GlusterFS volume 'testvol'. 

```
# cat ~/config-for-cluster1/cluster1-backend-vars.yml
gluster_infra_disktype: JBOD

gluster_infra_volume_groups:
  - { vgname: 'GLUSTER_vg1', pvname: '/dev/vdb' }

gluster_infra_thinpools:
  - {vgname: 'GLUSTER_vg1', thinpoolname: 'GLUSTER_pool1', thinpoolsize: '5G', poolmetadatasize: '1G'}

gluster_infra_lv_logicalvols:
  - { vgname: 'GLUSTER_vg1', thinpool: 'GLUSTER_pool1', lvname: 'GLUSTER_lv1', lvsize: '5G' }

gluster_infra_mount_devices:
  - { path: '/gluster/brick1', vgname: 'GLUSTER_vg1', lvname: 'GLUSTER_lv1' }

gluster_cluster_volume: 'testvol'
gluster_cluster_bricks: '/gluster/brick1'
```

- В соответствии с шаблоном backend-vars.sample конфигурируется и cleanup-vars.sample - набор переменных для удаления инфраструктуры и кластера GlusterFs в случае повторного запуска Test Suite/
```
# cat ~/config-for-cluster1/cluster1-cleanup-vars.yml
gluster_volumes: testvol
gluster_infra_reset_mnt_paths:
  - /gluster/brick1

gluster_infra_reset_volume_groups:
  - GLUSTER_vg1
```

Более детально о конфигурировании инфраструктуры: ...


Создать файл hosts и привести его в соответствии с имеющейся инфраструктурой Gluster FS или созданной на п.3

```
# cp hosts.sample ~/config-for-cluster1/hosts
# cat ~/config-for-cluster1/hosts

[all:vars]
gluster_volumes=testvol
gluster_cluster_replica_count=3
#gluster_cluster_disperse_count=3
node0=gluster1
build="upstream"
#build="custom"
#custom_build_url="https://download.gluster.org/pub/gluster/glusterfs/8/8.1/Fedora/fedora-32/x86_64/"
#custom_build_repo_url=
#custom_build_path=/tmp/rpms/
benchmarking_tools=0
backend_variables=~/config-for-cluster1/cluster1-backend-vars.yml
cleanup_vars=~/config-for-cluster1/cluster1-cleanup-vars.yml
rhsm_vars=~/config-for-cluster1/rhsm-vars.yml
use_rhsm_repository=0
tool="smallfile"
download_results_at_location=~/config-for-cluster1/

[control]
control_machine ansible_host=fsmgmt ansible_connection=local

[master_server]
gluster1

[master_client]
gluster1

[cluster_servers]
gluster1
gluster2
gluster3

[cluster_clients]
gluster1 should_mount_from=gluster1
gluster2 should_mount_from=gluster2
gluster2 should_mount_from=gluster2

[cluster_machines:children]
cluster_servers
cluster_clients


```


### Описание теста Smallfiles


Основной репозиторий находится тут: https://github.com/distributed-system-analysis/smallfile
/root/${Operations[$j]}-profile-fuse.txt
Large files

### Планы:
Сделать условное выполнение тасков для инфраструктурных ролей (и не только):
https://stackoverflow.com/questions/42436532/how-can-i-skip-role-in-ansible


