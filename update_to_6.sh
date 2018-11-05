#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

py26=$(python -V 2>&1|grep '2.6.')
if [ "$py26" != "" ];then
	echo "====================================="
	echo "抱歉, Centos6.x无法通过此脚本升级到6.0!";
	exit 0;
fi

yunsuo=$(ps aux|grep yunsuo_agent_service|grep -v grep)
if [ "$yunsuo" != "" ];then
	isTest=/etc/init.d/bt_0000001111.pl
	echo 'True' > $isTest
	if [ ! -f $isTest ];then
		echo "====================================================="
		echo "检测到您的系统中安装有云锁，请先将云锁的[系统加固]功能关闭，再重新执行升级命令";
		exit 0;
	fi
	rm -f $isTest
fi

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file https://github.com/gdtiti/panel/raw/master/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL
setup_path=/www
/etc/init.d/bt stop

rm -rf $setup_path/server/panel/static
rm -rf $setup_path/server/panel/class
rm -rf $setup_path/server/panel/templates
rm -f $setup_path/server/panel/*.py
rm -f $setup_path/server/panel/*.pyc

wget -O panel.zip $download_Url/install/src/panel6.zip -T 10
wget -O /etc/init.d/bt $download_Url/install/src/bt6.init -T 10
chmod +x /etc/init.d/bt
if [ -f "$setup_path/server/panel/data/default.db" ];then
	if [ -d "/$setup_path/server/panel/old_data" ];then
		rm -rf $setup_path/server/panel/old_data
	fi
	mkdir -p $setup_path/server/panel/old_data
	mv -f $setup_path/server/panel/data/default.db $setup_path/server/panel/old_data/default.db
	mv -f $setup_path/server/panel/data/system.db $setup_path/server/panel/old_data/system.db
	mv -f $setup_path/server/panel/data/port.pl $setup_path/server/panel/old_data/port.pl
fi

unzip -o panel.zip -d $setup_path/server/ > /dev/null

if [ -d "$setup_path/server/panel/old_data" ];then
	mv -f $setup_path/server/panel/old_data/default.db $setup_path/server/panel/data/default.db
	mv -f $setup_path/server/panel/old_data/system.db $setup_path/server/panel/data/system.db
	mv -f $setup_path/server/panel/old_data/port.pl $setup_path/server/panel/data/port.pl
	if [ -d "/$setup_path/server/panel/old_data" ];then
		rm -rf $setup_path/server/panel/old_data
	fi
fi

rm -f panel.zip
cd $setup_path/server/panel/
rm -f /dev/shm/session.db
python -m py_compile tools.py
pip install itsdangerous==0.24
pip install psutil chardet virtualenv Flask Flask-Session Flask-SocketIO flask-sqlalchemy Pillow gunicorn gevent-websocket paramiko
python tools.py update_to6

if [ ! -f /root/.ssh/id_rsa.pub ];then
	ssh-keygen -q -t rsa -P "" -f /root/.ssh/id_rsa
fi
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "====================================="
/etc/init.d/bt start
echo "已成功升级到[6.0]";

