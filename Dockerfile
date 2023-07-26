FROM basex/basexhttp:latest
USER basex
COPY ./webapp /srv/basex/webapp
COPY ./.basex /srv/basex
COPY saxon/saxon-he-10.6.jar /usr/src/basex/basex-api/lib/saxon-he-10.6.jar
RUN basex -c 'REPO INSTALL https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar' -dv
RUN basex -c 'REPO LIST' -dv



