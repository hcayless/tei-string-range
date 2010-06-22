<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xmlns:t="http://www.tei-c.org/ns/1.0" version="2.0">
  
  <!--
  <xsl:template match="/">
    <tests>
      <test n="1">
        <xsl:copy-of select="t:get-string-range(//t:div[@type='edition'], 18, 30)"/>
      </test>
      <test n="2">
        <xsl:copy-of select="t:get-milestone-range(//t:div[@type='edition'], 18, 30)"/>
      </test>
      <test n="3">
        <xsl:copy-of select="t:get-fragment-range(//t:div[@type='edition'], 18, 30)"/>
      </test>
    </tests>
    
    
  </xsl:template>
  -->
  
  <xsl:function name="t:get-string-range">
    <xsl:param name="elt"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <xsl:sequence select="substring(string($elt), $start, $end - $start)"/>
  </xsl:function>
  
  <xsl:function name="t:get-milestone-range">
    <xsl:param name="elt"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <!-- Get a flattened copy of the fragment $elt -->
    <xsl:variable name="flat-elt"><xsl:call-template name="flatten"><xsl:with-param name="elt" select="$elt"/></xsl:call-template></xsl:variable>
    <!-- Find the starting text() node -->
    <xsl:variable name="start-node" select="$flat-elt//text()[string-length(string-join(preceding-sibling::text(), '')) &lt; $start and (string-length(string-join(preceding-sibling::text(), '')) + string-length(.)) &gt;= $start]"/>
    <!-- Find the ending text() node -->
    <xsl:variable name="end-node" select="$flat-elt//text()[string-length(string-join(preceding-sibling::text(), '')) &lt; $end and (string-length(string-join(preceding-sibling::text(), '')) + string-length(.)) &gt;= $end]"/>
    <!-- Find the location within the starting text() node where the range begins -->
    <xsl:variable name="s" select="$start - string-length(string-join($start-node/preceding-sibling::text(), ''))"/>
    <!-- Find the location within the ending text() node where the range ends -->
    <xsl:variable name="e" select="$end - string-length(string-join($end-node/preceding-sibling::text(), ''))"/>
    <xsl:choose>
      <!-- Account for the case where start and end text node are the same -->
      <xsl:when test="$start-node = $end-node">
        <xsl:sequence select="substring($start-node, $s, $e - $s)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="substring($start-node, $s)"/>
        <xsl:for-each select="$flat-elt//node()[preceding-sibling::node() = $start-node and following-sibling::node() = $end-node]"><xsl:copy-of select="."/></xsl:for-each>
        <xsl:copy-of select="substring($end-node, 1, $e)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="t:get-fragment-range">
    <xsl:param name="elt"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <!-- Find the starting text() node -->
    <xsl:variable name="start-node" select="$elt//text()[string-length(string-join(preceding::text()[ancestor::* = $elt], '')) &lt; $start and (string-length(string-join(preceding::text()[ancestor::* = $elt], '')) + string-length(.)) &gt;= $start]"/>
    <!-- Find the ending text() node -->
    <xsl:variable name="end-node" select="$elt//text()[string-length(string-join(preceding::text()[ancestor::* = $elt], '')) &lt; $end and (string-length(string-join(preceding::text()[ancestor::* = $elt], '')) + string-length(.)) &gt;= $end]"/>
    <xsl:variable name="fragment">
      <xsl:apply-templates select="$elt" mode="fragment">
        <xsl:with-param name="start-node" select="$start-node"/>
        <xsl:with-param name="end-node" select="$end-node"/>
        <xsl:with-param name="start" select="$start - string-length(string-join($start-node/preceding::text()[ancestor::* = $elt], ''))"/>
        <xsl:with-param name="end" select="$end - string-length(string-join($end-node/preceding::text()[ancestor::* = $elt], ''))"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:copy-of select="$fragment"/>
  </xsl:function>
  
  <xsl:function name="t:normalize-text">
    <xsl:param name="text"/>
    <xsl:for-each select="$text">
      <xsl:sequence select="replace(replace(., '\n', ''), '\s+', ' ')"/>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:template name="flatten">
    <xsl:param name="elt"/>
    <xsl:apply-templates select="$elt" mode="flatten"/>
  </xsl:template>
  
  <xsl:template match="*" mode="flatten">
    <xsl:choose>
      <xsl:when test=".//node()">
        <xsl:element name="{local-name(.)}-start"><xsl:namespace name="t" select="'http://www.tei-c.org/ns/1.0'"/><xsl:copy-of select="@*"/></xsl:element><xsl:apply-templates mode="flatten"/><xsl:element name="{local-name(.)}-end"/>
      </xsl:when>
      <xsl:otherwise><xsl:copy-of select="."></xsl:copy-of></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="fragment">
    <xsl:param name="start-node"/>
    <xsl:param name="end-node"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <xsl:choose>
      <xsl:when test="descendant::text()[. is $start-node]">
        <xsl:copy copy-namespaces="yes">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="fragment">
            <xsl:with-param name="start-node" select="$start-node"/>
            <xsl:with-param name="end-node" select="$end-node"/>
            <xsl:with-param name="start" select="$start"/>
            <xsl:with-param name="end" select="$end"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="descendant::text()[. is $end-node]">
        <xsl:copy copy-namespaces="yes">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="fragment">
            <xsl:with-param name="start-node" select="$start-node"/>
            <xsl:with-param name="end-node" select="$end-node"/>
            <xsl:with-param name="start" select="$start"/>
            <xsl:with-param name="end" select="$end"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="preceding::text()[. is $start-node] and following::text()[. is $end-node]">
        <xsl:copy copy-namespaces="yes">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="fragment">
            <xsl:with-param name="start-node" select="$start-node"/>
            <xsl:with-param name="end-node" select="$end-node"/>
            <xsl:with-param name="start" select="$start"/>
            <xsl:with-param name="end" select="$end"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()" mode="fragment">
    <xsl:param name="start-node"/>
    <xsl:param name="end-node"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <xsl:choose>
      <xsl:when test=". is $start-node"><xsl:value-of select="substring($start-node, $start)"/></xsl:when>
      <xsl:when test=". is $end-node"><xsl:value-of select="substring($end-node, 1, $end)"/></xsl:when>
      <xsl:when test="preceding::text()[. is $end-node]"/>
      <xsl:when test="following::text()[. is $start-node]"/>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
</xsl:stylesheet>
