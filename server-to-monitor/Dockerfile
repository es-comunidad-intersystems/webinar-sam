
#ARG IMAGE=store/intersystems/iris-community:2021.2.0.649.0
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2021.2.0.649.0
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2022.1.0.199.0

FROM $IMAGE

USER ${ISC_PACKAGE_MGRUSER}

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP irissession.sh /
RUN chmod +x /irissession.sh

# copy iris source code
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP src /tmp

SHELL ["/irissession.sh"]

RUN \
  zn "USER" \
  # load & compile source code
  do $SYSTEM.OBJ.LoadDir("/tmp", "ck", , 1) \
  do ##class(%File).RemoveDirectoryTree("/tmp") \
  # Add Role
  zn "%SYS" \
  set tApp=##class(Security.Applications).%OpenId("/api/monitor") \
  set tRole=tApp.MatchRoles.GetAt(1) \
  set tRole=":%DB_USER"_tRole \
  do tApp.MatchRoles.SetAt(tRole,1) \
  set sc=tApp.%Save(1) \
  #set sc = 1
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]