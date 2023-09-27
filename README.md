# Bits2Crossref

_local_


1. Make sure you have docker installed and running.

    `docker -v`

    `docker ps`

2. Then use this command to pull and run the docker container:

    `docker build . --pull -t bits:crossref`

    `docker run --pull=always -p 1984:1984 -p 8984:8984 bits:crossref`

3. Open a browser and go to:

    [http://admin:admin@localhost:8984/rest?run=form.html](http://admin:admin@localhost:8984/rest?run=form.html)


`admin:admin` are the standard credentials for the webapps http basic authentication.

-------------------------------------------------
Open-Access-Tage 2023 
27.-29. September 2023 | Berlin 



