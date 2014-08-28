<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lectureMD.xsl
    Created on : 1 novembre 2010, 22:32
    Author     : jldeleage
    Description:
        Lit un document MagicDraw (ou plus généralement UML 2.2 / XMI 2.1)
        et produit un modèle "ete".
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
 xmlns:uml='http://www.omg.org/spec/UML/20110701'
 xmlns:uml-2-2='http://www.omg.org/spec/UML/20110701'
 xmlns:xmi-2-1='http://www.omg.org/spec/XMI/20110701'
 xmlns:MagicDraw_Profile='http://www.omg.org/spec/UML/20110701/MagicDrawProfile'
 xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
 xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
 xmlns:UML_Standard_Profile='http://www.omg.org/spec/UML/20110701/StandardProfileL2'
 xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>




<!--<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
 xmlns:uml_2_2='http://schema.omg.org/spec/UML/2.2'
 xmlns:xmi_2_1='http://schema.omg.org/spec/XMI/2.1'
 xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
 xmlns:MagicDraw_Profile='http://www.magicdraw.com/schemas/MagicDraw_Profile.xmi'
 xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
 xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
 xmlns:UML_Standard_Profile='http://www.magicdraw.com/schemas/UML_Standard_Profile.xmi'
 xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>-->

    <xsl:output method="xml" indent="yes"/>



    <!-- Normalement, cette feuille est importée
         Cependant, la règle "match /" est fourni pour permettre une
         utilisation autonome.
         Elle a une priorité faible au cas où la feuille serait incluse.
     -->
    <xsl:template match="/" priority="-10">
        <xsl:message>
            <xsl:text>TODO : écrire la règle principale de la feuille lecture_20110701.xsl</xsl:text>
        </xsl:message>
    </xsl:template>

    <xsl:template match="xmi-2-1:XMI" mode="info">
        <xsl:message>Document UML-2.2 et XMI-2.1</xsl:message>
    </xsl:template>



    <xsl:template match="uml-2-2:Model[xmi-2-1:type='uml:Model']" mode="select-modele-ete">
        <xsl:message>Modele été : </xsl:message>
        <xsl:apply-templates select="." mode="modele-ete"/>
    </xsl:template>

    <xsl:template match="uml-2-2:PackagedElement[xmi-2-1:type='uml:Class']" mode="select-classe">
        <xsl:apply-templates select="." mode="hello"/>
    </xsl:template>


</xsl:stylesheet>
