FROM ubuntu:16.04

LABEL MAINTAINER="pdefreitas"

USER root
SHELL [ "/bin/bash" ]

COPY ./etc/* /etc/

COPY ./images/iol/* /opt/unetlab/addons/iol/bin/

RUN /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

RUN wget -O - http://www.eve-ng.net/repo/eczema@ecze.com.gpg.key | sudo apt-key add -

RUN add-apt-repository "deb [arch=amd64]  http://www.eve-ng.net/repo xenial main"

RUN apt update && sudo apt upgrade -y

RUN apt install eve-ng\
                python \
                python-pip \
                build-essential

RUN cp -rp /lib/firmware/$(uname -r)/bnx2 /lib/firmware/

COPY entrypoint.sh /root/entrypoint.sh
COPY piscokeygen.py /root/piscokeygen.py

ENTRYPOINT [ "/root/entrypoint.sh" ]