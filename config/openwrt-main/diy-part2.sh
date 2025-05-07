#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
#sed -i.bak "s/\(DISTRIB_DESCRIPTION='.*\)'/\1 $(date +%Y-%m-%d)'/" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='official'" >>package/base-files/files/etc/openwrt_release

#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
# svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
git clone https://github.com/Lieoxc/openwrt-package.git package/lieo-package

cp package/lieo-package/config_generate  ./package/base-files/files/bin/
cp package/lieo-package/sysupgrade.conf  ./package/base-files/files/etc/
# 处理redis编译
cp -rf package/lieo-package/redis-patch/files/* ./feeds/packages/libs/redis/files/
cp -rf package/lieo-package/redis-patch/Makefile ./feeds/packages/libs/redis/

# 处理mosquitto编译
cp -rf package/lieo-package/mosquitto-patch/*  ./feeds/packages/net/mosquitto/

# 处理postgresql编译
cp -rf package/lieo-package/postgresql-patch/* ./feeds/packages/libs/postgresql/

# 前端文件解压
unzip package/lieo-package/iot/files/etc/iot/configs/dist.zip  -d  package/lieo-package/iot/files/etc/iot/configs/
rm -rf package/lieo-package/iot/files/etc/iot/configs/dist.zip

# wifi默认设置
cp package/lieo-package/mac80211.sh ./package/kernel/mac80211/files/lib/wifi/

cp package/lieo-package/plugin-monitor ./package/base-files/files/etc/init.d/
cp package/lieo-package/plugin-monitor.sh ./package/base-files/files/bin/

chmod +x package/lieo-package/data_collect/bin/data_collect
chmod +x package/lieo-package/iot/bin/iot
# 前面已经拷贝完了，这里删除掉
rm -rf package/lieo-package/mosquitto-patch 
rm -rf package/lieo-package/postgresql-patch 
rm -rf package/lieo-package/redis-patch
rm -rf package/lieo-package/config_generate
rm -rf package/lieo-package/sysupgrade.conf
rm -rf package/lieo-package/mac80211.sh
rm -rf package/lieo-package/plugin-monitor
rm -rf package/lieo-package/plugin-monitor.sh

# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
