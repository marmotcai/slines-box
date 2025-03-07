#!/bin/bash

read -p "请输入用户名：" USER
    echo -e "请输入密码: \c"
    while : ;do
        char=` #这里是反引号，tab键上面那个
            stty cbreak -echo
            dd if=/dev/tty bs=1 count=1 2>/dev/null
            stty -cbreak echo
        ` #这里是反引号，tab键上面那个
        if [ "$char" = "" ];then
            echo #这里的echo只是为换行
            break
        fi
        PASS="$PASS$char"
        echo -n "*"
    done

echo $USER
echo $PASS
