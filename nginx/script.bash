#!/bin/bash
http=$1;
servername=$2';';
#??????????
pathCert='';
#??????????
pathKey='';
#??????????
pathCa='';
cert='ssl_certificate '${pathCert}';';
key='ssl_certificate_key '${pathKey}';';
ca='ssl_trusted_certificate '${pathCa}';';
if [[ $http = "http" ]]
then
        sed -e "
        s:%SET_HTTP_PROTOCOL_REDIRECT%:#:g;
        s:%HTTP_PORT%:80:g;
        s:%SSL_CERTIFICATE%::g;
        s:%SSL_KEY%::g;
        s:%SSL_CA%::g;
        s:%SERVER_NAME%:server_name ${servername}:g;
    " /usr/local/nginx.tpl > /usr/local/nginx.conf;
else
        sed -e "
        s:%SET_HTTP_PROTOCOL_REDIRECT%::g;
        s:%HTTP_PORT%:443 ssl:g;
        s:%SSL_CERTIFICATE%:${cert}:g;
        s:%SSL_KEY%:${key}:g;
        s:%SSL_CA%:${ca}:g;
        s:%SERVER_NAME%:server_name ${servername}:g;
    " /usr/local/nginx.tpl > /usr/local/nginx.conf;
fi
cp -f /usr/local/nginx.conf /etc/nginx/conf.d/nginx.conf;
rm -f /etc/nginx/conf.d/default.conf;