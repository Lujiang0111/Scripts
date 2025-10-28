# Esxi修改https端口

+ 注意：只适用于esxi6/7，8及往后的版本不适用！
+ 注意：只能修改https端口，修改http端口会导致网页无法打开。

1. 登录esxi网页，打开ssh功能（主机->操作->服务->启用安全shell）。
2. 使用xshell等工具连接esxi（身份验证使用Keyboard Interactive）。
3. 输入

    ```shell
    vi /etc/vmware/rhttpproxy/config.xml
    /443
    ```

    修改443为自己想要的端口，如4433。
4. 在datastore创建一个自定义防火墙文件，如httpsPortNew.xml。

    ```shell
    mkdir -p /vmfs/volumes/datastore1/Scripts
    vi /vmfs/volumes/datastore1/Scripts/httpsPortNew.xml
    ```

    httpsPortNew.xml文件内容为

    ```xml
    <ConfigRoot>
        <service id="0000">
            <id>httpsPortNew</id>
            <rule id='0000'>
                <direction>inbound</direction>
                <protocol>tcp</protocol>
                <porttype>dst</porttype>
                <port>4433</port>
            </rule>
            <enabled>true</enabled>
            <required>false</required>
        </service>
    </ConfigRoot>
    ```

5. 在开机启动脚本local.sh中添加防火墙配置

    ```shell
    vi /etc/rc.local.d/local.sh
    ```

    在```exit 0```前添加

    ```shell
    # modify https port
    \cp /vmfs/volumes/datastore1/Scripts/httpsPortNew.xml /etc/vmware/firewall/ -r
    esxcli network firewall refresh
    ```

6. 在ssh中输入```reboot```或在网页中点击**重新引导**，完成配置。
