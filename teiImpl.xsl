<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teiImpl="http://teiImpl" version="2.0">

    <xsl:output indent="yes"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b>
                <xs:date>Jun 11, 2010</xs:date>
            </xd:p>
            <xd:p><xd:b>Author:</xd:b> ajs6f</xd:p>
            <xd:p>First draft of TEI string-range impl</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:function name="teiImpl:ptr-from-pi" as="element(tei:ptr)">
        <xsl:param name="pi" as="processing-instruction('string-range-begin')"/>
        <!-- capture the id of this range -->
        <xsl:variable name="range" as="xs:string"
            select="translate(substring-after($pi,'='),'&quot;','')"/>
        <xsl:message select="concat('Range number: ',$range)"/>
        <!-- capture the start element -->
        <xsl:variable name="start-element" as="node()">
            <xsl:sequence
                select="$pi/(ancestor::node()[@xml:id]|preceding::node()[@xml:id])[last()]"/>
        </xsl:variable>
        <xsl:message select="concat('Start element: ', $start-element)"/>

        <!-- capture the offset -->
        <xsl:variable name="offset">
            <xsl:variable name="after-start-element"
                select="$start-element//following::text()|$start-element//text()"/>
            <xsl:message
                select="concat('Elements in $after-start-element:', count($after-start-element))"/>

            <xsl:variable name="before-string-range-begin"
                select="$pi/preceding::text()"/>
            <xsl:message
                select="concat('Elements in $before-string-range-begin:', count($before-string-range-begin))"/>

            <xsl:variable name="in-between"
                select="$after-start-element intersect $before-string-range-begin"/>
            <xsl:message select="concat('Elements in $in-between:', count($in-between))"/>

            <xsl:sequence select="string-length(string-join($in-between,''))"/>
        </xsl:variable>
        <!-- capture the length -->
        <xsl:variable name="length">
            <!-- find the end marker -->
            <xsl:variable name="end-pi"
                select="$pi/following::processing-instruction('string-range-end')[matches(translate(substring-after(.,'='),'&quot;',''),$range)]"/>
            
            <xsl:variable name="before-string-range-begin"
                select="$pi//following::text()"/>
            <xsl:message
                select="concat('Elements in $before-string-range-begin:', count($before-string-range-begin))"/>
            
            <xsl:variable name="before-string-range-end"
                select="$end-pi/preceding::text()"/>
            <xsl:message
                select="concat('Elements in $before-string-range-end:', count($before-string-range-end))"/>
            
            <xsl:variable name="in-between"
                select="$before-string-range-begin intersect $before-string-range-end"/>
            <xsl:message select="concat('Elements in $in-between:', count($in-between))"/>
            
            <xsl:sequence select="string-length(string-join($in-between,''))"/>
            
        </xsl:variable>
        <tei:ptr target="#string-range({$start-element/@xml:id}, {$offset}, {$length})"/>
    </xsl:function>

    <xsl:template match="/tei:TEI">
        <xsl:copy>
            <xsl:apply-templates/>
            <linkGrp>
                <xsl:for-each select="//processing-instruction(string-range-begin)">
                    <xsl:copy-of select="teiImpl:ptr-from-pi(.)"/>
                </xsl:for-each>
            </linkGrp>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:if test="not(processing-instruction(string-range-begin))">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
