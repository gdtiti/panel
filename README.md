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

5.一键升级6.3版本

wget -O update.sh https://github.com/gdtiti/panel/raw/master/install/update6.sh && bash update6.sh free
或者
curl https://github.com/gdtiti/panel/raw/master/update6.sh|bash

6.一键安装6.3版本
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


===我的使用顺序=====================================================
1、安装

wget -O install.sh https://github.com/gdtiti/panel/raw/master/install.sh && bash install.sh

2、升级专业版

wget -T 5 -O panel.zip https://github.com/gdtiti/panel/raw/master/install/update/LinuxPanel-5.9.0_pro.zip
unzip -o panel.zip -d /www/server/ > /dev/null
cd /www/server/panel/
rm -f /www/server/panel/data/templates.pl
cd /www/server/panel
python tools.py o
sleep 1 && service bt restart > /dev/null 2>&1 &

3、破解

wget https://github.com/gdtiti/panel/raw/master/bt_Crack2.sh && chmod 755 bt_Crack2.sh && bash bt_Crack2.sh

4、再次升级专业版

wget -O update_pro.sh https://github.com/gdtiti/panel/raw/master/update_pro.sh && bash update_pro.sh pro

5、再次破解

wget https://github.com/gdtiti/panel/raw/master/bt_Crack2.sh && chmod 755 bt_Crack2.sh && bash bt_Crack2.sh

6、修改main.py

------------------------------------------------
2018/09/24:  破解后面板无法启动。

删除 /www/server/panel/main.pyc

修改 /www/server/panel/main.py


在文本最后找到check_system()方法，在最后一句话加上#。然后重启服务器或者宝塔。

#panelSite.panelSite().set_mt_conf()

------------------------------------------------

2018/11/07:	 破解后面板总是不停的转圈


删除 /www/server/panel/class/panelPlugin.pyc

修改 /www/server/panel/class/panelPlugin.py

在获取云端插件列表时直接返回您的插件列表已是最新版本

def getCloudPlugin(self,get):
        return public.returnMsg(True,'您的插件列表已经是最新版本-1!');
#这里可以换成我自己存储的列表
import json
        if not hasattr(web.ctx.session,'downloadUrl'): web.ctx.session.downloadUrl = 'http://download.bt.cn';
        
        #获取列表
        try:
            newUrl = public.get_url();
            if os.path.exists('plugin/beta/config.conf'):
                downloadUrl = newUrl + '/install/list.json'
            else:
                downloadUrl = newUrl + '/install/list_pro.json'
            data = json.loads(public.httpGet(downloadUrl))
            web.ctx.session.downloadUrl = newUrl;
        except:
            downloadUrl = web.ctx.session.downloadUrl + '/install/list_pro.json'
            data = json.loads(public.httpGet(downloadUrl))


之所以两次升级专业版 两次破解 估计是升级专业版时少了文件 需要靠破解覆盖以后再次升级才完整 暂时这样可以完美安装我就不再研究为啥了

---------------------------------------------
破解以后无法增加站点

删除 /www/server/panel/class/panelSite.pyc

修改 /www/server/panel/class/panelSite.py 

def set_mt_conf(self):
        #t1 = ['315', '022', '022', '022', '315', '018', '04', '017', '021', '04', '017', '315', '015', '00', '013', '04', '011', '315', '02', '011', '00', '018', '018', '315', '015', '00', '013', '04', '011', '10', '020', '019', '07', '314', '015', '024']
        #t2 = ['02', '07', '04', '02', '010', '54', '015', '011', '020', '06', '08', '013', '54', '018', '019', '00', '019', '020', '018']
        #t3 = ['315', '022', '022', '022', '315', '018', '04', '017', '021', '04', '017', '315', '015', '00', '013', '04', '011', '315', '02', '011', '00', '018', '018', '315', '015', '00', '013', '04', '011', '115', '011', '020', '06', '08', '013', '314', '015', '024', '02']
        #m1 = self.get_string_find(t1)
        #m2 = self.get_string_find(t2)
        #m3 = self.get_string_find(t3)
        #conf = public.readFile(m1)
        #if conf.find(m2) == -1: return False
        #if os.path.exists(m3): 
        #    public.writeFile(m3,public.readFile(m3).replace('R','F'))
        #    public.ExecShell('/etc/init.d/bt reload &')
        return True
