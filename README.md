## Гайд по настроке docker сборки и оптимизации сервера под неё

Сборка включает в себя:
- nginx
- php-fpm 8 + cron
- mysql 8
- redis 6

Версии сервисов можно менять в зависимости от требований.

## Порядок запуска сборки:

1. Скопировать .env.example в .env  
    **cp .env.example .env**

2. Заполнить в .env переменные нужными значениями. DB_ROOT_PASSWORD не должен совпадать с DB_PASSWORD

3. Бекап базы положить в каталог volumes/database/dump (если этого не требуется, то каталог оставить пустым)  
    `cp YOUR_DB_BACKUP.SQL DOCKER_PATH/volumes/database/dump/dump.sql/`

4. Если требуется применение https для проекта, то в .env нужно указать HTTP_PROTOCOL=https и в docker-compose.yml расскомментировать строки монтирования файлов сертификатов и указать соответствующий путь и названия для них.  
    ``- ./nginx/sertificate/your.cert.crt:/etc/ssl/certs/yourproject/ssl.your.cert.crt``  
    ``- ./nginx/sertificate/your.cert.key:/etc/ssl/certs/yourproject/ssl.your.cert.key``  
    ``- ./nginx/sertificate/your.cert.ca:/etc/ssl/certs/yourproject/ssl.your.cert.ca``  

5. Для настройки cron'а необходимо прописать нужные строки в php/crontab. Для laravel просто расскомментировать первую строку в исходном файле.

6. В основном конфиге nginx'а nginx_main.conf указать количество воркеров (параметр ``worker_processes``) равное количеству ядер процессора (смотреть командой lscpu).  
    Также задать нужное значение ограничения запросов в секунду, обрабатываемых nginx'ом.  
    Параметр ``limit_req_zone $binary_remote_addr zone=peroneip:10m rate=500r/s;`` - 500 меняем на нужное.  
    Для проектов с другими backend фреймворками поменять параметр root в файле nginx.tpl (строка ``root /var/www/public;``)
        
7. Положить файлы проекта по пути volumes/html/

8. Запуск сборки выполнять под соответствующим пользователем проекту командой (!!!!!!)  

    Linux:
    ``USERID=$UID docker-compose up -d --build``  
    
    Windows PowerShell : 
    
    ``$env:USER = 'default'``
    ``$env:USERID = 1000``
    
    Запуск контейнеров: ``docker-compose up -d`` 
    Остановка контейнеров: ``docker-compose stop``  


## Настройка оптимизации сервера (хоста)

В файл /etc/security/limits.conf добавить в конец файла следующие строки:  
    ``* soft  nofile  200000``  
    ``* hard  nofile  200000``  
    ``www-data  soft  nofile 200000``  
    ``www-data  hard  nofile 200000``  
    ``root soft nofile 200000``  
    ``root hard nofile 200000``  
    ``nginx soft nofile 200000``  
    ``nginx hard nofile 200000``  
    
В файл /etc/sysctl.conf в конец добавить строку  
    ``fs.file-max = 200000``  

**После добавления требуется перезагрузить систему!!!**

## Настройка безопасности серевера (хоста)

### Добавление sudo пользователя

Добавляем дополнительного sudo пользователя admin (или любое другое имя).

  Добавление пользователя и следуем по шагам - ``adduser admin``  
  Добавляем пользователя в группу sudo - ``usermod -aG sudo admin``

### Настройка ssh

Необходимо сменить стандартный порт для ssh на другой. Порт меняется в файле  
    ``/etc/ssh/sshd_config``.  
    Строка: ``Port 22``  
    Также в этом файле нужно отключить возможность логина под root пользователем.  
    ``PermitRootLogin no``

После этого нужно перезапустить службу ssh  
``service sshd restart``

### Установка и настройка утилиты fail2ban 

Данная утилита умеет блокировать ip адреса, путем добавления правил блокировки в iptables.
Fail2ban просматривает нужные логи и на основе их блокирует ip адреса.  

``apt-get install fail2ban``  

Скопировать файл /host/jail.local в каталог /etc/fail2ban/

``cp jail.local /etc/fail2ban/jail.local``

!!! Необходимо внести следующие правки в скопированный конфигурационный файл !!!

В секции ``[nginx-http-auth]`` изменить параметр logpath на путь ведущий к логам nginx'а
в каталоге сборки (/nginx/logs/error.log), например /home/YOURPROJECT/nginx/logs/error.log

В секции ``[nginx-limit-req]`` изменить параметр logpath на путь ведущий к логам nginx'а
в каталоге сборки (/nginx/logs/error.log), например  /home/YOURPROJECT/nginx/logs/error.log

Затем перезапустить службу  
``service fail2ban restart``

Логи утилиты лежат по пути /var/log/fail2ban.log


## Настройка firewall'а ufw

Разрешаем в файрволле командой следующие порты:  
``ufw allow PORT``  

``22022(новый порт для ssh), 80, 443, 80/tcp, 443/tcp``  

Запрещаем в файрволле командой следующие порты:  
``ufw deny PORT``  

``22, 22/tcp, 21, 21/tcp, 23, 23/tcp и порты используемые сервисами в докер сборке.``  

!!! ОБЯЗАТЕЛЬНО НУЖНО ДОБАВИТЬ В ИСКЛЮЧЕНИЯ ПОРТ ПО КОТОРОМУ ПОДКЛЮЧАЕТЕСЬ ПО ssh !!!

Включаем файрволл командой - ``ufw enable``  
Отключать файрволл командой - ``ufw disable``  

### Настройка проекта

Меняем права каталога storage внутри папки проекта:  
``chown www-data:www-data storage``  

Зайти в контейнер - ``docker exec -it *_php bash``  

Все дальнейшие команды выполняются ВНУТРИ контейнера php  

``composer install``  

``php artisan key:generate (при разворачивании с нуля)``  

``php artisan migrate (при разворачивании с нуля)``  

**Конец**