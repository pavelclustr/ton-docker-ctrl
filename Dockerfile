FROM ubuntu:20.04

# setup locale and timezone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y locales
# install cmake
RUN apt-get --yes install cmake make git wget

# install python
RUN apt-get --yes update
RUN apt-get --yes install python3-dev python3-pip python3-wheel

# install systemctl
RUN wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py \
     -O /usr/bin/systemctl && chmod +x /usr/bin/systemctl
RUN wget https://raw.githubusercontent.com/ton-blockchain/mytonctrl/master/scripts/install.sh 
RUN /bin/bash install.sh -i -m full

RUN apt install --yes nano htop iproute2

# patch mytoncrtl
ADD scripts/ /scripts/
RUN python3 /scripts/patch_baseline.py

WORKDIR /root

ENTRYPOINT ["/scripts/entrypoint.sh"]