<?xml version="1.0" encoding="UTF-8"?>


<!--
    Document   : identite.xsl
    Created on : 3 octobre 2010, 18:59
    Author     : jldeleage
    Description:
        "Super-classe" des feuilles de lecture des différentes versions
        de XMI/UML.
        Contient des règles par défaut et des règles utilitaires
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
                xmlns:xmi='http://www.omg.org/spec/XMI/20110701'
                xmlns:fete="http://www.insset.u-picardie.fr/jeanluc/ete.html"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <!-- 0 : tout
         1 : tout sauf finest
         2 : finer et au-dessus
         3 : fine et au-dessus
         4 : info
         5 : warning
         6 : severe
      -->
    <xsl:param name="niveau-log" select="5"/>
    

    <xsl:template match="*" mode="select-ete-model" priority="-20">
        <xsl:if test="2 &gt;= $niveau-log">
            <xsl:message>
                <xsl:text>Ceci n'est pas un modele ete : </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> : </xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="@name"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                        G E N E R A L I T E S                        -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- La feuille principale invoque cette règle pour avoir produire un
         log indiquant les informations spécifiques à la version traitée
      -->
    <xsl:template match="*" mode="info">
        <xsl:message>Pas de version spécifique de XMI</xsl:message>
    </xsl:template>

    <!--
          Le document traité est dans l'espace de noms
          Il faut que l'élément d'extension XMI soit dans le même espace de
          noms.
          La feuille principale demande donc le nom de l'élément à créer,
          ou plutôt son espace de noms.
      -->
    <xsl:template match="*" mode="create-extension-element">
        <xmi:Extension extender="ete">
            <xsl:apply-templates select="." mode="callback-extension-element"/>
        </xmi:Extension>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--             T R A I T E M E N T S   P A R   D E F A U T             -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- La feuille principale demande à la feuille spécifique de retrouver
         les classes, les acteurs, etc.
         Chacune de ces règles doit être redéfinie dans les feuilles
         spécifiques et contenir uniquement l'invocation de la règle
         process-xxx correspondante sur les éléments ad-hoc.
         Exemple :
         <xsl:template match="packagedElement[@xmi:type='uml:Class']
                        mode="select-classes">
             <xsl:apply-templates select="." mode="selected-class"/>
         </xsl:template>
         Les méthodes ne sont placées ici qu'à titre d'information, elles
         sont d'ailleurs mises en commentaire, car la règle suivante par
         défaut intercepte toutes les invocations non traitées en ne faisant
         rien.
      -->
<!--    <xsl:template match="*" mode="select-classes" priority="-10"/>
    <xsl:template match="*" mode="select-actors" priority="-10"/>
    <xsl:template match="*" mode="select-scenarios" priority="-10"/>
    <xsl:template match="*" mode="select-attributes" priority="-10"/>
    <xsl:template match="*" mode="select-superclasses" priority="-10"/>
    <xsl:template match="*" mode="select-interfaces" priority="-10"/>-->
 
    <xsl:template match="*" mode="#all" priority="-1000">
        <!-- Ne rien faire -->
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                            C L A S S E S                            -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- Cette méthode sert d'aiguillage pour les méthodes définies dans
         les sous-classes.
         Cela permet d'effectuer des traitements différents sur une même
         sélection sans que la feuille appelée ait à gérer les différences :
         elle se contente de filtrer les éléments et d'invoquer une règle
         sur chaque élément filtré.
         Si le mode de la règle n'est pas traité explicitement, la
         règle d'aiguillage ci-dessous invoque la règle définie par le
         pramètre tunnel "action".
         Donc si on appelle deux fois la même règle de sélection en passant
         des valeurs différentes au paramètre "action", on obtient la même
         sélection mais on applique des règles différentes.
         Par exemple pour faire un traitement x sur les classes, la feuille
         principale écrit :
         <xsl:apply-templates select=".//*" mode="select-classes">
            <xsl:with-param name="action" select="'x'"/>
         </xsl:apply-templates>
      -->
    <xsl:template match="*" mode="selected-class" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>
        <xsl:choose>
            <xsl:when test="$action='process-class'">
                <xsl:apply-templates select="." mode="process-class"/>
            </xsl:when>
            <xsl:when test="$action='has-subclasses'">
                <xsl:message>Aiguillage vers has-subclasses</xsl:message>
                <xsl:apply-templates select="." mode="has-subclasses"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    
    <xsl:template match="* | @*" mode="selected-superclass" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>
        <xsl:choose>
            <xsl:when test="$action='process-superclass'">
                <xsl:apply-templates select="." mode="process-superclass"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

  
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- A T T R I B U T S                                                   -->
    <!-- ( P R O P R I E T E S   E T   A S S O C I A T I O N S )             -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <xsl:template match="* | @*" mode="selected-attribute" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>

        <xsl:choose>
            <xsl:when test="$action='process-attribute'">
                <xsl:apply-templates select="." mode="process-attribute"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- Renvoie "property" ou "association" -->
    <xsl:template match="*" mode="get-nature-of-attribute">
        <xsl:choose>
            <xsl:when test="@association">
                <xsl:text>association</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>property</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Renvoie la cardinalité. La méthode par défaut renvoie 1
         Redéfinir dans les feuilles spécifiques.
         TODO : essayer de fournir une méthode par défaut plus précise.
      -->
    <xsl:template match="* | @*" mode="get-cardinality">
        <xsl:text>1</xsl:text>
    </xsl:template>


    <xsl:template match="*" mode="get-type">
        <xsl:call-template
            name="extrais-type">
            <xsl:with-param name="chaine"
                select="type/xmi:Extension/referenceExtension/@referentPath"
            />
        </xsl:call-template>
    </xsl:template>


    <!-- Méthode "privée". Ne devrait pas être invoquée directement par une
         autre feuille.
      -->
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


    <xsl:template match="* | @*" mode="selected-association" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>

        <xsl:choose>
            <xsl:when test="$action='process-association'">
                <xsl:apply-templates select="." mode="process-association"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>




    <xsl:template match="* | @*" mode="selected-reverse-cardinality" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>
        <xsl:choose>
            <xsl:when test="$action='process-reverse-cardinality'">
                <xsl:apply-templates select="." mode="process-reverse-cardinality"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>





    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- O P E R A T I O N S                                                 -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="* | @*" mode="selected-operation" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>

        <xsl:choose>
            <xsl:when test="$action='process-operation'">
                <xsl:apply-templates select="." mode="process-operation"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*" mode="selected-result-specification" priority="-200">
        <xsl:apply-templates select="." mode="process-result-specification"/>
    </xsl:template>


    <xsl:template match="*" mode="selected-param" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>
        <xsl:choose>
            <xsl:when test="$action='process-param'">
                <xsl:apply-templates select="." mode="process-param"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="* | @*" mode="selected-precondition" priority="-200">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>

        <xsl:choose>
            <xsl:when test="$action='process-precondition'">
                <xsl:apply-templates select="." mode="process-precondition"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="* | @*" mode="selected-postcondition">
        <xsl:param name="action" tunnel="yes" select="'no-action'"/>

        <xsl:choose>
            <xsl:when test="$action='process-postcondition'">
                <xsl:apply-templates select="." mode="process-postcondition"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="* | @*" mode="get-name-of-condition">
        <xsl:text>ConditionAnonyme</xsl:text>
    </xsl:template>

    <xsl:template match="* | @*" mode="get-expression-of-condition"/>


    <xsl:template match="*" mode="get-name">
        <xsl:value-of select="@name"/>
    </xsl:template>


    <xsl:template match="ownedOperation" mode="get-type-of-operation">
        <xsl:choose>
            <xsl:when test="ownedParameter[@direction='return']">
                <xsl:apply-templates select="ownedParameter[@direction='return']" mode="get-type"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>void</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ownedParameter" mode="select-params">
        <xsl:message>
            <xsl:text>Evaluation du paramètre </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:message>
        <xsl:if test="not(@direction='return')">
            <xsl:message>
                <xsl:text>C'est bien un paramètre...</xsl:text>
            </xsl:message>
            <xsl:apply-templates select="." mode="selected-param"/>
        </xsl:if>
    </xsl:template>


    <!--  -->
    <xsl:template match="*" mode="get-stereotypes">
    </xsl:template>

    <xsl:template match="*" mode="has-stereotype">
        <xsl:param name="element"/>
        <xsl:value-of select="true()"/>
    </xsl:template>


    <xsl:template match="*" mode="get-package">
        <xsl:if test="../@*[local-name()='type']='uml:Package'">
            <xsl:apply-templates select=".." mode="_get-package"/>
        </xsl:if>
    </xsl:template>


    <!-- 
      - Méthode interne. Ne devrait être appelée que sur un package.
      -->
    <xsl:template match="*" mode="_get-package">
        <xsl:if test="../@*[local-name()='type']='uml:Package'">
            <xsl:apply-templates select=".." mode="_get-package"/>
            <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- D E T E C T I O N   D E   L ' H E R I T A G E                       -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:template match="*" mode="select-superclasses">
        <xsl:if test="generalization/@general">
            <xsl:apply-templates select="id(generalization/@general)"/>
        </xsl:if>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- N A T U R E   D E   L ' E L E M E N T                               -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:function name="fete:isEntity">
        <xsl:param name="classe"/>
        <xsl:value-of select="true()"/>
    </xsl:function>

    <xsl:function name="fete:isPackage">
        <xsl:param name="packagedElement"/>
        <xsl:value-of select="$packagedElement/@*[local-name()='type']='uml:Package'"/>
    </xsl:function>

    <xsl:function name="fete:hasStereotype">
        <xsl:param name="stereotype"/>
        <xsl:value-of select="false()"/>
    </xsl:function>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- U T I L I T A I R E S   D E   L O G                                 -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:template match="*" mode="dump">
        <xsl:message>
            <xsl:value-of select="name()"/>
            <xsl:text> : </xsl:text>
        </xsl:message>
        <xsl:for-each select="@*">
            <xsl:message>
                <xsl:text>    </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="."/>
            </xsl:message>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@*" mode="dump">
        <xsl:message>
            <xsl:value-of select="name()"/>
            <xsl:text> : </xsl:text>
            <xsl:value-of select="."/>
        </xsl:message>
    </xsl:template>

    <xsl:template match="* | /" mode="xpath">
        <xsl:apply-templates select=".." mode="xpath"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[local-name() = local-name(current())])+1"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

</xsl:stylesheet>
