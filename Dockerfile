FROM basex/basexhttp:latest
ARG SAXON_VERSION=10.6
USER root
COPY ./webapp /srv/basex/webapp
RUN ls -l /srv/basex/webapp
RUN curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar -o saxon-he-${SAXON_VERSION}.jar
RUN ls -l
RUN ls -l /usr/src/basex/basex-api/lib/

RUN cp ./saxon-he-${SAXON_VERSION}.jar /usr/src/basex/basex-api/lib/saxon-he-${SAXON_VERSION}.jar

RUN ls -l /usr/src/basex/basex-api/lib/


