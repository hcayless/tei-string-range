<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:include href="string-range.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="node()|@*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:div[@type='edition']">
    <div type="edition" subtype="text" xml:space="preserve" xml:lang="grc" xml:id="{generate-id(.)}"><ab><xsl:value-of select="t:get-string-range(., 0, string-length())"/></ab></div>
    <xsl:call-template name="standoff"/>
  </xsl:template>
  
  <xsl:template match="*|@*|comment()|processing-instruction()" mode="standoff">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*|comment()|processing-instruction()" mode="standoff"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="standoff">
    <xsl:variable name="start" select="string-length(string-join(preceding::text()[ancestor::t:div[@type='edition']], ''))"/>
    <ptr>
      <xsl:attribute name="target">#string-range('<xsl:value-of select="generate-id(//t:div[@type='edition'])"/>', <xsl:value-of select="$start"/>, <xsl:value-of select="string-length(.)"/>)</xsl:attribute>
    </ptr>
  </xsl:template>
    
  <xsl:template name="standoff">
    <div type="edition" subtype="markup" xml:lang="grc">
      <xsl:apply-templates mode="standoff"/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>
