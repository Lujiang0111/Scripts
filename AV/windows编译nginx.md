# windows编译nginx

+ 参考文档：<http://nginx.org/en/docs/howto_build_on_win32.html>

## 1. 准备工作

### 1.1. visual studio环境搭建

1. 安装vs2015以上的版本：<https://visualstudio.microsoft.com/zh-hans/downloads/>

### 1.2. msys2环境搭建

1. 下载msys2：<https://www.msys2.org/>
2. 更新msys2

    ```shell
    pacman -Syu
    pacman -Su
    ```

3. 在msys2根目录下创建一个msys_vs2017.bat的文件，具体内容：

    ```powershell
    set MSYS2_PATH_TYPE=inherit
    ::vs2017
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
    ::vs2022
    ::call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    msys2_shell.cmd -mingw
    ```

4. 将msys2根目录\usr\bin\link.exe改名为link_msys2.exe，因为会和vs的link.exe重名

## 2. nginx编译

### 2.1. Nginx及依赖库下载

+ nginx

1. 下载地址：<https://github.com/nginx/nginx/tags>*（注意不要在nginx.org网站上下载，二者的目录结构不一致，后者没有auto/configure文件）*
2. 解压至nginx-src目录。

+ openssl

1. 下载地址：<https://slproweb.com/products/Win32OpenSSL.html>
2. 安装，创建nginx-src/3rd/openssl目录，拷贝openssl安装路径下include和lib文件夹至nginx-src/3rd/openssl目录。

+ pcre2

1. 下载地址：<https://github.com/PhilipHazel/pcre2/releases>
2. 解压至nginx-src/3rd/pcre2目录。

+ zlib

1. 下载地址：<https://www.zlib.net/>
2. 解压至nginx-src/3rd/zlib目录。

### 2.2. windows编译兼容

1. nginx-src/auto/cc/msvc

    + 注释掉vs版本判断行

    ```shell
    # MSVC 2005 supports C99 variadic macros
    if [ "$ngx_msvc_ver" -ge 14 ]; then
        have=NGX_HAVE_C99_VARIADIC_MACROS . auto/have
    fi
    ```

    改为

    ```shell
    # MSVC 2005 supports C99 variadic macros
    #if [ "$ngx_msvc_ver" -ge 14 ]; then
        have=NGX_HAVE_C99_VARIADIC_MACROS . auto/have
    #fi
    ```

2. nginx-src/auto/lib/openssl/conf

    + 修改openssl库的搜索路径

    ```shell
    CORE_INCS="$CORE_INCS $OPENSSL/openssl/include"
    CORE_DEPS="$CORE_DEPS $OPENSSL/openssl/include/openssl/ssl.h"

    if [ -f $OPENSSL/ms/do_ms.bat ]; then
        # before OpenSSL 1.1.0
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/ssleay32.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libeay32.lib"
    else
        # OpenSSL 1.1.0+
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libssl.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libcrypto.lib"
    fi
    ```

    改为

    ```shell
    CORE_INCS="$CORE_INCS $OPENSSL/include"
    CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"

    if [ -f $OPENSSL/ms/do_ms.bat ]; then
        # before OpenSSL 1.1.0
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib/ssleay32.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libeay32.lib"
    else
        # OpenSSL 1.1.0+
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libssl.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libcrypto.lib"
    fi
    ```

### 2.3. msys环境下编译

1. 直接运行msys_vs2017.bat（不要右键用管理员运行，有可能无法正确弹框）。

2. 进入nginx-src目录，运行

    ```shell
    chmod +x auto/configure
    auto/configure \
    --prefix= \
    --with-cc=cl \
    --with-debug \
    --with-http_ssl_module \
    --with-openssl=3rd/openssl \
    --with-openssl-opt=no-asm \
    --with-pcre=3rd/pcre2 \
    --with-zlib=3rd/zlib
    ```

3. 编译完成后，生成的exe文件在nginx-src/objs目录。

## 3. 运行nginx

1. 进入nginx-src/objs目录，创建logs和conf文件夹
2. 进入conf文件夹，创建对应文件

    + 参考文档：<https://www.nginx.com/resources/wiki/start/topics/examples/full/>

    + nginx.conf

    ```nginx
    worker_processes 5; ## Default: 1
    error_log logs/error.log;
    pid logs/nginx.pid;
    worker_rlimit_nofile 8192;

    events {
        worker_connections 4096; ## Default: 1024
    }

    http {
        include mime.types;
        include proxy.conf;
        include fastcgi.conf;
        index index.html index.htm index.php;

        default_type application/octet-stream;
        log_format main '$remote_addr - $remote_user [$time_local] $status '
        '"$request" $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';
        access_log logs/access.log main;
        sendfile on;
        tcp_nopush on;
        server_names_hash_bucket_size 128; # this seems to be required for some vhosts

        server {
            listen 80;
            server_name domain1.com www.domain1.com;
            access_log logs/domain1.access.log main;
            root html;

            location ~ \.php$ {
                fastcgi_pass 127.0.0.1:1025;
            }
        }

        server {
            listen 80;
            server_name domain2.com www.domain2.com;
            access_log logs/domain2.access.log main;

            # serve static files
            location ~ ^/(images|javascript|js|css|flash|media|static)/ {
                root /var/www/virtual/big.server.com/htdocs;
                expires 30d;
            }

            # pass requests for dynamic content to rails/turbogears/zope, et al
            location / {
                proxy_pass http://127.0.0.1:8080;
            }
        }

        upstream big_server_com {
            server 127.0.0.3:8000 weight=5;
            server 127.0.0.3:8001 weight=5;
            server 172.28.0.1:8000;
            server 172.28.0.1:8001;
        }

        server {
            listen 80;
            server_name big.server.com;
            access_log logs/big.server.access.log main;

            location / {
                proxy_pass http://big_server_com;
            }
        }
    }
    ```

    + proxy.conf

    ```nginx
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    client_max_body_size 10m;
    client_body_buffer_size 128k;
    proxy_connect_timeout 90;
    proxy_send_timeout 90;
    proxy_read_timeout 90;
    proxy_buffers 32 4k;
    ```

    + fastcgi.conf

    ```nginx
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param QUERY_STRING $query_string;
    fastcgi_param REQUEST_METHOD $request_method;
    fastcgi_param CONTENT_TYPE $content_type;
    fastcgi_param CONTENT_LENGTH $content_length;
    fastcgi_param SCRIPT_NAME $fastcgi_script_name;
    fastcgi_param REQUEST_URI $request_uri;
    fastcgi_param DOCUMENT_URI $document_uri;
    fastcgi_param DOCUMENT_ROOT $document_root;
    fastcgi_param SERVER_PROTOCOL $server_protocol;
    fastcgi_param GATEWAY_INTERFACE CGI/1.1;
    fastcgi_param SERVER_SOFTWARE nginx/$nginx_version;
    fastcgi_param REMOTE_ADDR $remote_addr;
    fastcgi_param REMOTE_PORT $remote_port;
    fastcgi_param SERVER_ADDR $server_addr;
    fastcgi_param SERVER_PORT $server_port;
    fastcgi_param SERVER_NAME $server_name;

    fastcgi_index index.php;

    fastcgi_param REDIRECT_STATUS 200;
    ```

    + mime.types

    ```nginx
    types {
        text/html                             html htm shtml;
        text/css                              css;
        text/xml                              xml rss;
        image/gif                             gif;
        image/jpeg                            jpeg jpg;
        application/x-javascript              js;
        text/plain                            txt;
        text/x-component                      htc;
        text/mathml                           mml;
        image/png                             png;
        image/x-icon                          ico;
        image/x-jng                           jng;
        image/vnd.wap.wbmp                    wbmp;
        application/java-archive              jar war ear;
        application/mac-binhex40              hqx;
        application/pdf                       pdf;
        application/x-cocoa                   cco;
        application/x-java-archive-diff       jardiff;
        application/x-java-jnlp-file          jnlp;
        application/x-makeself                run;
        application/x-perl                    pl pm;
        application/x-pilot                   prc pdb;
        application/x-rar-compressed          rar;
        application/x-redhat-package-manager  rpm;
        application/x-sea                     sea;
        application/x-shockwave-flash         swf;
        application/x-stuffit                 sit;
        application/x-tcl                     tcl tk;
        application/x-x509-ca-cert            der pem crt;
        application/x-xpinstall               xpi;
        application/zip                       zip;
        application/octet-stream              deb;
        application/octet-stream              bin exe dll;
        application/octet-stream              dmg;
        application/octet-stream              eot;
        application/octet-stream              iso img;
        application/octet-stream              msi msp msm;
        audio/mpeg                            mp3;
        audio/x-realaudio                     ra;
        video/mpeg                            mpeg mpg;
        video/quicktime                       mov;
        video/x-flv                           flv;
        video/x-msvideo                       avi;
        video/x-ms-wmv                        wmv;
        video/x-ms-asf                        asx asf;
        video/x-mng                           mng;
    }
    ```

3. nginx的基本命令
    + ```start nginx``` ：启动 nginx
    + ```nginx -t``` ：测试配置文件是否有语法错误
    + ```nginx -s reopen``` ：重启Nginx
    + ```nginx -s reload``` ：重新加载Nginx配置文件，然后以优雅的方式重启Nginx
    + ```nginx -s stop``` ：强制停止Nginx服务
    + ```nginx -s quit``` ：优雅地停止Nginx服务（即处理完所有请求后再停止服务）
