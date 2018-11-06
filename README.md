可以批量替换的路径
https://github.com/gdtiti/panel/raw/master
updateLinux
updateLinuxBate
需要手动替换路径

1.安装
wget -O install.sh https://github.com/gdtiti/panel/raw/master/install.sh && bash install.sh
或者
wget -O install.sh https://github.com/gdtiti/panel/raw/master/install-ubuntu.sh && bash install.sh

2.单纯升级专业版
wget -O update_pro.sh https://github.com/gdtiti/panel/raw/master/update_pro.sh && bash update_pro.sh pro

3.从专业版降级到免费版
wget -O update.sh http://download.bt.cn/install/update.sh && bash update.sh free

4.一键破解
wget https://github.com/gdtiti/panel/raw/master/bt_Crack.sh && chmod 755 bt_Crack.sh && bash bt_Crack.sh
或者
wget https://github.com/gdtiti/panel/raw/master/bt_Crack2.sh && chmod 755 bt_Crack2.sh && bash bt_Crack2.sh
或者用代码方式破解(这种需要先升级专业版然后这里是修改过期时间)
wget https://github.com/gdtiti/panel/raw/master/bt_Crack3.sh && chmod 755 bt_Crack3.sh && bash bt_Crack3.sh


6.一键升级6.3版本
wget -O update.sh https://github.com/gdtiti/panel/raw/master/install/update6.sh && bash update6.sh free
或者
curl https://github.com/gdtiti/panel/raw/master/update6.sh|bash

7.一键安装6.3版本
wget -O install.sh https://github.com/gdtiti/panel/raw/master/install_6.0.sh && bash install_6.0.sh
或者
wget -O install.sh https://github.com/gdtiti/panel/raw/master/install-ubuntu_6.0.sh && bash install-ubuntu_6.0.sh

--------------------------
cd /www/server/panel && python tools.pyc panel 123456
修改面板密码
执行后，最后一列 316927639 是帐号，密码是 123456 登录ip:8888修改即可。


2018/09/24:  破解后面板无法启动。

删除 /www/server/panel/main.pyc

修改 /www/server/panel/main.py

在文本最后找到check_system()方法，在最后一句话加上#。然后重启服务器或者宝塔。

#panelSite.panelSite().set_mt_conf()


--------------------------
如果更新后未生效执行
service bt restart
重启宝塔面板