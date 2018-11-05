#!/bin/bash
cd /www/server
mv panel panel.bak
wget -N --no-check-certificate https://github.com/gdtiti/panel/raw/master/install/src/panel_c.zip
unzip -o panel_c.zip
rm -f panel_c.zip
rm /root/bt_Creak.sh
/etc/init.d/bt restart
echo -e "\033[33;1m安装完成! 打开宝塔面板查看 \n个人主页:http://67zz/cn \n修改自:Eleven\033[0m"   
exit 0;