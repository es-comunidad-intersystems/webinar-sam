#ARG IMAGE=intersystemsdc/irishealth-community:2021.2.0.649.0-zpm
ARG IMAGE=intersystemsdc/irishealth-community:2022.1.0.114.0-zpm
FROM ${IMAGE}

# create /app
USER root
RUN mkdir /app && chown $ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /app

USER ${ISC_PACKAGE_MGRUSER}

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP irissession.sh /
RUN chmod +x /irissession.sh

# copy source code
WORKDIR /app 

# regular Demo HL7 production
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP install /app/install
# copy src code
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP src /app/src
# test files for HL7 production
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP test /test

#For Python Metric
RUN pip3 install --target /usr/irissys/mgr/python psutil

SHELL ["/irissession.sh"]


RUN \
  #Change some config values
  zn "%SYS" \
  set sc=##class(Config.config).Get(.prop) \
  set prop("gmheap")=90000,prop("locksiz")=267772216 \
  set prop("globals8kb")=600,prop("routines")=300 \
  set sc=##class(Config.config).Modify(.prop) \
  #Change some SQL Config
  set sc=##class(Config.SQL).Get(.p) set p("ExtrinsicFunctions")=1  \
  set sc=##class(Config.SQL).Modify(.p) \
  zn "USER" \
  # install webterminal
  zpm "install webterminal" \
  # install demo
  do $SYSTEM.OBJ.LoadDir("/app/install/HL7", "ck", ,1) \
  do $SYSTEM.OBJ.LoadDir("/app/install/Loan", "ck", ,1) \
  do $system.OBJ.Load("/app/install/Loan/latest/csp/app/DemoLoanForm.csp", "ck") \
  do $system.OBJ.Load("/app/install/Loan/latest/csp/app/DemoLoanSubmit.csp", "ck") \ 
  # load src code
  do $system.OBJ.LoadDir("/app/src", "fck", ,1) \
  do ##class(%Library.Routine).CompileList("SLEEP.MAC") \
  # auto-start production
  do ##class(Ens.Director).SetAutoStart("Demo.HL7.MsgRouter.Production") \ 
  set sc = 1
  
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
CMD [ "-l", "/usr/irissys/mgr/messages.log" ]
