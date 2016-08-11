FROM php:5.6-apache

RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get update && apt-get install unzip -y && apt-get install curl -y && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini



VOLUME /var/www/html


# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN  curl -o wordpress.zip -SL https://github.com/rahulnatarajan/awstestdrive/archive/master.zip \
        && unzip wordpress.zip -d /usr/src/ \
        && rm wordpress.zip \
        && mv /usr/src/awstestdrive-master/ /usr/src/wordpress \
        && chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
