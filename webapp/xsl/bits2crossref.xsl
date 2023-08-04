<?xml version="1.0"?>
<!-- ========================================================================== -->
<!-- XSL Name         : BITS2CrossRef.xsl (version 1.0)                         -->
<!-- Created By       : ZB MED Information Centre for Life Sciences             -->
<!-- Purpose          : To extract metadata for CrossRef from BITS coded XML    -->
<!-- Creation Date    : June 27, 2023                                           -->
<!-- Command Line     : java -jar saxon8.jar input.xml BITS2CrossRef.xsl        -->
<!--                     meta=input_meta.xml >output.xml                      	-->
<!--                                                      						-->
<!-- ========================================================================== -->


<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
				xmlns="http://www.crossref.org/schema/4.3.6"
				xmlns:xsldoc="http://www.bacman.net/XSLdoc" 
				xmlns:xlink="http://www.w3.org/1999/xlink" 
				xmlns:fr="http://www.crossref.org/fundref.xsd"
				xmlns:ai="http://www.crossref.org/AccessIndicators.xsd"
        		xmlns:jatsFn="http://www.crossref.org/functions/jats"
				exclude-result-prefixes="xsldoc">

<xsl:output method="xml" 
            indent="yes" 
            encoding="UTF-8"/>

	<!-- One of these two fields must be populated -->
	<xsl:param name="metaContents" as="node()*" />
	<xsl:param name="meta" as="xs:string" select="''"/>
	<xsl:variable name="metafile">
		<xsl:if test="empty($metaContents) and $meta=''">
			<xsl:message terminate="yes">Must specify meta information - either as a nodeset in 'metaContents' or as a filename via 'meta'</xsl:message>
		</xsl:if>
		<xsl:sequence select="if (not(empty($metaContents))) then $metaContents else document($meta)"/>
	</xsl:variable>

<xsl:variable name="date" select="adjust-date-to-timezone(current-date(), ())"/>
<xsl:variable name="time" select="format-time(current-time(),'[H01][m01][s01]')"/>
<xsl:variable name="tempdatetime" select="concat($date,'',$time)"/>
<xsl:variable name="datetime" select="translate($tempdatetime,':-.','')"/>

<!-- ========================================================================== -->
<!-- Root Element                                                               -->
<!-- ========================================================================== -->
<xsl:template match="/">
	<xsl:choose>
		
		<xsl:when test="book">
			<doi_batch version="4.3.6">
					<xsl:attribute name="xsi:schemaLocation">http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schema/deposit/crossref4.3.6.xsd</xsl:attribute>
				<head>
					<xsl:apply-templates select="//front"/>

				</head>
				<body>
					<book>
						<xsl:apply-templates select="//book-meta"/>
											
					</book>
				</body>
			</doi_batch>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="true"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ========================================================================== -->
<!-- Book Front Matter Element                                                       -->
<!-- ========================================================================== -->
	<xsl:template match="front">
		<xsl:variable name="noIdComment"><xsl:comment>No book-id has been entered by user</xsl:comment></xsl:variable>
		<xsl:variable name="noPublisherNameComment"><xsl:comment>Publisher's Name not found in the input file</xsl:comment></xsl:variable>
		<xsl:variable name="noEmailAddressComment"><xsl:comment>NO e-mail address has been entered by the user</xsl:comment></xsl:variable>

		<doi_batch_id>
			<xsl:sequence select="(jatsFn:findDoiBatchId(book-meta/book-id), $noIdComment)[1]" />
		</doi_batch_id>
		<timestamp>
			<xsl:value-of select="$datetime"/>
		</timestamp>
		<depositor>
			<depositor_name>
				<xsl:sequence select="(//book-meta/publisher/publisher-name/string(), $noPublisherNameComment)[1]"/>
			</depositor_name>
			<email_address>
				<xsl:sequence select="($metafile/meta/email_address/string(), $noEmailAddressComment)[1]"/>
			</email_address>
		</depositor>
		<registrant>
			<xsl:sequence select="($metafile/meta/depositor/string(), //book-meta/publisher/publisher-name/string(), $noPublisherNameComment)[1]"/>
		</registrant>
	</xsl:template>

	<xsl:function name="jatsFn:findDoiBatchId" as="xs:string?">
		<xsl:param name="candidateIdElements" as="element()*"/>
		<xsl:variable name="candidateIds" select="($candidateIdElements[@pub-id-type='art-access-id']
												  ,$candidateIdElements[@pub-id-type='publisher-id']
												  ,$candidateIdElements[@book-id-type='doi']
												  ,$candidateIdElements[@pub-id-type='medline']
												  ,$candidateIdElements[@pub-id-type='pii']
												  ,$candidateIdElements[@pub-id-type='sici']
												  ,$candidateIdElements[@pub-id-type='pmid']
												  ,$candidateIdElements[@pub-id-type='other'])"/>
		<xsl:sequence select="$candidateIds[1]"/>
	</xsl:function>



<!-- ========================================================================== -->
<!-- BITS Book Metadata Element                                                   -->
<!-- ========================================================================== -->
	<xsl:template match="book-meta">
		<book_metadata language="en">
			<xsl:apply-templates select="contrib-group"/>
			<xsl:variable name="fullTitle" as="xs:string?" select="(book-title-group/book-title, book-title, book-id)[1]" />
			<xsl:if test="not($fullTitle)"><xsl:message terminate="yes">Book full title is not available in the Input file</xsl:message></xsl:if>
			<titles><title><xsl:value-of select="$fullTitle"/></title></titles>

			<xsl:apply-templates select="edition"/>


			<xsl:if test="../book-meta/book-id[@book-id-type='doi']">
				<doi_data>
					<doi>
						<xsl:value-of select="../book-meta/book-id[@book-id-type='doi']"/>
					</doi>
				</doi_data>
			</xsl:if>
			<xsl:apply-templates select="pub-date"/>
			
			<xsl:if test="not(isbn)"><xsl:message terminate="yes">Book ISBN is not available in the Input file</xsl:message></xsl:if>
				
			<xsl:apply-templates select="isbn"/>
			<xsl:apply-templates select="publisher"/>
		</book_metadata>
	</xsl:template>

	<xsl:template match="edition">
		<edition_number><xsl:value-of select="."/></edition_number>
	</xsl:template>

	<xsl:template match="isbn">
		<xsl:variable name="media_type" select="if (@content-type=('ebook','epub', 'epub-ppub')) then 'electronic' else 'print'"/>
		<isbn media_type="{$media_type}"><xsl:value-of select="."/></isbn>
	</xsl:template>

	<xsl:template match="publisher">
		<publisher>
			<xsl:apply-templates select="publisher-name"/>
			<xsl:apply-templates select="publisher-loc"/>
		</publisher>
	</xsl:template>

	<xsl:template match="publisher-name"><publisher_name><xsl:value-of select="."/></publisher_name></xsl:template>
	<xsl:template match="publisher-loc"><publisher_loc><xsl:value-of select="."/><xsl:apply-templates select="publisher-loc/uri/node()"/></publisher_loc></xsl:template>
	<xsl:template match="publisher-loc/uri"><uri><xsl:value-of select="."/></uri></xsl:template>

<!-- ========================================================================== -->
<!-- Publication Date                                                           -->
<!-- ========================================================================== -->

	<xsl:template match="pub-date">
		<xsl:variable name="mediaType" select="if (@pub-type=('epub', 'epub-ppub')) then 'online' else 'print'"/>
		<publication_date media_type="{ $mediaType }">
			<xsl:apply-templates select="month"/>
			<xsl:apply-templates select="day"/>
			<xsl:apply-templates select="year"/>
		</publication_date>
	</xsl:template>

	<xsl:template match="month"><month><xsl:value-of select="."/></month></xsl:template>
	<xsl:template match="day"><day><xsl:value-of select="."/></day></xsl:template>
	<xsl:template match="year"><year><xsl:value-of select="."/></year></xsl:template>




<!-- ========================================================================== -->
<!-- BITS Article Contributors                                                  -->
<!-- ========================================================================== -->
	<xsl:template match="//book-meta/contrib-group[contrib]">
		<contributors><xsl:apply-templates select="contrib"/></contributors>
	</xsl:template>

	<xsl:template match="contrib[name or name-alternatives or string-name]">
		<person_name sequence="{ if (position() eq 1) then 'first' else 'additional' }" contributor_role="author">
			<xsl:apply-templates select="(name, string-name, name-alternatives/name, name-alternatives/string-name)[1]"/>

			<xsl:if test="contrib-id[@contrib-id-type='orcid']">
				<ORCID>
					<xsl:apply-templates select="contrib-id"/>
				</ORCID>
			</xsl:if>
			
		</person_name>

		<xsl:if test="collab">
			<organization sequence="{ if (position() eq 1) then 'first' else 'additional' }" contributor_role="author">
				<xsl:apply-templates select="collab"/>
			</organization>
		</xsl:if>
	</xsl:template>

	<xsl:template match="contrib-group//name">
		<xsl:apply-templates select="given-names"/>
		<xsl:apply-templates select="surname"/>
		<xsl:apply-templates select="suffix"/>
	</xsl:template>

	<xsl:template match="contrib-group//given-names"><given_name><xsl:apply-templates/></given_name></xsl:template>
	<xsl:template match="contrib-group//surname"><surname><xsl:apply-templates/></surname></xsl:template>
	<xsl:template match="contrib-group//suffix"><suffix><xsl:apply-templates/></suffix></xsl:template>

	<xsl:template match="contrib-group/contrib/collab">
		<xsl:if test="collab">
			<organization>
				<xsl:apply-templates select="collab"/>
			</organization>
		</xsl:if>
	</xsl:template>





	<xsl:template match="aff"> </xsl:template>

	<xsl:template match="aff/label"> </xsl:template>
	
<!-- ========================================================================== -->
<!-- Citations                                                                  -->
<!-- ========================================================================== -->
<xsl:template match="ref-list">
	<citation_list>
		<xsl:apply-templates select="ref"/>
	</citation_list>
</xsl:template>

<xsl:template match="ref/citation-alternatives">
	<xsl:variable name="key" select="concat($datetime,'_',@id)"/>
	<citation>
		<xsl:attribute name="key">key<xsl:value-of select="$key"/></xsl:attribute>
		<xsl:apply-templates select="element-citation"/>
		<xsl:apply-templates select="citation"/>
		<xsl:apply-templates select="nlm-citation"/>
		<xsl:apply-templates select="mixed-citation"/>
	</citation>
</xsl:template>

<xsl:template match="element-citation | citation | nlm-citation | mixed-citation">
	<xsl:choose>
		<xsl:when test="@publication-type='journal' or @citation-type='journal'">
			<xsl:if test="issn">
				<issn>
					<xsl:value-of select="//element-citation/issn | //citation/issn | //nlm-citation/issn | //mixed-citation/issn"/>
				</issn>
			</xsl:if>
			<xsl:if test="source">
				<journal_title>
					<xsl:apply-templates select="source"/>
				</journal_title>
			</xsl:if>
                        <xsl:choose>
                            <xsl:when test="person-group">
				<xsl:apply-templates select="person-group/name|person-group/collab"/>
                            </xsl:when>
                            <xsl:when test="string-name">
				<xsl:apply-templates select="string-name"/>
                            </xsl:when>
                            <xsl:when test="collab">
				<xsl:apply-templates select="collab"/>
                            </xsl:when>
                        </xsl:choose>    
			<xsl:if test="volume">
				<volume>
					<xsl:apply-templates select="volume"/>
				</volume>
			</xsl:if>
			<xsl:if test="issue">
				<issue>
					<xsl:apply-templates select="issue"/>
				</issue>
			</xsl:if>
			<xsl:if test="fpage">
				<first_page>
					<xsl:apply-templates select="fpage"/>
				</first_page>
			</xsl:if>
			<xsl:if test="year">
				<cYear>
					<xsl:value-of select="replace(year, '[a-zA-Z]', '')" /> 
				</cYear>
			</xsl:if>
			<xsl:if test="article-title">
				<article_title>
					<xsl:apply-templates select="article-title"/>
				</article_title>
			</xsl:if>
		</xsl:when>
			<xsl:when test="@citation-type = 'book' or @citation-type = 'conf-proceedings' or @citation-type = 'confproc' or @citation-type = 'other' or @publication-type = 'book' or @publication-type = 'conf-proceedings' or @publication-type = 'confproc' or @publication-type = 'other'">
                        <xsl:choose>
                            <xsl:when test="person-group">
				<xsl:apply-templates select="person-group/name|person-group/collab"/>
                            </xsl:when>
                            <xsl:when test="string-name">
				<xsl:apply-templates select="string-name"/>
                            </xsl:when>
                            <xsl:when test="collab">
				<xsl:apply-templates select="collab"/>
                            </xsl:when>
                        </xsl:choose>    
			<xsl:if test="fpage">
				<first_page>
					<xsl:apply-templates select="fpage"/>
				</first_page>
			</xsl:if>
			<xsl:if test="year">
				<cYear>
					<xsl:value-of select="replace(year, '[a-zA-Z]', '')" /> 
				</cYear>
			</xsl:if>
			<xsl:if test="source">
				<volume_title>
					<xsl:apply-templates select="source"/>
				</volume_title>
			</xsl:if>
			<xsl:if test="edition">
				<edition_number>
					<xsl:apply-templates select="edition"/>
				</edition_number>
			</xsl:if>
			<xsl:if test="article-title">
				<article_title>
					<xsl:apply-templates select="article-title"/>
				</article_title>
			</xsl:if>
		</xsl:when>
			<xsl:otherwise>
			<unstructured_citation>
				<xsl:value-of select="."/>
			</unstructured_citation>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="back//name">
	<xsl:if test="position()=1">
		<author>
			<xsl:apply-templates select="surname"/>
		</author>
	</xsl:if>
</xsl:template>

<xsl:template match="back//string-name">
	<xsl:if test="position()=1">
		<author>
			<xsl:apply-templates select="surname"/>
		</author>
	</xsl:if>
</xsl:template>

<xsl:template match="back//collab">
	<xsl:if test="position()=1">
		<author>
			<xsl:apply-templates/>
		</author>
	</xsl:if>
</xsl:template>

	<!-- =================================================== -->

	<xsl:template match="element()" mode="abstract">
		<xsl:element name="jats:{local-name()}" namespace="http://www.ncbi.nlm.nih.gov/JATS1">
			<!--<xsl:copy-of select="namespace::*"/>-->
			<xsl:apply-templates select="node() | @*" mode="abstract"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()" mode="abstract">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@*" mode="abstract">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="xref" mode="abstract">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<!-- license URL -->
	<xsl:function name="jatsFn:accessIndicator" as="element(ai:program)?">
		<xsl:param name="permissions" as="element()?"/>

		<xsl:variable name="indicators" as="element()*">
			<xsl:if test="$permissions/license[@license-type=('open-access', 'free')]"><free_to_read/></xsl:if>
			<xsl:apply-templates select="$permissions/license" mode="access-indicators"/>
			<xsl:apply-templates select="$metafile/meta/license" mode="fromMeta"/>
		</xsl:variable>

		<xsl:if test="not(empty($indicators))">
			<ai:program name="AccessIndicators"><xsl:sequence select="$indicators"/></ai:program>
		</xsl:if>
	</xsl:function>

	<xsl:template match="license" mode="fromMeta">
		<ai:license_ref>
			<xsl:if test="@applies_to"><xsl:attribute name="applies_to" select="@applies_to"/></xsl:if>
			<xsl:value-of select="."/>
		</ai:license_ref>
	</xsl:template>

	<!-- http://tdmsupport.crossref.org/license-uris-technical-details/ -->
	<xsl:template match="license[@xlink:href]" mode="access-indicators">
		<ai:license_ref><xsl:value-of select="@xlink:href"/></ai:license_ref>
	</xsl:template>
	<xsl:template match="*" mode="access-indicators" priority="-1"/>

	<!-- fundref -->
	
	<xsl:template match="funding-group" mode="fundref">
		<fr:program>
			<xsl:apply-templates select="award-group/funding-source" mode="fundref"/>
		</fr:program>
	</xsl:template>

	<xsl:template match="funding-group/award-group/funding-source" mode="fundref">
		<xsl:if test="normalize-space(string(.)) != ''">
			<fr:assertion name="fundgroup">
			<!-- TODO: in JATS 1.1d1 the name and ID/DOI may be in a wrapper -->
			
		    <xsl:choose>
			    <xsl:when test="institution-wrap">
			    	 
			    	<xsl:variable name="institution-id" select="institution-wrap/institution-id"/>
			    	 
			    	<xsl:choose> 
					    <xsl:when test="institution-wrap/institution != ''">
						    <fr:assertion name="funder_name">
							    <xsl:value-of select="institution-wrap/institution"/>
								<xsl:if test="$institution-id != ''">
									<fr:assertion name="funder_identifier">
										<xsl:value-of select="$institution-id"/>
									</fr:assertion>
								</xsl:if>
						    </fr:assertion>
						</xsl:when>
						<xsl:otherwise>
						    <xsl:if test="$institution-id != ''">
							    <fr:assertion name="funder_identifier">
								    <xsl:value-of select="$institution-id"/>
							    </fr:assertion>
						    </xsl:if>
						</xsl:otherwise>
					</xsl:choose>
			    </xsl:when>
			    <xsl:when test="institution != ''">
				    <fr:assertion name="funder_name">
					    <xsl:value-of select="institution"/>
				    </fr:assertion>
			    </xsl:when>
			    <xsl:otherwise>
			    	<xsl:if test="normalize-space(string(.)) != ''">
					    <fr:assertion name="funder_name">
						    <xsl:value-of select="normalize-space(string(.))"/>
					    </fr:assertion>
					</xsl:if>
			    </xsl:otherwise>
		    </xsl:choose>
		    
			 
			<xsl:apply-templates select="../award-id" mode="fundref"/>
			</fr:assertion>
		</xsl:if>
	</xsl:template>

	<xsl:template match="award-id" mode="fundref">
		<xsl:if test=". != ''">
			<fr:assertion name="award_number">
				<xsl:value-of select="."/>
			</fr:assertion>
		</xsl:if>
	</xsl:template>

	<!-- full-text URLs -->
	
	<xsl:function name="jatsFn:tdm">
		<xsl:param name="resource"/>
		<xsl:variable name="base" as="xs:string"
					  select="if (ends-with($resource,'/')) then substring($resource,1,string-length($resource)-1) else $resource"/>
		<xsl:variable name="defaultFormats">pdf,xml,html</xsl:variable>
		<xsl:variable name="formatsFromMeta" select="$metafile/meta/tdmFormats" as="xs:string?"/>
		<xsl:variable name="formats" select="tokenize(($formatsFromMeta,$defaultFormats)[1],',')"/>

		<xsl:if test="not(empty($formats))">
			<collection property="text-mining">
				<xsl:for-each select="$formats">
					<item>
						<resource content_version="vor" mime_type="application/{ . }">
							<xsl:value-of select="concat($base, '.', . )"/>
						</resource>
					</item>
				</xsl:for-each>
			</collection>
		</xsl:if>
	</xsl:function>

	<!-- crawler full-text URLs for Similarity Check -->
	<!-- https://support.crossref.org/hc/en-us/articles/215774943-Depositing-as-crawled-URLs-for-Similarity-Check -->
	<xsl:function name="jatsFn:crawler">
		<xsl:param name="resource"/>
		<xsl:variable name="base" as="xs:string"
					  select="if (ends-with($resource,'/')) then substring($resource,1,string-length($resource)-1) else $resource"/>

		<collection property="crawler-based">
			<item crawler="iParadigms">
				<resource>
					<xsl:value-of select="concat($base, '.html' )"/>
				</resource>
			</item>
		</collection>
	</xsl:function>

	<!-- archive locations -->
<!--	<xsl:template name="archive-locations">
		<xsl:if test="$archiveLocations">
			<archive_locations>
				<xsl:for-each select="str:tokenize($archiveLocations, ',')">
					<archive name="{.}"/>
				</xsl:for-each>
			</archive_locations>
		</xsl:if>
</xsl:template> -->

</xsl:stylesheet>
