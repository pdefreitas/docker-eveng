FROM ubuntu:16.04

LABEL MAINTAINER="pdefreitas"

USER root
SHELL [ "/bin/bash" ]

COPY ./etc/* /etc/

COPY ./images/iol/* /opt/unetlab/addons/iol/bin/

RUN apt-get install wget bash

RUN wget -O - http://www.eve-ng.net/repo/eczema@ecze.com.gpg.key | sudo apt-key add -

RUN sudo add-apt-repository "deb [arch=amd64]  http://www.eve-ng.net/repo xenial main"

RUN apt-get update && sudo apt-get upgrade -y

RUN apt-get install eve-ng\
                    python \
                    python-pip \
                    build-essential

RUN /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

RUN cp -rp /lib/firmware/$(uname -r)/bnx2 /lib/firmware/

COPY entrypoint.sh /root/entrypoint.sh
COPY piscokeygen.py /root/piscokeygen.py

ENTRYPOINT [ "/root/entrypoint.sh" ]