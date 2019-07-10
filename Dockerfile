FROM tlecreate/php_nginx_fastcgi_cache:alpine

COPY conf/fastcgi-cache-rules.conf /etc/nginx/cache-rules.d/

COPY conf/wordpress.conf /etc/nginx/html-rules.d/

# Install wordpress

RUN curl https://wordpress.org/latest.tar.gz -o /opt/wordpress.tar.gz && \
  tar xzf /opt/wordpress.tar.gz -C /opt/ && \
  rm -rf /var/www/html/* && \
  mv /opt/wordpress/* /var/www/html/ && \
  rm -rf /opt/wordpress/ && \
  rm /opt/wordpress.tar.gz && \
  mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

VOLUME ["/var/www/html/wp-content", "/var/log"]
