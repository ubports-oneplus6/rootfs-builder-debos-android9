#!/bin/sh

CHANNEL=${1:-devel}
ARCH=${2:-armhf}

# Temporary set up the nameserver
mv /etc/resolv.conf /etc/resolv2.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

echo "deb http://repo.ubports.com/ xenial_-_android9 main" >> /etc/apt/sources.list.d/ubports-android9.list

echo "Package: *" >> /etc/apt/preferences.d/ubports-android9.pref
echo "Pin: release o=UBports,a=xenial_-_android9" >> /etc/apt/preferences.d/ubports-android9.pref
echo "Pin-Priority: 2010" >> /etc/apt/preferences.d/ubports-android9.pref

if [ "$CHANNEL" == "edge" ]; then
    echo "deb http://repo.ubports.com/ xenial_-_edge_-_android9 main" >> /etc/apt/sources.list.d/ubports-android9.list

    echo "Package: *" >> /etc/apt/preferences.d/ubports-android9.pref
    echo "Pin: release o=UBports,a=xenial_-_edge_-_android9" >> /etc/apt/preferences.d/ubports-android9.pref
    echo "Pin-Priority: 2020" >> /etc/apt/preferences.d/ubports-android9.pref
fi

apt update
apt upgrade -y --allow-downgrades

apt install -y bluebinder ofono-ril-binder-plugin pulseaudio-modules-droid-28
# sensorfw
apt remove -y qtubuntu-sensors
apt install -y libsensorfw-qt5-hybris libsensorfw-qt5-configs libsensorfw-qt5-plugins libqt5sensors5-sensorfw qtubuntu-position
# hfd-service
apt install -y hfd-service libqt5feedback5-hfd hfd-service-tools
# in-call audio
apt install -y pulseaudio-modules-droid-hidl-28 audiosystem-passthrough

# Media
wget https://ci.ubports.com/job/ubports/job/gst-plugins-bad-packaging/job/xenial_-_edge_-_android8_-_testing/2/artifact/gstreamer1.0-hybris_1.8.3-1ubuntu0.3~overlay2_${ARCH}.deb
dpkg -i gstreamer1.0-hybris_1.8.3-1ubuntu0.3~overlay2_${ARCH}.deb
rm gstreamer1.0-hybris_1.8.3-1ubuntu0.3~overlay2_${ARCH}.deb

# custom hfd-service
mkdir -p /root/hfd
wget https://build.lolinet.com/file/halium/ubport/packages/hfd-service/hfd-service-tools_0.1.1_${ARCH}.deb -P /root/hfd/
wget https://build.lolinet.com/file/halium/ubport/packages/hfd-service/hfd-service_0.1.1_${ARCH}.deb -P /root/hfd/
wget https://build.lolinet.com/file/halium/ubport/packages/hfd-service/libqt5feedback5-hfd_0.1.1_${ARCH}.deb -P /root/hfd/
wget https://build.lolinet.com/file/halium/ubport/packages/hfd-service/qml-module-hfd_0.1.1_${ARCH}.deb -P /root/hfd/

dpkg -i /root/hfd/*.deb
rm -rf /root/hfd
apt-mark hold hfd-service-tools hfd-service libqt5feedback5-hfd qml-module-hfd

# Restore symlink
rm /etc/resolv.conf
mv /etc/resolv2.conf /etc/resolv.conf
