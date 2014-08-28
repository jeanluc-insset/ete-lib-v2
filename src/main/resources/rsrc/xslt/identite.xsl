<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : identite.xsl
    Created on : 3 octobre 2010, 18:59
    Author     : jldeleage
    Description:
        Copie le document tel quel (à un message près que l'on peut ajouter
        grâce au paramètre "message")
        Utilisé par le "dump" pour fournir une trace au fur et à mesure
        des transformations.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="message" select="''"/>

    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="/">
        <xsl:comment>
            <xsl:value-of select="$message"/>
        </xsl:comment>
        <xsl:copy-of select="*"/>
    </xsl:template>

</xsl:stylesheet>
