<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lectureMD.xsl
    Created on : 1 novembre 2010, 22:32
    Author     : jldeleage
    Description:
        Lit un document MagicDraw (ou plus généralement UML 2.x / XMI 2.y)
        et produit un modèle "ete".
        Les espaces de noms traités par cette feuille sont :
        UML : http://www.omg.org/spec/UML/20131001
        XMI : http://www.omg.org/spec/XMI/20131001
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:uml-2-3='http://www.omg.org/spec/UML/20131001'
  xmlns:uml='http://www.omg.org/spec/UML/20131001'
  xmlns:xmi='http://www.omg.org/spec/XMI/20131001'
  xmlns:xmi-gen="http://www.omg.org/XMI"
  xmlns:xmi-2-2='http://www.omg.org/spec/XMI/20131001'
>

<!--<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
 xmlns:uml_2_2='http://schema.omg.org/spec/UML/2.2'
 xmlns:xmi='http://schema.omg.org/spec/XMI/2.1'
 xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
 xmlns:MagicDraw_Profile='http://www.magicdraw.com/schemas/MagicDraw_Profile.xmi'
 xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
 xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
 xmlns:UML_Standard_Profile='http://www.magicdraw.com/schemas/UML_Standard_Profile.xmi'
 xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>-->

    <xsl:output method="xml" indent="yes"/>


    <xsl:key name="id-xmi" match="*" use="@xmi:id"  />


        <!-- Normalement, cette feuille est importée ou incluse
         Cependant, la règle "match /" est fournie pour permettre une
         utilisation autonome.
         Elle a une priorité faible au cas où la feuille serait incluse.
     -->
    <xsl:template match="/" priority="-10">
        <xsl:message>
            <xsl:text>TODO : écrire la règle principale de la feuille
                lecture_20131001.xsl</xsl:text>
        </xsl:message>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="xmi-2-2:XMI" mode="info">
        <xsl:message>Document UML-2.3 et XMI-2.2. Versions du 01/10/2013</xsl:message>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- F I L T R A G E   des classes, attributs, opérations                -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:template match="uml-2-3:Model[@*='uml:Model']"
                  mode="select-ete-model">
        <xsl:message>Modele été : </xsl:message>
        <xsl:apply-templates select="." mode="ete-model"/>
    </xsl:template>


    <xsl:template match="packagedElement[@*='uml:Class']" mode="select-classes">
        <xsl:apply-templates select="." mode="selected-class"/>
    </xsl:template>

    <xsl:template match="ownedAttribute" mode="select-attributes">
        <xsl:if test="not(@association)">
            <xsl:apply-templates select="." mode="selected-attribute"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ownedOperation" mode="select-operations">
        <xsl:apply-templates select="." mode="selected-operation"/>
    </xsl:template>

    <xsl:template match="ownedAttribute" mode="select-associations">
        <xsl:if test="@association">
            <xsl:apply-templates select="." mode="selected-association"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="packagedElement" mode="does-it-have-subclasses">
        <xsl:if test="@name='Operation'">
            <xsl:message>
                <xsl:text>Recherche des sous-classes de "Operation"</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:if test="//generalization/@general=current()/@id">
            <xsl:message>Sous-classes trouvees</xsl:message>
            <xsl:apply-templates select="." mode="selected-class"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="select-superclasses">
        <xsl:if test="generalization/@general">
            <xsl:apply-templates select="//*[@id=current()/generalization/@general]"
                    mode="selected-superclass"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="postcondition" mode="select-postconditions">
        <xsl:apply-templates select="../ownedRule[@id=current()/@idref]"
                    mode="select-postconditions"/>
    </xsl:template>


    <xsl:template match="ownedRule[specification/language='OCL2.0']" mode="select-postconditions">
        <xsl:variable name="body" select="normalize-space(specification/body)"/>
        <xsl:variable name="apres-result" select="normalize-space(substring-after($body, 'result'))"/>
        <xsl:choose>
            <xsl:when test="not(starts-with($body, 'result'))">
                <xsl:apply-templates select="." mode="selected-postcondition"/>
            </xsl:when>
            <xsl:when test="not(starts-with($apres-result, '='))">
                <xsl:apply-templates select="." mode="selected-postcondition"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="ownedRule" mode="get-expression-of-condition">
        <xsl:apply-templates select="specification" mode="get-expression-of-condition">
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="specification[language='OCL2.0']" mode="get-expression-of-condition">
        <xsl:value-of select="body"/>
    </xsl:template>


    <xsl:template match="specification[language='OCL2.0']" mode="select-result-specification">
        <xsl:if test="starts-with(normalize-space(body), 'result')">
            <xsl:variable name="sans-result" select="substring-after(body, 'result')"/>
            <xsl:if test="starts-with(normalize-space($sans-result),'=')">
                <xsl:apply-templates select="body" mode="selected-result-specification"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*" mode="get-result-specification">
        <xsl:value-of select="normalize-space(substring-after(., '='))"/>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- A C C E S S E U R S                                                 -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="*" mode="get-type">
        <xsl:variable name="intermediaire">
        <xsl:call-template
            name="extrais-type">
            <xsl:with-param name="chaine"
                select="type/xmi:Extension/referenceExtension/@referentPath"
            />
        </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$intermediaire = 'date'">
                <xsl:text>Date</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$intermediaire"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="extrais-type">
        <xsl:param name="chaine"/>
        <xsl:choose>
            <xsl:when test="contains($chaine, '::')">
                <xsl:call-template name="extrais-type">
                    <xsl:with-param name="chaine"
                        select="substring-after($chaine, '::')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$chaine"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
