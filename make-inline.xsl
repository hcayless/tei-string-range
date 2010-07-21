<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t" version="2.0">
  
  <xsl:include href="string-range.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="node()|@*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*|@*|comment()|processing-instruction()" mode="strip-text">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|comment()|processing-instruction()" mode="strip-text"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="strip-text"/>
  
  <xsl:template match="t:div[@type='edition' and @subtype='markup']">
    <div>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:attribute name="type">edition</xsl:attribute>
      <xsl:attribute name="xml:space">preserve</xsl:attribute>
      <xsl:apply-templates mode="strip-text"/>
    </div>
  </xsl:template>
  
  <xsl:template match="t:div[@type='edition' and @subtype='text']"/>
  
  <xsl:template match="t:ptr[contains(@target, '#string-range')]" mode="strip-text">
    <xsl:value-of select="t:eval-string-range(@target, /)"/>
  </xsl:template>
 
</xsl:stylesheet>
