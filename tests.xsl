<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t"
  version="2.0">
  <xsl:import href="string-range.xsl"/>
  <xsl:output indent="yes"/>
    <xsl:template match="/">
    <tests>
    <test n="1">
    <xsl:copy-of select="t:get-string-range(//t:div[@type='edition'], 476, 497)"/>
    </test>
    <test n="2">
      <xsl:copy-of select="t:get-milestone-range(//t:div[@type='edition'], 476, 497)"/>
    </test>
    <test n="3">
      <xsl:copy-of select="t:get-fragment-range(//t:div[@type='edition'], 476, 497)"/>
    </test>
    </tests>
    
    </xsl:template>

</xsl:stylesheet>
