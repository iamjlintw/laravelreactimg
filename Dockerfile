FROM centos:7.5.1804

MAINTAINER Jethro Lin <jethro_lin@taogo.com.tw>

#devtool
RUN yum -y install vim  git unzip zip
RUN yum -y install unzip zip python python-pip

# PHP7.1 Stack
RUN yum -y install epel-release yum-utils && \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php71,remi && \
    yum -y update && \
    yum -y install ImageMagick ImageMagick-devel  && \
    yum -y install php php-devel php-pear php-curl php-fpm php-mysql php-mcrypt php-cli php-gd php-pgsql php-pdo   \
           php-common php-json php-pecl-redis php-pecl-memcache php-opcache php-mbstring \
           php-xml php-zip php-soap php-yaml   \
    pecl install Imagick  && \
    yum clean all
# Install composer
# source: https://getcomposer.org/download/
##

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN chmod +rx /usr/bin/composer

# Install v8js php extension
COPY scripts/install-v8js.sh /install-v8js.sh
RUN sh /install-v8js.sh && rm /install-v8js.sh

