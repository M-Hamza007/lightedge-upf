## build : docker build -t lightedge-upfservice .
## run :   docker run --net=host --rm --privileged -it lightedge-upfservice

FROM ubuntu:18.04
# MAINTAINER g.baggio@fbk.eu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN buildDeps='build-essential git cmake autoconf ca-certificates unzip net-tools apt-utils' \
    && set -x \
    && apt-get update \
    && apt-get install -y linux-image-5.4.0-104-generic \
    && apt-get install -y linux-headers-5.4.0-104-generic \
    && apt-get install -y $buildDeps \
    && apt-get install -y iptables iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/kohler/click.git click \
    && cd click \
    && git checkout dabb6d61a28a0f350af93bc1f081dd913d8c8548 \
    && LINUX_VERSION='5.4.0-104-generic' ./configure --with-linux=/usr/src/linux-headers-$LINUX_VERSION --with-linux-map=/boot/System.map-$LINUX_VERSION --enable-linuxmodule --disable-userlevel \
    && make \
    && make install \
    && cd / \
    && rm -rf click \
    && git clone https://github.com/lightedge/upflib upflib \
    && cd upflib \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DBUILD_SHARED_LIBS=OFF \
             -DCMAKE_INSTALL_PREFIX=/tmp/build \
    && make \
    && make install \
    && cd / \
    && git clone https://github.com/lightedge/lightedge-upfservice lightedge-upfservice \
    && cd lightedge-upfservice \
    && ./configure --with-click=/usr/local --with-upflib=/tmp/build \
    && make \
    && make install 

RUN ls /

ADD modes /modes
ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
