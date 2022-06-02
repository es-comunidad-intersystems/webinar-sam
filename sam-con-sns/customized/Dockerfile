ARG IMAGE=containers.intersystems.com/intersystems/sam:1.1.0.107
FROM ${IMAGE}
#SAM 1.1.0.107 uses Ubuntu 18.04.5 LTS bionic

#USER
USER root
#Install pip3 and boto3
#RUN add-apt-repository universe
#DNS update: This is needed to run yum and to let the docker build process access the internet. 
#RUN "sh" "-c" "echo nameserver 8.8.8.8 >> /etc/resolv.conf"
RUN apt-get update && apt-get upgrade
RUN apt-get install python3-pip
RUN apt-get install n
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "install-pip3-ubuntu.py"
RUN python3 install-pip3-ubuntu.py
RUN pip3 install boto3

# create /app
RUN mkdir /app && chown $ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /app

USER ${ISC_PACKAGE_MGRUSER}

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP ./irissession.sh /
RUN chmod +x /irissession.sh

# copy source code
WORKDIR /app 

# copy src code
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP src /app/src

SHELL ["/irissession.sh"]

RUN \
  zn "USER" \
  # install webterminal
  # zpm "install webterminal" \
  # load src code
  do $system.OBJ.LoadDir("/app/src", "ck", ,1) \
  set sc = 1
  
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
CMD [ "-l", "/usr/irissys/mgr/messages.log" ]