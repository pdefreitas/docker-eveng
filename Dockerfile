FROM ubuntu:16.04

LABEL MAINTAINER="pdefreitas"

USER root

COPY ./etc/* /etc/

COPY ./images/iol/* /opt/unetlab/addons/iol/bin/

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

RUN echo "root:eve" | chpasswd

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y apt-utils wget bash software-properties-common sudo

# add run user
RUN useradd -ms /bin/bash user
RUN echo "user:password" | chpasswd

RUN wget -q -O- http://www.eve-ng.net/repo/eczema@ecze.com.gpg.key | apt-key add

RUN add-apt-repository "deb [arch=amd64]  http://www.eve-ng.net/repo xenial main"

RUN apt-get update

USER user

RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y eve-ng \
                                                           python \
                                                           python-pip \
                                                           build-essential

RUN apt-get upgrade -y

RUN sudo cp -rp /lib/firmware/$(uname -r)/bnx2 /lib/firmware/

USER root

RUN /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

RUN sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
RUN sed -i -e 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 console=ttyS1,115200"/' /etc/default/grub
RUN update-grub

#add a new systemd file to ensure apache2 starts
RUN cat >> /lib/systemd/system/apache2.service.d/apache2-systemd.conf << EOF \
[Unit] \
Description=Apache HTTP Server \
After=syslog.target network.target \
[Service] \
Type=forking \
RemainAfterExit=no \
Restart=always \
PIDFile=/var/run/apache2/apache2.pid \
[Install] \
WantedBy=multi-user.target \
EOF

RUN touch /opt/ovf/.configured

COPY entrypoint.sh /root/entrypoint.sh
COPY piscokeygen.py /root/piscokeygen.py

ENTRYPOINT [ "/root/entrypoint.sh" ]