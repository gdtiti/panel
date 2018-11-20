#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL
Root_Path=`cat /var/bt_setupPath.conf`
Setup_Path=$Root_Path/server/php
php_path=$Root_Path/server/php
mysql_dir=$Root_Path/server/mysql
mysql_config="${mysql_dir}/bin/mysql_config"
Is_64bit=`getconf LONG_BIT`
run_path='/root'
apacheVersion=`cat /var/bt_apacheVersion.pl`

php_55='5.5.38'
php_56='5.6.38'
php_70='7.0.32'
php_71='7.1.23'
php_72='7.2.11'

centos_version=`cat /etc/redhat-release | grep ' 7.' | grep -i centos`
if [ "${centos_version}" != '' ]; then
	rpm_path="centos7"
else
	rpm_path="centos6"
fi

cpuInfo=$(getconf _NPROCESSORS_ONLN)
if [ "${cpuInfo}" -ge "4" ];then
	cpuCore=$((${cpuInfo}-1))
else
	cpuCore="1"
fi

Lib_Check(){
	if [ ! -f "/usr/local/curl/bin/curl" ]; then
		curl_version="7.57.0"
		wget -O curl-$curl_version.tar.gz ${download_Url}/src/curl-$curl_version.tar.gz -T 5
		tar zxf curl-$curl_version.tar.gz
		cd curl-$curl_version
	    ./configure --prefix=/usr/local/curl --enable-ares --without-nss --with-ssl=/usr/local/openssl
	    make && make install
	    cd ..
	    rm -rf curl-$curl_version
		rm -rf curl-$curl_version.tar.gz
	fi

	if [ ! -f "/usr/local/libiconv/bin/iconv" ]; then
		wget -O libiconv-1.14.tar.gz ${download_Url}/src/libiconv-1.14.tar.gz -T 5
		mkdir /patch
		wget -O /patch/libiconv-glibc-2.16.patch ${download_Url}/src/patch/libiconv-glibc-2.16.patch -T 5
		tar zxf libiconv-1.14.tar.gz
		cd libiconv-1.14
	    patch -p0 < /patch/libiconv-glibc-2.16.patch
	    ./configure --prefix=/usr/local/libiconv --enable-static
	    make && make install
	    cd ${run_path}
	    rm -rf libiconv-1.14
		rm -f libiconv-1.14.tar.gz
	fi

	if [ ! -f "/usr/lib/libmcrypt.so" ]; then
		wget -O libmcrypt-2.5.8.tar.gz ${download_Url}/src/libmcrypt-2.5.8.tar.gz -T 5
		tar zxf libmcrypt-2.5.8.tar.gz
		cd libmcrypt-2.5.8
		
	    ./configure
	    make && make install
	    /sbin/ldconfig
	    cd libltdl/
	    ./configure --enable-ltdl-install
	    make && make install
	    ln -sf /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	    ln -sf /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	    ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	    ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	    ldconfig
	    cd ${run_path}
	    rm -rf libmcrypt-2.5.8
		rm -f libmcrypt-2.5.8.tar.gz
	fi

	if [ ! -f "/usr/local/bin/mcrypt" ]; then
		wget -O mcrypt-2.6.8.tar.gz ${download_Url}/src/mcrypt-2.6.8.tar.gz -T 5
		tar zxf mcrypt-2.6.8.tar.gz
		cd mcrypt-2.6.8
	    ./configure
	    make && make install
	    cd ${run_path}
	    rm -rf mcrypt-2.6.8
		rm -f mcrypt-2.6.8.tar.gz
	fi

	if [ ! -f  "/usr/local/lib/libmhash.so" ]; then
		wget -O mhash-0.9.9.9.tar.gz ${download_Url}/src/mhash-0.9.9.9.tar.gz -T 5
		tar zxf mhash-0.9.9.9.tar.gz
		cd mhash-0.9.9.9
	    ./configure
	    make && make install
	    ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	    ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	    ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	    ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	    ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
	    ldconfig
	    cd ${run_path}
	    rm -rf mhash-0.9.9.9*
	fi

    Cur_Pcre_Ver=`pcre-config --version|grep '^8.' 2>&1`
    if [ "$Cur_Pcre_Ver" == "" ];then
		pcre_version=8.40
	    wget -O pcre-$pcre_version.tar.gz ${download_Url}/src/pcre-$pcre_version.tar.gz -T 5
		tar zxf pcre-$pcre_version.tar.gz
		cd pcre-$pcre_version
		if [ "$Is_64bit" == "64" ];then
			./configure --prefix=/usr --docdir=/usr/share/doc/pcre-$pcre_version --libdir=/usr/lib64 --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline --disable-static --enable-utf8  
	    else
			./configure --prefix=/usr --docdir=/usr/share/doc/pcre-$pcre_version --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline --disable-static --enable-utf8
		fi
		make && make install
	    cd ..
	    rm -rf pcre-$pcre_version
		rm -f pcre-$pcre_version.tar.gz
	fi

	if [ ! -f "/usr/local/openssl/bin/openssl" ]; then
        cd ${run_path}
        wget ${download_Url}/src/openssl-1.0.2l.tar.gz -T 20
        tar -zxf openssl-1.0.2l.tar.gz
        rm -f openssl-1.0.2l.tar.gz
        cd openssl-1.0.2l
        ./config --openssldir=/usr/local/openssl zlib-dynamic shared
        make && make install
        echo '1.0.2l_shared' > /usr/local/openssl/version.pl
        cd ..
        rm -rf openssl-1.0.2l
		cat > /etc/ld.so.conf.d/openssl.conf <<EOF
/usr/local/openssl/lib
EOF
		ldconfig	
	fi
}
Lib_Check2(){
	if [ ! -f "/usr/local/curl/bin/curl" ]; then
		wget ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-curl-7.54.0.rpm
		rpm -ivh bt-curl-7.54.0.rpm --force --nodeps
		rm -f bt-curl-7.54.0.rpm
	fi
	if [ ! -f "/usr/local/libiconv/bin/iconv" ]; then
		wget ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-libiconv-1.14.rpm
		rpm -ivh bt-libiconv-1.14.rpm --force --nodeps
		rm -f bt-libiconv-1.14.rpm
	fi
	if [ ! -f "/usr/lib/libmcrypt.so" ]; then
		wget ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-libmcrypt-2.5.8.rpm
		rpm -ivh bt-libmcrypt-2.5.8.rpm --force --nodeps
		rm -f bt-libmcrypt-2.5.8.rpm
		ln -s /usr/local/lib/libltdl.so.3 /usr/lib/libltdl.so.3
	fi
	if [ ! -f "/usr/local/bin/mcrypt" ]; then
		wget ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-mcrypt-2.6.8.rpm
		rpm -ivh bt-mcrypt-2.6.8.rpm --force --nodeps 
		rm -f bt-mcrypt-2.6.8.rpm 
	fi
	if [ ! -f "/usr/local/lib/libmhash.so" ]; then
		wget ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-mhash-0.9.9.9.rpm
		rpm -ivh bt-mhash-0.9.9.9.rpm --force --nodeps
		rm -f bt-mhash-0.9.9.9.rpm
	fi
}
Set_PHP_FPM_Opt()
{
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -le 2048 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 50#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 10#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 10#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 50#" ${php_setup_path}/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 2048 && ${MemTotal} -le 4096 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 80#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 15#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 15#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 80#" ${php_setup_path}/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 4096 && ${MemTotal} -le 8192 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 150#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 150#" ${php_setup_path}/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 8192 && ${MemTotal} -le 16384 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 200#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 200#" ${php_setup_path}/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 16384 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 300#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 30#" ${php_setup_path}/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 300#" ${php_setup_path}/etc/php-fpm.conf
    fi
}


Export_PHP_Autoconf()
{
    export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
    export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
}

Ln_PHP_Bin()
{
	rm -f /usr/bin/php*
	rm -f /usr/bin/pear
	rm -f /usr/bin/pecl

    ln -sf ${php_setup_path}/bin/php /usr/bin/php
    ln -sf ${php_setup_path}/bin/phpize /usr/bin/phpize
    ln -sf ${php_setup_path}/bin/pear /usr/bin/pear
    ln -sf ${php_setup_path}/bin/pecl /usr/bin/pecl
    ln -sf ${php_setup_path}/sbin/php-fpm /usr/bin/php-fpm
}

Pear_Pecl_Set()
{
    pear config-set php_ini ${php_setup_path}/etc/php.ini
    pecl config-set php_ini ${php_setup_path}/etc/php.ini
}

Install_Composer()
{
	if [ ! -f "/usr/bin/composer" ];then
		wget -O /usr/bin/composer ${download_Url}/install/src/composer.phar -T 20;
		chmod +x /usr/bin/composer
		if [ "${download_Url}" == "http://$CN:5880" ];then
			composer config -g repo.packagist composer https://packagist.phpcomposer.com
		fi
	fi
}

Install_PHP_52()
{
	if [ "${apacheVersion}" == "2.4" ];then
		rm -rf $Root_Path/server/php/52
		return;
	fi
	cd ${run_path}
	php_version="52"
	php_setup_path=${php_path}/${php_version}
    Export_PHP_Autoconf
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-5.2.17.tar.gz -T20
	fi
    tar zxf src.tar.gz
	mv php-5.2.17 src
	rm -rf /patch
	mkdir -p /patch
	if [ "${apacheVersion}" != '2.2' ];then
		wget ${download_Url}/src/php-5.2.17-fpm-0.5.14.diff.gz
		gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d src -p1
	fi
    
	wget -O /patch/php-5.2.17-max-input-vars.patch ${download_Url}/src/patch/php-5.2.17-max-input-vars.patch -T20
	wget -O /patch/php-5.2.17-xml.patch ${download_Url}/src/patch/php-5.2.17-xml.patch -T20
	wget -O /patch/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch ${download_Url}/src/patch/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch -T20
	wget -O /patch/php-5.2-multipart-form-data.patch ${download_Url}/src/patch/php-5.2-multipart-form-data.patch -T20
	rm -f php-5.2.17-fpm-0.5.14.diff.gz
	cd src/
    patch -p1 < /patch/php-5.2.17-max-input-vars.patch
    patch -p0 < /patch/php-5.2.17-xml.patch
    patch -p1 < /patch/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p1 < /patch/php-5.2-multipart-form-data.patch
	
	ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so
	ln -s /usr/lib64/libpng.so /usr/lib/libpng.so
	
    ./buildconf --force
	if [ "${apacheVersion}" != '2.2' ];then
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --with-mysql=${mysql_dir} --with-pdo-mysql=${mysql_dir} --with-mysqli=$Root_Path/server/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --with-mime-magic --with-iconv=/usr/local/libiconv
	else
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --with-apxs2=$Root_Path/server/apache/bin/apxs --with-mysql=${mysql_dir} --with-pdo-mysql=${mysql_dir} --with-mysqli=$Root_Path/server/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --with-mime-magic
	fi
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
	make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install
	
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-dist ${php_setup_path}/etc/php.ini
	
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-5.2 installation failed.\033[0m";
		exit 0;
	fi
	
	#安装mysqli
    #cd ${Root_Path}/server/php/52/src/ext/mysqli/
    #${Root_Path}/server/php/52/bin/phpize
    #echo "${now_path}"
    #./configure --with-php-config=${php_setup_path}/bin/php-config  --with-mysqli=$Root_Path/server/mysql/bin/mysql_config
    #make
    #make install
    #cd ${php_setup_path}	

    Ln_PHP_Bin

    # php extensions
    sed -i "s#extension_dir = \"./\"#extension_dir = \"${php_setup_path}/lib/php/extensions/no-debug-non-zts-20060613/\"\n#" ${php_setup_path}/etc/php.ini
    sed -i 's#output_buffering =.*#output_buffering = On#' ${php_setup_path}/etc/php.ini
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g'${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    
	mkdir -p /usr/local/zend/php52
	wget -O /usr/local/zend/php52/ZendOptimizer.so ${download_Url}/src/ZendOptimizer-${Is_64bit}.so -T 20
	
	mysqli='';
	if [ -f ${php_setup_path}/lib/php/extensions/no-debug-non-zts-20060613/mysqli.so ];then
		mysqli="extension=mysqli.so";
	fi

    cat >>${php_setup_path}/etc/php.ini<<EOF
$mysqli
;eaccelerator

;ionCube

[Zend Optimizer]
zend_optimizer.optimization_level=1
zend_extension="/usr/local/zend/php52/ZendOptimizer.so"

;xcache

EOF

	if [ "${apacheVersion}" != '2.2' ];then
		rm -f ${php_setup_path}/etc/php-fpm.conf
		wget -O ${php_setup_path}/etc/php-fpm.conf ${download_Url}/conf/php-fpm5.2.conf -T20
		wget -O /etc/init.d/php-fpm-52 ${download_Url}/init/php_fpm_52.init -T20
		chmod +x /etc/init.d/php-fpm-52
		chkconfig --add php-fpm-52
		chkconfig --level 2345 php-fpm-52 on
		service php-fpm-52 start
	else
		if [ ! -f /www/server/php/52/libphp5.so ];then
			\cp -a -r $Root_Path/server/apache/modules/libphp5.so /www/server/php/52/libphp5.so
			sed -i '/#LoadModule php5_module/s/^#//' /www/server/apache/conf/httpd.conf
		fi
		/etc/init.d/httpd restart
	fi
	rm -f ${php_setup_path}/src.tar.gz	
	echo "5.2.17" > ${php_setup_path}/version.pl
}

Install_PHP_53()
{
	cd ${run_path}
	php_version="53"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-5.3.29.tar.gz
	fi
    
    tar zxf src.tar.gz
	mv php-5.3.29 src
	cd src
	
	rm -rf /patch
	mkdir -p /patch
	wget -O /patch/php-5.3-multipart-form-data.patch ${download_Url}/src/patch/php-5.3-multipart-form-data.patch -T20
    patch -p1 < /patch/php-5.3-multipart-form-data.patch
	if [ "${apacheVersion}" != '2.2' ];then
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
	else
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --with-apxs2=$Root_Path/server/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
	fi
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
	make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install
	
	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-5.3 installation failed.\033[0m";
		exit 0;
	fi

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini
	
	cd ${run_path}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
    sed -i 's/register_long_arrays =.*/;register_long_arrays = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/magic_quotes_gpc =.*/;magic_quotes_gpc = On/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 5.3..."
	mkdir -p /usr/local/zend/php53
    if [ "${Is_64bit}" = "64" ] ; then
        wget ${download_Url}/src/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        \cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/php53/
		rm -f ${run_path}/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		rm -rf ${run_path}/ZendGuardLoader-php-5.3-linux-glibc23-x86_64
    else
        wget ${download_Url}/src/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        \cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/php53/
		rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
		rm -f ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
    fi
	

    echo "Write ZendGuardLoader to php.ini..."
    cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/php53/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache

EOF
if [ "${apacheVersion}" != '2.2' ];then
    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-53.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_53_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
	
    \cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-53
	chmod +x /etc/init.d/php-fpm-53
	
	chkconfig --add php-fpm-53
	chkconfig --level 2345 php-fpm-53 on
	/etc/init.d/php-fpm-53 start
else
	if [ ! -f /www/server/php/53/libphp5.so ];then
		\cp -a -r $Root_Path/server/apache/modules/libphp5.so /www/server/php/53/libphp5.so
		sed -i '/#LoadModule php5_module/s/^#//' /www/server/apache/conf/httpd.conf
	fi
	/etc/init.d/httpd restart
fi
	rm -f ${php_setup_path}src.tar.gz
	echo "5.3.29" > ${php_setup_path}/version.pl
}


Install_PHP_54()
{
	cd ${run_path}
	php_version="54"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	
	mkdir -p ${php_setup_path}
    rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-5.4.45.tar.gz -T20
	fi
	
    tar zxf src.tar.gz
	mv php-5.4.45 src
	cd src
	if [ "${apacheVersion}" != '2.2' ];then
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-intl
	else
		./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --with-apxs2=$Root_Path/server/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-intl --with-xsl
	fi
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
	make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install

	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-5.4 installation failed.\033[0m";
		exit 0;
	fi
	
    Ln_PHP_Bin

    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini
	cd ${php_setup_path}
    # php extensions
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer
	
	mkdir -p /usr/local/zend/php54
    if [ "${Is_64bit}" = "64" ] ; then
        wget ${download_Url}/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -T20
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        \cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/zend/php54/
		rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
		rm -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
    else
        wget ${download_Url}/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz -T20
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        \cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/zend/php54/
		rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
		rm -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
    fi

    echo "Write ZendGuardLoader to php.ini..."
    cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/php54/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache

EOF

if [ "${apacheVersion}" != '2.2' ];then
    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-54.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_54_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
	Set_PHP_FPM_Opt
    \cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-54
    chmod +x /etc/init.d/php-fpm-54
	
	chkconfig --add php-fpm-54
	chkconfig --level 2345 php-fpm-54 on
	rm -f /tmp/php-cgi-54.sock
	/etc/init.d/php-fpm-54 start
else
	if [ ! -f /www/server/php/54/libphp5.so ];then
		\cp -a -r $Root_Path/server/apache/modules/libphp5.so /www/server/php/54/libphp5.so
		sed -i '/#LoadModule php5_module/s/^#//' /www/server/apache/conf/httpd.conf
	fi
	/etc/init.d/httpd restart
fi
	rm -f ${php_setup_path}/src.tar.gz
	echo "5.4.45" > ${php_setup_path}/version.pl
}

Install_PHP_55()
{
	cd ${run_path}
	php_version="55"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-${php_55}.tar.gz -T20
	fi
    
    tar zxf src.tar.gz
	mv php-${php_55} src
	cd src
	./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-intl
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
	make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install
	
	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-5.5 installation failed.\033[0m";
		exit 0;
	fi
	
    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini

    cd ${php_setup_path}
    # php extensions
    echo "Modify php.ini..."
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 5.5..."
    mkdir -p /usr/local/zend/php55
    if [ "${Is_64bit}" = "64" ] ; then
        wget ${download_Url}/src/zend-loader-php5.5-linux-x86_64.tar.gz -T20
        tar zxf zend-loader-php5.5-linux-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so /usr/local/zend/php55/
		rm -rf zend-loader-php5.5-linux-x86_64
		rm -f zend-loader-php5.5-linux-x86_64.tar.gz
    else
        wget ${download_Url}/src/zend-loader-php5.5-linux-i386.tar.gz
        tar zxf zend-loader-php5.5-linux-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so /usr/local/zend/php55/
		rm -rf zend-loader-php5.5-linux-i386
		rm -f zend-loader-php5.5-linux-i386.tar.gz
    fi

    echo "Write ZendGuardLoader to php.ini..."
    cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/php55/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache

EOF

    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-55.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_55_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
    echo "Copy php-fpm init.d file..."
    \cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-55
    chmod +x /etc/init.d/php-fpm-55
	
	chkconfig --add php-fpm-55
	chkconfig --level 2345 php-fpm-55 on
	rm -f /tmp/php-cgi-55.sock
	/etc/init.d/php-fpm-55 start
	rm -f ${php_setup_path}/src.tar.gz
	echo "${php_55}" > ${php_setup_path}/version.pl
}

Install_PHP_56()
{
	cd ${run_path}
	php_version="56"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-${php_56}.tar.gz -T20
	fi
    
    tar zxf src.tar.gz
	mv php-${php_56} src
	cd src
	./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-intl
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install

	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-5.6 installation failed.\033[0m";
		rm -rf ${php_setup_path}
		exit 0;
	fi
	
    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini

    cd ${php_setup_path}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
	sed -i 's/;curl.cainfo =/curl.cainfo = \/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 5.6..."
    mkdir -p /usr/local/zend/php56
    if [ "${Is_64bit}" = "64" ] ; then
        wget ${download_Url}/src/zend-loader-php5.6-linux-x86_64.tar.gz -T20
        tar zxf zend-loader-php5.6-linux-x86_64.tar.gz
        \cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /usr/local/zend/php56/
		rm -rf zend-loader-php5.6-linux-x86_64
		rm -f zend-loader-php5.6-linux-x86_64.tar.gz
    else
        wget ${download_Url}/src/zend-loader-php5.6-linux-i386.tar.gz -T20
        tar zxf zend-loader-php5.6-linux-i386.tar.gz
        \cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so /usr/local/zend/php56/
		rm -rf zend-loader-php5.6-linux-i386
		rm -f zend-loader-php5.6-linux-i386.tar.gz
    fi

    echo "Write ZendGuardLoader to php.ini..."
cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/php56/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache

EOF

    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-56.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_56_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
    echo "Copy php-fpm init.d file..."
    \cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-56
    chmod +x /etc/init.d/php-fpm-56
	
	chkconfig --add php-fpm-56
	chkconfig --level 2345 php-fpm-56 on
	rm -f /tmp/php-cgi-56.sock
	/etc/init.d/php-fpm-56 start
	rm -f ${php_setup_path}/src.tar.gz
	echo "${php_56}" > ${php_setup_path}/version.pl
}

Install_PHP_70()
{
	cd ${run_path}
	php_version="70"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-${php_70}.tar.gz -T20
	fi
    
    tar zxf src.tar.gz
	mv php-${php_70} src
	cd src
	./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install

	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-7.0 installation failed.\033[0m";
		rm -rf ${php_setup_path}
		exit 0;
	fi
	
    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini

    cd ${php_setup_path}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
	sed -i 's/;curl.cainfo =/curl.cainfo = \/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 7..."
    echo "unavailable now."

    echo "Write ZendGuardLoader to php.ini..."
cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
;php7 do not support zendguardloader @Sep.2015,after support you can uncomment the following line.
;zend_extension=/usr/local/zend/php70/ZendGuardLoader.so
;zend_loader.enable=1
;zend_loader.disable_licensing=0
;zend_loader.obfuscation_level_support=3
;zend_loader.license_path=

;xcache

EOF

    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-70.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_70_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
	\cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-70
    chmod +x /etc/init.d/php-fpm-70
	
	chkconfig --add php-fpm-70
	chkconfig --level 2345 php-fpm-70 on
	rm -f /tmp/php-cgi-70.sock
	/etc/init.d/php-fpm-70 start
	rm -f ${php_setup_path}/src.tar.gz
	echo "${php_70}" > ${php_setup_path}/version.pl
}

Install_PHP_71()
{
	cd ${run_path}
	php_version="71"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-${php_71}.tar.gz -T20
	fi
    
    tar zxf src.tar.gz
	mv php-${php_71} src
	cd src
	./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install

	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-7.1 installation failed.\033[0m";
		rm -rf ${php_setup_path}
		exit 0;
	fi
	
    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini

    cd ${php_setup_path}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
	sed -i 's/;curl.cainfo =/curl.cainfo = \/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 7..."
    echo "unavailable now."

    echo "Write ZendGuardLoader to php.ini..."
cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
;php7 do not support zendguardloader @Sep.2015,after support you can uncomment the following line.
;zend_extension=/usr/local/zend/php71/ZendGuardLoader.so
;zend_loader.enable=1
;zend_loader.disable_licensing=0
;zend_loader.obfuscation_level_support=3
;zend_loader.license_path=

;xcache

EOF

    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-71.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_71_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
	\cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-71
    chmod +x /etc/init.d/php-fpm-71
	
	chkconfig --add php-fpm-71
	chkconfig --level 2345 php-fpm-71 on
	rm -f /tmp/php-cgi-71.sock
	/etc/init.d/php-fpm-71 start
	if [ -d "$Root_Path/server/nginx" ];then
		wget -O $Root_Path/server/nginx/conf/enable-php-71.conf ${download_Url}/conf/enable-php-71.conf -T20
	fi
	rm -f ${php_setup_path}/src.tar.gz
	echo "${php_71}" > ${php_setup_path}/version.pl
}

Install_PHP_72()
{
	cd ${run_path}
	php_version="72"
	/etc/init.d/php-fpm-$php_version stop
	php_setup_path=${php_path}/${php_version}
	
	mkdir -p ${php_setup_path}
	rm -rf ${php_setup_path}/*
	cd ${php_setup_path}
	if [ ! -f "${php_setup_path}/src.tar.gz" ];then
		wget -O ${php_setup_path}/src.tar.gz ${download_Url}/src/php-${php_72}.tar.gz -T20
	fi
    
    tar zxf src.tar.gz
	mv php-${php_72} src
	cd src
	./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    make install

	if [ ! -f "${php_setup_path}/bin/php" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: php-7.2 installation failed.\033[0m";
		rm -rf ${php_setup_path}
		exit 0;
	fi
	
    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${php_setup_path}/etc
    \cp php.ini-production ${php_setup_path}/etc/php.ini

    cd ${php_setup_path}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${php_setup_path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${php_setup_path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/g' ${php_setup_path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/g' ${php_setup_path}/etc/php.ini
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
	sed -i 's/;curl.cainfo =/curl.cainfo = \/etc\/pki\/tls\/certs\/ca-bundle.crt/' ${php_setup_path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,popen,proc_open,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' ${php_setup_path}/etc/php.ini
    sed -i 's/error_reporting =.*/error_reporting = E_ALL \& \~E_NOTICE/g' ${php_setup_path}/etc/php.ini
    sed -i 's/display_errors = Off/display_errors = On/g' ${php_setup_path}/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    echo "Install ZendGuardLoader for PHP 7..."
    echo "unavailable now."

    echo "Write ZendGuardLoader to php.ini..."
cat >>${php_setup_path}/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache

[Zend ZendGuard Loader]
;php7 do not support zendguardloader @Sep.2015,after support you can uncomment the following line.
;zend_extension=/usr/local/zend/php72/ZendGuardLoader.so
;zend_loader.enable=1
;zend_loader.disable_licensing=0
;zend_loader.obfuscation_level_support=3
;zend_loader.license_path=

;xcache

EOF

    cat >${php_setup_path}/etc/php-fpm.conf<<EOF
[global]
pid = ${php_setup_path}/var/run/php-fpm.pid
error_log = ${php_setup_path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi-72.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.status_path = /phpfpm_72_status
pm.max_children = 30
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 100
request_slowlog_timeout = 30
slowlog = var/log/slow.log
EOF
Set_PHP_FPM_Opt
	\cp ${php_setup_path}/src/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm-72
    chmod +x /etc/init.d/php-fpm-72
	
	chkconfig --add php-fpm-72
	chkconfig --level 2345 php-fpm-72 on
	rm -f /tmp/php-cgi-72.sock
	/etc/init.d/php-fpm-72 start
	if [ -d "$Root_Path/server/nginx" ];then
		wget -O $Root_Path/server/nginx/conf/enable-php-72.conf ${download_Url}/conf/enable-php-72.conf -T20
	elif [ -d "$Root_Path/server/apache" ]; then
		wget -O $Root_Path/server/apache/conf/extra/httpd-vhosts.conf http://download.bt.cn/conf/httpd-vhosts.conf
		sed -i "s/php-cgi-VERSION/php-cgi-72/g" $Root_Path/server/apache/conf/extra/httpd-vhosts.conf
	fi

	rm -f ${php_setup_path}/src.tar.gz
	echo "${php_72}" > ${php_setup_path}/version.pl
}

Update_PHP_56()
{
	cd ${run_path}
	php_version="56"
	php_setup_path=${php_path}/${php_version}
	php_update_path=${php_path}/${php_version}/update

	mkdir -p ${php_update_path}
	rm -rf ${php_update_path}/*
	
	cd ${php_update_path}
	if [ ! -f "${php_update_path}/src.tar.gz" ];then
		wget -O ${php_update_path}/src.tar.gz ${download_Url}/src/php-${php_56}.tar.gz -T20
	fi
    tar zxf src.tar.gz
    mv php-${php_56} src
    cd src

    ./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-intl
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    /etc/init.d/php-fpm-56 stop
    sleep 1
    make install
    sleep 1
    rm -rf ${php_update_path}
    Ln_PHP_Bin
    /etc/init.d/php-fpm-56 start
    echo "${php_56}" > ${php_setup_path}/version.pl
    rm -f ${php_setup_path}/version_check.pl
}
Update_PHP_70()
{
	cd ${run_path}
	php_version="70"
	php_setup_path=${php_path}/${php_version}
	php_update_path=${php_path}/${php_version}/update

	mkdir -p ${php_update_path}
	rm -rf ${php_update_path}/*
	
	cd ${php_update_path}
	if [ ! -f "${php_update_path}/src.tar.gz" ];then
		wget -O ${php_update_path}/src.tar.gz ${download_Url}/src/php-${php_70}.tar.gz -T20
	fi
    tar zxf src.tar.gz
    mv php-${php_70} src
    cd src

    ./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
    /etc/init.d/php-fpm-70 stop
    sleep 1
    make install
    rm -rf ${php_update_path}
    sleep 1
    Ln_PHP_Bin
    /etc/init.d/php-fpm-70 start
    echo "${php_70}" > ${php_setup_path}/version.pl
    rm -f ${php_setup_path}/version_check.pl
}
Update_PHP_71()
{
	cd ${run_path}
	php_version="71"
	php_setup_path=${php_path}/${php_version}
	php_update_path=${php_path}/${php_version}/update

	mkdir -p ${php_update_path}
	rm -rf ${php_update_path}/*
	
	cd ${php_update_path}
	if [ ! -f "${php_update_path}/src.tar.gz" ];then
		wget -O ${php_update_path}/src.tar.gz ${download_Url}/src/php-${php_71}.tar.gz -T20
	fi
    tar zxf src.tar.gz
    mv php-${php_71} src
    cd src

    ./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
 	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi   
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
	/etc/init.d/php-fpm-71 stop
	sleep 1
	make install
    sleep 1
    rm -rf ${php_update_path}
    Ln_PHP_Bin
    /etc/init.d/php-fpm-71 start
    echo "${php_71}" > ${php_setup_path}/version.pl
    rm -f ${php_setup_path}/version_check.pl
}
Update_PHP_72()
{
	cd ${run_path}
	php_version="72"
	php_setup_path=${php_path}/${php_version}
	php_update_path=${php_path}/${php_version}/update

	mkdir -p ${php_update_path}
	rm -rf ${php_update_path}/*
	
	cd ${php_update_path}
	if [ ! -f "${php_update_path}/src.tar.gz" ];then
		wget -O ${php_update_path}/src.tar.gz ${download_Url}/src/php-${php_72}.tar.gz -T20
	fi
    tar zxf src.tar.gz
    mv php-${php_72} src
    cd src

    ./configure --prefix=${php_setup_path} --with-config-file-path=${php_setup_path}/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
	if [ "${Is_64bit}" = "32" ];then
		sed -i 's/lcrypt$/lcrypt -lresolv/' Makefile
    fi
    make ZEND_EXTRA_LIBS='-liconv' -j${cpuCore}
	/etc/init.d/php-fpm-72 stop
	sleep 1
	make install
    sleep 1
    rm -rf ${php_update_path}
    Ln_PHP_Bin
    /etc/init.d/php-fpm-72 start
    echo "${php_72}" > ${php_setup_path}/version.pl
    rm -f ${php_setup_path}/version_check.pl
}
SetPHPMyAdmin()
{
	if [ -f "/www/server/nginx/sbin/nginx" ]; then
		webserver="nginx"
	fi
    PHPVersion=""
    if [ -f "$Root_Path/server/php/52/bin/php" ];then
        PHPVersion="52"
    fi
    if [ -f "$Root_Path/server/php/53/bin/php" ];then
        PHPVersion="53"
    fi
    if [ -f "$Root_Path/server/php/54/bin/php" ];then
        PHPVersion="54"
    fi
    if [ -f "$Root_Path/server/php/55/bin/php" ];then
        PHPVersion="55"
    fi
    if [ -f "$Root_Path/server/php/56/bin/php" ];then
        PHPVersion="56"
    fi
    if [ -f "$Root_Path/server/php/70/bin/php" ];then
        PHPVersion="70"
    fi
    if [ -f "$Root_Path/server/php/71/bin/php" ];then
        PHPVersion="71"
    fi
    if [ -f "$Root_Path/server/php/71/bin/php" ];then
        PHPVersion="72"
    fi

    
    if [ "${webserver}" == "nginx" ];then
        sed -i "s#$Root_Path/wwwroot/default#$Root_Path/server/phpmyadmin#" $Root_Path/server/nginx/conf/nginx.conf
        rm -f $Root_Path/server/nginx/conf/enable-php.conf
        \cp $Root_Path/server/nginx/conf/enable-php-$PHPVersion.conf $Root_Path/server/nginx/conf/enable-php.conf
        sed -i "/pathinfo/d" $Root_Path/server/nginx/conf/enable-php.conf
        /etc/init.d/nginx reload
    else
        sed -i "s#$Root_Path/wwwroot/default#$Root_Path/server/phpmyadmin#" $Root_Path/server/apache/conf/extra/httpd-vhosts.conf
        sed -i "0,/php-cgi/ s/php-cgi-\w*\.sock/php-cgi-${PHPVersion}.sock/" $Root_Path/server/apache/conf/extra/httpd-vhosts.conf
        /etc/init.d/httpd reload
    fi
}

Uninstall_PHP()
{
	php_version=${1/./}
	service php-fpm-$php_version stop
	chkconfig --del php-fpm-$php_version
	rm -rf $php_path/$php_version
	rm -f /etc/init.d/php-fpm-$php_version

    if [ -f "$Root_Path/server/phpmyadmin/version.pl" ];then
        SetPHPMyAdmin
    fi

    for phpV in 52 53 54 55 56 70 71 72
    do
    	if [ -f "/www/server/php/${phpV}/bin/php" ]; then
    		rm -f /usr/bin/php
    		ln -sf /www/server/php/${phpV}/bin/php /usr/bin/php
    	fi
    done
}


actionType=$1
version=$2

if [ "$actionType" == 'install' ];then
	Lib_Check
	Lib_Check2
	case "$version" in
		'5.2')
			Install_PHP_52
			;;
		'5.3')
			Install_PHP_53
			;;
		'5.4')
			Install_PHP_54
			;;
		'5.5')
			Install_PHP_55
			;;
		'5.6')
			Install_PHP_56
			;;
		'7.0')
			Install_PHP_70
			;;
		'7.1')
			Install_PHP_71
			;;
		'7.2')
			Install_PHP_72
			;;
	esac
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_PHP $version
elif [ "$actionType" == 'update' ];then
	case "$version" in
		'5.6')
			Update_PHP_56
			;;
		'7.0')
			Update_PHP_70
			;;
		'7.1')
			Update_PHP_71
			;;
		'7.2')
			Update_PHP_72
			;;
	esac
fi
