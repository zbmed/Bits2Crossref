module namespace e = 'some.namespace';

declare
  %rest:path("/bits2crossref")
  %rest:POST("{$xml}")
function e:bits2crossref($xml as item())
{
  let $options := map{'indent':'no',
                    'omit-xml-declaration':'no',
                    'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN',
                    'doctype-system':'JATS-archivearticle1-mathml3.dtd'}
  let $xsl := doc('./xsl/bits2crossref.xsl')
  return 
  if ($xml[.instance of xs:string]) then (
    let $new-xml := e:strip-preamble($xml)
    return xslt:transform-text($new-xml,$xsl,$options)
  )
  else if ($xml[.instance of document-node()]) then (
    xslt:transform-text($xml,$xsl,$options)
  )
  else (error(xs:QName("basex:error"),'Input must be supplied as a string or XML document.'))
};


declare function e:strip-preamble($xml){
  if (contains($xml,'<?covid-19-tdm ?>'))
    then ('<?covid-19-tdm'||substring-after($xml,'<?covid-19-tdm'))
  else ('<article'||substring-after($xml,'<article'))
};
