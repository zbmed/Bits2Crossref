# Bits2Crossref

_local_

To use the transformation engine with the provided stylesheets:

1. Use Git and `git clone https://github.com/zbmed/Bits2Crossref.git` 

2. Edit this section inside webapp/xsl/bits2crossref.xsl to your needs:

```
<crossref:metadata>
	<depositor>
	    <!-- depositor name  -->
	    <depositor_name>###depositor_name###</depositor_name>
	    <!-- depositor email  -->
	    <email_address>###depositor_email###</email_address>
    </depositor>
    <registrant>###registrant###</registrant>	
</crossref:metadata>
```



3. Make sure you have docker installed and running.


    `docker -v`
    
    `docker ps`


4. Then use this command to pull and run the docker container.


    `docker build . --pull -t bits:crossref`

    `docker run --pull=always -p 1984:1984 -p 8984:8984 bits:crossref`


5. Open a browser and go to:


    [http://admin:admin@localhost:8984/rest?run=form.html](http://admin:admin@localhost:8984/rest?run=form.html)


`admin:admin` are the standard credentials for the webapps http basic authentication.

-------------------------------------------------
Open-Access-Tage 2023 
27.-29. September 2023 | Berlin 



