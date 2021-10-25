# Деплой Nginx Hello
Ansible с установленным модулем community.kubernetes.helm, позволяет деплоить конфигурации 
с индивидуальными параметрами для разных стендов Разработкаи/Тестирование/Прод.

Конфигурации меняются в каталогах inventory/\*/group_vars/\*/*.yml

На каждый стенд деплоится своя конфигурация ConfigMap index.html с тегом заголовка \<h1>\</h1>

Процесс деплоя
0. Пререквизиты.
    - работа производится в bash
    - установлен kubectl
    - установлен python3
    - (для локальной отладки) установлен Docker Desktop с включенным Kubernetes
    - Создан namespace и secviceaccount с корректными rolebindings и получен токен для доступа к namespace:
```
kubectl create namespace interview-test
kubectl config set-context --current --namespace=interview-test
kubectl create serviceaccount dima-dev
kubectl create rolebinding dima-dev-admin --clusterrole=admin --serviceaccount=interview-test:dima-dev
kubectl create clusterrolebinding dima-dev-cluster-admin --clusterrole=admin --serviceaccount=interview-test:dima-dev
kubectl get secret --namespace=interview-test
kubectl describe secret dima-dev-token-8x66c
```

1. Выполните шаги создания виртуальной среды для Ansible (см.ниже) и активируйте её:
```
source ansible_venv/bin/activate
```
2. Создайте файл с паролем
```
echo "*mypassword*" >> my_pwd.txt
```
3. Зашифруйте токен доступа к api k8s любым из способов и запишите его в vars.yml -> kuber_cluster.api_key нужного inventory:
```
# Если шифруете через файл
ansible-vault encrypt token.txt --vault-password-file my_pwd.txt

# Если просто передаете строку
ansible-vault encrypt_string --vault-password-file my_pwd.txt ***TOKEN*** --name 'token'
```
3. Запускайте плейбук в зависимости от стенда, на который деплоите test/prod:
```
# Перейдите в каталог с плейбуком
cd ansible_scripts

# Выполнить прогон dry-run без изменения объектов с включенным расширенным логированием:
ansible-playbook -vvvvv -i inventories/test deploy_playbook.yml --vault-password-file ../my_pwd.txt --check --diff

# Выполнить деплой:
ansible-playbook -i inventories/test deploy_playbook.yml --vault-password-file ../my_pwd.txt

```
4. Чтобы проверить результат - необходимо воспользовать curl:
```
curl -H "Host: nginx-hello.dimka.pro" http://localhost:31886
```

## Создание виртуальной среды с Ansible:
```
mkdir ansible_venv
python3 -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install virtualenv
python3 -m venv ansible_venv
source ansible_venv/bin/activate
python3 -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install ansible
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install kubernetes
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install openshift
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install grpcio
python3 -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install pyhelm
```

## Структура каталогов
- ansible_venv (виртуальная среда python)
- ansible_scripts
    - deploy_playbook.yml (плейбук деплоя)
    - inventories (переменные для конфигурирования каждой среды ПРОД/ТЕСТ)
        - test
            - groups_vars
                - localhost
                    - vars.yml
            - hosts.yml
        - prod
            - groups_vars
                - localhost
                    - vars.yml
            - hosts.yml
    - templates
        - nginx_hello
            - values.yml (шаблон переменных)