FROM ubuntu:16.04

LABEL MAINTAINER="pdefreitas"

USER root

COPY ./etc/* /etc/

COPY ./images/iol/* /opt/unetlab/addons/iol/bin/

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y wget bash software-properties-common

RUN wget -q -O- http://www.eve-ng.net/repo/eczema@ecze.com.gpg.key | apt-key add

RUN add-apt-repository "deb [arch=amd64]  http://www.eve-ng.net/repo xenial main"

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y eve-ng \
                                                      python \
                                                      python-pip \
                                                      build-essential

RUN apt-get upgrade -y

RUN /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

RUN cp -rp /lib/firmware/$(uname -r)/bnx2 /lib/firmware/

COPY entrypoint.sh /root/entrypoint.sh
COPY piscokeygen.py /root/piscokeygen.py

ENTRYPOINT [ "/root/entrypoint.sh" ]