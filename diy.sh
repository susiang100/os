cd $OPENSHIFT_DATA_DIR
wget http://www.canonware.com/download/jemalloc/jemalloc-4.0.4.tar.bz2
tar -xjf jemalloc-4.0.4.tar.bz2
rm -rf jemalloc-4.0.4.tar.bz2
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz
tar -zxvf pcre-8.40.tar.gz
rm -rf pcre-8.40.tar.gz
wget https://github.com/FRiCKLE/ngx_cache_purge/archive/master.zip
unzip master.zip
rm -rf master.zip
git clone git://github.com/alibaba/tengine.git



cd tengine
./configure \
--prefix=$OPENSHIFT_DATA_DIR/nginx \
--with-pcre=$OPENSHIFT_DATA_DIR/pcre-8.40 \
--with-jemalloc=$OPENSHIFT_DATA_DIR/jemalloc-4.0.4 \
--add-module=$OPENSHIFT_DATA_DIR/ngx_cache_purge-master \
--with-ipv6 \
--with-http_v2_module \
--with-http_realip_module \
--with-http_mp4_module \
--with-http_flv_module \
--with-http_geoip_module \
--with-http_gzip_static_module \
--with-http_sub_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_concat_module \
--with-http_auth_request_module \
--with-http_addition_module=shared \
--with-http_sysguard_module=shared \
--with-http_image_filter_module=shared \
--with-http_footer_filter_module=shared \
--with-http_memcached_module=shared \
--with-http_trim_filter_module=shared \
--with-http_empty_gif_module=shared
make
make dso_install
make install



cd /tmp
wget -O libmcrypt-2.5.8.tar.gz http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz?big_mirror=0
tar zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd libltdl
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --enable-ltdl-install
make -j4 && make install
cd ../..
wget -O mhash-0.9.9.9.tar.gz http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz?big_mirror=0
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget -O mcrypt-2.6.8.tar.gz http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz?big_mirror=0
tar zxf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
export LDFLAGS="-L${OPENSHIFT_DATA_DIR}usr/local/lib -L/usr/lib"
export CFLAGS="-I${OPENSHIFT_DATA_DIR}usr/local/include -I/usr/include"
export LD_LIBRARY_PATH="/usr/lib/:${OPENSHIFT_DATA_DIR}usr/local/lib"
export PATH="/bin:/usr/bin:/usr/sbin:${OPENSHIFT_DATA_DIR}usr/local/bin:${OPENSHIFT_DATA_DIR}bin:${OPENSHIFT_DATA_DIR}sbin"
touch malloc.h
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --with-libmcrypt-prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget http://php.net/distributions/php-7.0.0.tar.gz
tar -zxvf php-7.0.0.tar.gz
cd php-7.0.0
./configure --prefix=${OPENSHIFT_DATA_DIR}php --with-config-file-path=${OPENSHIFT_DATA_DIR}php/etc --with-mcrypt=${OPENSHIFT_DATA_DIR}usr/local \
--with-fpm-user=www --with-fpm-group=www --enable-fpm --enable-opcache \
--disable-fileinfo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-jpeg-dir \
--with-iconv-dir=/usr/local --with-freetype-dir --with-png-dir --with-zlib --disable-rpath \
--with-libxml-dir=/usr --enable-xml --enable-bcmath --enable-shmop --enable-exif --with-curl \
--enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-inline-optimization \
--enable-mbstring --with-gd --enable-gd-native-ttf --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp \
--with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
make -j4
make install



${OPENSHIFT_DATA_DIR}php/bin/php -v




cd $OPENSHIFT_DATA_DIR
wget http://acfun.webcrow.jp/php/nginx.conf.erb
wget http://acfun.webcrow.jp/php/php.ini.erb
wget http://acfun.webcrow.jp/php/php-fpm.conf
wget http://acfun.webcrow.jp/php/www-facgi.conf.erb
wget http://acfun.webcrow.jp/php/wordpress.conf
erb ./nginx.conf.erb >${OPENSHIFT_DATA_DIR}nginx/conf/nginx.conf
erb ./php.ini.erb >${OPENSHIFT_DATA_DIR}php/etc/php.ini
mkdir ${OPENSHIFT_DATA_DIR}nginx/run
erb ./www-facgi.conf.erb >${OPENSHIFT_DATA_DIR}nginx/run/www-facgi.conf
cp ./php-fpm.conf ${OPENSHIFT_DATA_DIR}nginx/conf
mv ./wordpress.conf ${OPENSHIFT_DATA_DIR}nginx/run
mkdir /tmp/cache/wpcache/temp
mkdr ${OPENSHIFT_HOMEDIR}app-root/runtime/repo/www
rm -rf nginx.conf.erb php.ini.erb php-fpm.conf www-facgi.conf.erb wordpress.conf
