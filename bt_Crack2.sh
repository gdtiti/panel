yum install unzip -y
cd /www/server/panel/class
wget https://github.com/gdtiti/panel/raw/master/bt_crack.zip
unzip -O bt_crack.zip
rm -f bt_crack.zip
wget -O update.sh https://github.com/gdtiti/panel/raw/master/install/update_pro.sh && bash update.sh pro
wget https://github.com/gdtiti/panel/raw/master/bt.zip
unzip -o bt.zip
rm -f bt.zip
echo -e "安装完成! 请等待服务器重启后连接宝塔检测是否安装完成"
rm -f install
reboot
fi   
exit 0;