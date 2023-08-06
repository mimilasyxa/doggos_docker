server {
    listen %HTTP_PORT%;

    %SSL_CERTIFICATE%
    %SSL_KEY%
    %SSL_CA%
    root /var/www/public;

    %SERVER_NAME%

    index index.html index.htm index.php;

    charset utf-8;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    client_max_body_size 200m;
    sendfile off;

    #Requests limit
    limit_req zone=peroneip burst=550;

    #Connections limit
    limit_conn perip 10000;

    #gzip
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_proxied any;

    gzip_types
    application/atom+xml
    application/json
    application/Id+json
    application/manifest+json
    application/rss+xml
    application/vnd.geo+json
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/opentype
    image/bmp
    image/svg+xml
    svg
    svgz
    image/x-icon
    text/cache-manifest
    text/vcard
    text/vnd.rim.location.xloc
    text/vtt
    text/x-component
    text/x-cross-domain-policy
    text/plain
    text/css
    text/html
    application/javascript
    application/x-javascript
    ext/javascript
    ^text/.*$ ^image/.*$;

    gzip_vary on;

    #php params
    fastcgi_param magic_quotes_gpc "off";
    fastcgi_param magic_quotes_runtime "off";
    fastcgi_param register_globals "off";
    fastcgi_param short_open_tags "on";

    disable_symlinks "off";

    location = /nginx_status {
        stub_status;
    }

    location ~* ^/(.*/)?\.svn/ {
        return 403;
    }

    # Static files location
    location ~*^.+\.(jpg|jpeg|gif|png|css|zip|bmp|js|svg|ttf|eot|woff|xml|webp|txt|html|mp4|json)$
    {
        root   /var/www/public;
        expires 25920000s; # 3 days
        access_log off;
        log_not_found off;
        add_header Pragma public;
        add_header Cache-Control "max-age=25920000, public";
    }

    location / {

        if ($https = '') {
            %SET_HTTP_PROTOCOL_REDIRECT%    rewrite ^(.*)$ https://$http_host$request_uri redirect;
        }

        if ($http_host ~* "^www\.(.*)") {
            rewrite ^(.*)$ http://%1/$1 redirect;
        }
    }

    location ~ ^.*\.php$ {
        fastcgi_pass php:9000;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_keep_conn on;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~* ^(.*)$ {
        rewrite ^(.*)$ /index.php?$args last;
    }

    location /swagger-ui/default {
        location ~ \.(json)$ {

        }
        return 403;
    }
}