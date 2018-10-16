#!/bin/bash
set -e
# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
chmod +rx /usr/bin/composer
mkdir -p /var/run/php-fpm

# install dependencies
yum -y groupinstall "Development Tools"
yum -y install  git  python glib2-devel subversion make g++ python curl chrpath lbzip2 re2c
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum -y install nodejs
# depot tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /usr/local/depot_tools
export PATH=$PATH:/usr/local/depot_tools

# download v8
cd /usr/local/src
fetch v8

# compile v8
cd /usr/local/src/v8
git checkout 6.4.388.18
gclient sync

# Setup GN
tools/dev/v8gen.py -vv x64.release -- is_component_build=true

# Build
ninja -C out.gn/x64.release/
# install v8
mkdir -p /usr/local/lib
#cp /usr/local/src/v8/out/native/lib.target/lib*.so /usr/local/lib
cp /usr/local/src/v8/third_party/icu/common/icudtl.dat /usr/local/lib
cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin /usr/local/lib
mkdir /usr/local/lib/include
cp -R include/* /usr/local/lib/include/
cp -R /usr/local/src/v8/include /usr/local


#get v8js, new version
cd /usr/local/src
git clone https://github.com/phpv8/v8js.git
cd v8js

phpize
./configure --with-v8js=/usr/local LDFLAGS="-lstdc++"
make
make test
make install


# add module configuration
cat <<EOF > /etc/php.d/20-v8js.ini
; configuration for php v8js module
; priority=20
extension=v8js.so
EOF

# enable extension


rm -rf /root/.cache /var/lib/apt/lists/* /usr/local/src/* /usr/local/depot_tools
