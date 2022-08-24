FROM nginx

RUN apt-get update \
    && apt-get -y install nano

ARG http_protocol
ARG server_name

COPY nginx.tpl /usr/local/nginx.tpl

RUN echo "* soft  nofile  200000" >> /etc/security/limits.conf
RUN echo "* hard  nofile  200000" >> /etc/security/limits.conf
RUN echo "www-data  soft  nofile 200000" >> /etc/security/limits.conf
RUN echo "www-data  hard  nofile 200000" >> /etc/security/limits.conf
RUN echo "root soft nofile 200000" >> /etc/security/limits.conf
RUN echo "root hard nofile 200000" >> /etc/security/limits.conf
RUN echo "nginx soft nofile 200000" >> /etc/security/limits.conf
RUN echo "nginx hard nofile 200000" >> /etc/security/limits.conf

RUN echo "fs.file-max = 200000" >> /etc/sysctl.conf

COPY mime.types /etc/nginx/conf.d/mime.types
COPY script.bash /usr/local/bin/script.bash
RUN chmod +x /usr/local/bin/script.bash
RUN /bin/bash /usr/local/bin/script.bash $http_protocol $server_name

WORKDIR /

EXPOSE 443