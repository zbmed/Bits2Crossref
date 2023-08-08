FROM basex/basexhttp:latest
ARG SAXON_VERSION=10.6
USER basex
COPY ./webapp /srv/basex/webapp
COPY ./.basex /srv/basex
RUN curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar -o saxon-he-${SAXON_VERSION}.jar
ADD ./saxon-he-${SAXON_VERSION}.jar /saxon/saxon-he-${SAXON_VERSION}.jar
COPY /saxon/saxon-he-${SAXON_VERSION}.jar /usr/src/basex/basex-api/lib/saxon-he-${SAXON_VERSION}.jar
RUN basex -c 'REPO INSTALL https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar' -dv
RUN basex -c 'REPO LIST' -dv



