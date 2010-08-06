<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xmlns:t="http://www.tei-c.org/ns/1.0" version="2.0">
  
  <xsl:function name="t:get-string-range">
    <xsl:param name="elt"/>
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <xsl:sequence select="substring(string($elt), $start, $end - $start + 1)"/>
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
    <xsl:variable name="preceding-text" select="count($elt/preceding::text())"/>
    <xsl:variable name="start-index">
      <xsl:call-template name="get-text-index">
        <xsl:with-param name="index">1</xsl:with-param>
        <xsl:with-param name="position" select="$start"/>
        <xsl:with-param name="sequence" select="$elt//text()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="end-index">
      <xsl:call-template name="get-text-index">
        <xsl:with-param name="index">1</xsl:with-param>
        <xsl:with-param name="position" select="$end"/>
        <xsl:with-param name="sequence" select="$elt//text()"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Find the starting text() node -->
    <xsl:variable name="start-node" select="$elt//text()[count(preceding::text()) - $preceding-text = $start-index - 1]"/>
    <!-- Find the ending text() node -->
    <xsl:variable name="end-node" select="$elt//text()[count(preceding::text()) - $preceding-text = $end-index - 1]"/>
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
  
  <xsl:template name="get-text-index">
    <xsl:param name="index"/>
    <xsl:param name="position"/>
    <xsl:param name="sequence"/>
    <xsl:variable name="start-index" select="string-length(string-join(subsequence($sequence, 1, $index - 1), ''))"/>
    <xsl:variable name="end-index" select="string-length(string-join(subsequence($sequence, 1, $index - 1), ''))  + string-length($sequence[number($index)])"/>
    <xsl:choose>
      <xsl:when test="$start-index &lt;= $position and $end-index &gt;= $position"><xsl:value-of select="number($index)"/></xsl:when>
      <xsl:otherwise>
        <xsl:if test="number($index) &lt; count($sequence)">
          <xsl:call-template name="get-text-index">
            <xsl:with-param name="index" select="$index + 1"/>
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="sequence" select="$sequence"/>
          </xsl:call-template>
        </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="t:normalize-text">
    <xsl:param name="text"/>
    <xsl:for-each select="$text">
      <xsl:sequence select="replace(replace(., '\n', ''), '\s+', ' ')"/>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="t:eval-string-range">
    <xsl:param name="url"/>
    <xsl:param name="root"/>
    <xsl:variable name="range" select="t:parse-string-range($url)"/> 
    <xsl:variable name="doc">
      <xsl:choose>
        <xsl:when test="starts-with($url, '#')"><xsl:copy-of select="$root"/></xsl:when>
        <xsl:otherwise><xsl:copy-of select="doc(substring-before($url, '#'))"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="t:get-string-range($doc//*[@xml:id = $range[1]], $range[2] + 1, $range[2] + $range[3] + 1)"/>
  </xsl:function>
  
  <xsl:function name="t:parse-string-range">
    <xsl:param name="pointer"/>
    <xsl:variable name="apos">[']</xsl:variable>
    <xsl:for-each select="tokenize(replace(substring-before(substring-after($pointer, '#string-range('), ')'), $apos, ''), ',\s*')">
      <xsl:value-of select="."/>
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
