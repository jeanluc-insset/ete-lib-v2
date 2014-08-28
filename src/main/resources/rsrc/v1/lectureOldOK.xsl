<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lectureMD.xsl
    Created on : 1 novembre 2010, 22:32
    Author     : jldeleage
    Description:
        Lit un document MagicDraw (ou plus généralement UML 2.2 / XMI 2.1)
        et produit un modèle "ete".
    TODO: ajouter d'autres formats UML/XMI
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
 xmlns:uml_2_2='http://schema.omg.org/spec/UML/2.2'
 xmlns:xmi='http://schema.omg.org/spec/XMI/2.1'
 xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
 xmlns:MagicDraw_Profile='http://www.magicdraw.com/schemas/MagicDraw_Profile.xmi'
 xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
 xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
 xmlns:UML_Standard_Profile='http://www.magicdraw.com/schemas/UML_Standard_Profile.xmi'
 xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>

    <xsl:output method="xml" indent="yes"/>

    <xsl:key name="reverse" match="ownedAttribute[@association]"
             use="@association"/>


    <xsl:key name="scenarios" match="ownedBehavior[@xmi:type='uml:Interaction']" use="1"/>

    <xsl:key name="classe_par_id" match="packagedElement" use="@id"/>
    <!-- S'applique aussi aux énumérations, en fait à tout ce qui est dans un
        paquetage -->
    <xsl:key name="classe_par_xml_id" match="packagedElement" use="@xmi:id"/>


    <xsl:template match="/">
        <xsl:apply-templates select="xmi:XMI"/>
    </xsl:template>



    <xsl:template match="xmi:XMI">
        <!-- Copie du document initial -->
        <xsl:message>DEBUT DE LA LECTURE - Version 1.0</xsl:message>
        <xsl:copy>
            <xsl:message>COPIE DU DOCUMENT INITIAL...</xsl:message>
            <xsl:copy-of select="*"/>
            <xsl:message>AJOUT DES ELEMENTS DU META-MODELE Ete</xsl:message>
            <xmi:Extension extender="ete">
            <model version="1.0">
                <!-- Acteurs -->
                <xsl:apply-templates
                    select="//packagedElement[@xmi:type='uml:Actor']"/>
                <!--
                    Classes stéréotypées.
                    TODO : les composants "boundary" ne devraient-il pas
                        être lus dans les acteurs ?
                -->
                <xsl:apply-templates
                    select="*[@base_Class]"/>
                <!--
                    Énumérations
                  -->
                <xsl:apply-templates
                    select="//packagedElement[@xmi:type='uml:Enumeration']"/>
            </model>
            </xmi:Extension>
        </xsl:copy>
        <xsl:message>FIN DE LA LECTURE DU MODELE INITIAL</xsl:message>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                            A C T E U R S                            -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!--
      - Ajoute les éléments <actor>.
      - Pour chacun, ajoute le dossier dans lequel placer les pages web de
      - cet acteur ainsi que les pages elles-mêmes.
      -->
    <xsl:template match="packagedElement[@xmi:type='uml:Actor']">
        <xsl:variable name="nom" select="ete:stripspace(@name)"/>
        <xsl:if test="string-length($nom)">
        <actor>
            <name><xsl:value-of select="$nom"/></name>
            <real-name><xsl:value-of select="$nom"/></real-name>
            <folder>
            <xsl:if test="$nom != 'User' and $nom != 'Usager'">
                <xsl:value-of select="$nom"/>
            </xsl:if>
            </folder>
            <!-- Ajouter tous les "boundaries" auquel cet utilisateur a accès
               Attention : aucune vérification n'est faite sur le fait que
               l'autre extrêmité est bien un "boundary".
              -->
            <xsl:apply-templates
                    select="//packagedElement[@xmi:type='uml:Association'
                        and ownedEnd/@type=current()/@xmi:id]"
                    mode="association">
                <xsl:with-param name="idDepart" select="@xmi:id"/>
                <xsl:with-param name="nomElement" select="'boundary'"/>
            </xsl:apply-templates>
        </actor>
        </xsl:if>
    </xsl:template>




    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--               C L A S S E S   S T E R E O T Y P E E S               -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--
      -  Cette règle est appelée pour toute classe stéréotypée. Une telle
      -  classe est référencée par un élément
      -->


    <!-- Nouvelle version, pour traiter les stéréotypes non standard
         comme <<pojo>>  -->
    <xsl:template match="*[@base_Class]">
        <!-- Produit le stéréotype de la classe -->
        <xsl:element name="{ local-name() }">
            <xsl:attribute name="idUML" select="@base_Class"/>
            <!-- Ajout des attributs, opérations et associations -->
            <xsl:apply-templates select="//packagedElement[@xmi:id = current()/@base_Class]"/>
        </xsl:element>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--   C L A S S E S   ( E N T I T E S ,   P A G E S ,   C L A S S E S   -->
    <!--          D E   S E R V I C E ,   C L A S S E S   P O J O )          -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!--
      -  Seules les classes stéréotypées appellent cette règle
      -->
    <xsl:template match="packagedElement[@xmi:type='uml:Class']">
        <xsl:if test="ownedAttribute[@name='selected']">
            <!-- TODO : à revoir
              -  Les classes "boundary" peuvent possèder un élément "selected"
              -->
            <selected>
                <!--
                <type>
                    <xsl:value-of select="
                            ete:conversionType(key('classe_par_xml_id', ownedAttribute[@name='selected']/@type)/@name)"/>
                </type>
                -->
                <package>
                    <xsl:apply-templates select="key('classe_par_xml_id', ownedAttribute[@name='selected']/@type)/.." mode="calcPackage"/>
                </package>
            </selected>
        </xsl:if>
        <xsl:message>
            <xsl:text>Traitement de la classe </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:message>
        <name><xsl:value-of select="@name"/></name>
        <package><xsl:apply-templates select=".." mode="calcPackage"/></package>
        <xsl:apply-templates select="ownedAttribute"/>
        <xsl:apply-templates select="ownedOperation"/>
        <xsl:apply-templates select="ownedRule"/>
    </xsl:template>

    <xsl:template match="*" mode="copieComposant">
        <xsl:apply-templates/>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                          A T T R I B U T S                          -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="ownedAttribute">
        <xsl:choose>
            <!-- S'il s'agit d'une association porte le stéréotype <<table>> on
                 la traduit par un élément <table>
              -->
            <xsl:when test="//ete:table[@base_Property=current()/@xmi:id]">
                <table idUML="{ @association }">
                    <componentName><xsl:value-of select="@name"/></componentName>
                    <componentType><xsl:value-of select="key('classe_par_xml_id', @type)/@name"/></componentType>
                    <xsl:if test="upperValue/@value='*'">
                        <cardinality>*</cardinality>
                    </xsl:if>
                    <xsl:apply-templates select="key('classe_par_xml_id', @type)" />
                </table>
            </xsl:when>
            <!-- S'il s'agit d'une composition on la traduit par un élément
                 <component>
              -->
            <xsl:when test="@aggregation='composite'">
                <component>
                    <xsl:attribute name="idUML">
                        <xsl:value-of select="@association"/>
                    </xsl:attribute>
                    <componentName><xsl:value-of select="@name"/></componentName>
                    <componentType><xsl:value-of select="key('classe_par_xml_id', @type)/@name"/></componentType>
                    <xsl:if test="upperValue/@value='*'">
                        <cardinality>*</cardinality>
                    </xsl:if>
<!--                    <xsl:apply-templates select="key('classe_par_xml_id', @type)" mode="copieComposant"/>-->
                    <xsl:apply-templates select="key('classe_par_xml_id', @type)" />
                </component>
            </xsl:when>

            <!-- Si c'est une simple association, on la traduit par un
                 élément <association> ou un élément <navigation> selon
                 que la classe de destination est une entité ou un composant
                 frontière.
              -->
            <xsl:when test="@association">
                <xsl:variable name="id_type" select="//*[@xmi:id=current()/@type]/@xmi:id"/>
                <!-- Si l'autre extrêmité de l'association est un composant boundary,
                    il faut traduire cette association par une "navigation".
                  -->
                <xsl:variable name="nomElement">
                    <xsl:choose>
                        <xsl:when test="//UML_Standard_Profile:boundary[@base_Class = $id_type]">
                            <xsl:text>navigation</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>association</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="{ $nomElement }">
                    <xsl:attribute name="idUML">
                        <xsl:value-of select="@association"/>
                    </xsl:attribute>
                    <!-- S'il s'agit d'une association n-m bidirectionnelle,
                         ajouter l'élément <mappedBy> sur la première extrêmité
                         de l'association
                      -->
                    <!-- S'agit-il de la première occurrence de cette asspcoatop,? -->
                    <xsl:if test="generate-id(.) = generate-id(key('reverse', @association)[1])">
                        <!-- Est-ce bien une association n-m ?
                            Pour cela, on compte le nombre d'extrêmités dont
                            la cardinalité est *. Si on obtient 2, c'est OK
                          -->
                        <xsl:message>
                            <xsl:text>   association </xsl:text>
                            <xsl:for-each select="key('reverse', @association)">
                                <xsl:text>   extrêmité </xsl:text>
                                <xsl:value-of select="@name"/>
                                <xsl:text> cardinalité : [</xsl:text>
                                <xsl:value-of select="upperValue/@value"/>
                                <xsl:text>]</xsl:text>
                            </xsl:for-each>
                            <xsl:text>  Nombre total : [</xsl:text>
                            <xsl:value-of select="count(key('reverse', @association)[upperValue/@value='*'])"/>
                            <xsl:text>]</xsl:text>
                        </xsl:message>
                        <xsl:if test="count(key('reverse', @association)[upperValue/@value='*']) = 2">
                            <xsl:message>Association n-m</xsl:message>
                        <mappedBy>
                        <xsl:value-of select="key('reverse', @association)[2]/@name"/>    
                        </mappedBy>
                        </xsl:if>
                    </xsl:if>
                <!-- Garder la trace de l'identifiant dans le document d'origine -->
                <name><xsl:value-of select="@name"/></name>
                <xsl:if test="@name != 'selected' and ../ownedAttribute[@name='selected']">
                    <object>
                        <xsl:text>selected</xsl:text>
                    </object>    
                </xsl:if>
                <type>
                <!-- L'attribut type est la référence de la destination de
                    l'association. On cherche donc cette destination par
                    //*[xmi:id = current()/@type]
                    TODO : utiliser une clef
                    Ensuite, on récupère le nom de ce type
                  -->
                <xsl:attribute name="idUML" select="$id_type"/>
                <xsl:value-of select="//*[@xmi:id=current()/@type]/@name"/>
                </type>
                <package>
                <xsl:apply-templates select="//*[@xmi:id=current()/@type]/.." mode="calcPackage"/>
                </package>
                <!-- S'il y a deux éléments avec la même valeur pour 
                     l'attribut association, c'est que celle-ci est
                     bidirectionnelle.
                     Dans ce cas, on note ici le nom du rôle récuproque
                  -->
                <xsl:variable name="monId" select="generate-id()"/>
                <xsl:variable name="reverse-cardinality">
                    <!-- On note de même la cardinalité de la réciproque -->
                    <xsl:for-each select="key('reverse',@association)">
                        <xsl:if test="generate-id() != $monId">
                            <xsl:choose>
                                <xsl:when test="upperValue/@value='*'">
                                    <xsl:text>*</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>1</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="nomReverse">
                    <xsl:for-each select="key('reverse',@association)">
                        <xsl:if test="generate-id() != $monId">
                            <xsl:value-of select="@name"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="count(key('reverse',@association)) = 2">
                  <!-- On cherche l'autre extrêmité de l'aaociation
                       Pour trouver l'autre extrêmité, on parcourt toutes
                       les extrêmités de cette association et on ne garde
                       que celles différentes de self
                    -->
                  <reverse>
                      <xsl:value-of select="$nomReverse"/>
                  </reverse>
                  <reverse-cardinality>
                      <xsl:value-of select="$reverse-cardinality"/>
                  </reverse-cardinality>
                </xsl:if>    <!-- association bidirectionnelle -->
                <xsl:if test=".//*[@value='*']">
                    <!-- S'il y a la navigabilité réciproque, il faut l'indiquer
                         pour permettre l'attribut "mappedBy" de l'annotation
                         "@OneToMany"
                      -->
                    <cardinality>*</cardinality>
                    <xsl:if test="$reverse-cardinality='1'">
                        <mappedBy>
                            <xsl:value-of select="$nomReverse"/>
                        </mappedBy>
                    </xsl:if>
                </xsl:if>
                </xsl:element>
            </xsl:when>  <!-- "simple association" -->

        <xsl:otherwise>
                <!-- Ce n'est pas une association, c'est donc une propriété
                     de type scalaire
                     RECTIFICATIF : Ce peut être un attribut de type
                     utilisateur comme dans les composants "boundary".
                  -->
                <attribute>
                    <name><xsl:value-of select="@name"/></name>
                    <type>
                        <!-- L'une des deux expressions fonctionne, selon le
                        cas (type standard ou type du modèle) -->
<!--                        <xsl:value-of select="ete:derniereSousChaine(type/xmi:Extension/referenceExtension/@referentPath, '::')"/> -->
                        <xsl:choose>
                            <xsl:when test="/xmi:XMI/*/@base_Property=current()/@xmi:id">
                                <xsl:value-of select="ete:conversionType(local-name(/xmi:XMI/*[@base_Property=current()/@xmi:id]))"/>
                            </xsl:when>
                            <xsl:when test="key('classe_par_xml_id', @type)">
                                <xsl:value-of select="ete:conversionType(key('classe_par_xml_id', @type)/@name)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ete:conversionType(ete:derniereSousChaine(type/xmi:Extension/referenceExtension/@referentPath, '::'))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </type>
                    <xsl:if test="key('classe_par_xml_id', @type)">
                        <package>
                           <xsl:apply-templates select="key('classe_par_xml_id', @type)/.." mode="calcPackage"/> 
                        </package>
                    </xsl:if>
                    <xsl:if test=".//*[@value='*']">
                        <cardinality>*</cardinality>
                    </xsl:if>
                </attribute>
        </xsl:otherwise>    <!-- traitement des attributs -->
        </xsl:choose>
    </xsl:template>   <!-- ownedAttribute -->



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                         O P E R A T I O N S                         -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="ownedOperation">
        <operation idUML="{ @xmi:id }">
            <name><xsl:value-of select="@name"/></name>
            <xsl:variable name="id_type"
            select="ownedParameter[@direction='return']/type/@href"/>
            <type>
                <!-- L'attribut type est la référence de la destination de
                    l'association. On cherche donc cette destination par
                    //*[xmi:id = current()/@type]
                    TODO : utiliser une clef
                    Ensuite, on récupère le nom de ce type
                  -->
                <xsl:attribute name="idUML" select="$id_type"/>
                <!-- Une des deu valeurs est significative -->
                <!-- Type UML standard -->
                <xsl:value-of select="
                    ete:conversionType(ete:derniereSousChaine(ownedParameter[@direction='return']
                            /type/xmi:Extension/referenceExtension
                            /@referentPath, '::'))"/>
                <!-- Type utilisateur -->
                <xsl:value-of select="ete:conversionType(ownedParameter[@direction='return']/type/@name)"/>
            </type>
            <xsl:apply-templates select="ownedParameter"/>
            <xsl:apply-templates select="ownedRule"/>
            <xsl:variable name="id" select="@xmi:id"/>
            <!-- TODO: appliquer une approche plus polymorphe -->
<!--            <xsl:choose>
                <xsl:when test="/xmi:XMI/UML_Standard_Profile:destroy[@base_BehavioralFeature=$id]">
                    <destroy/>
                </xsl:when>
                <xsl:when test="/xmi:XMI/UML_Standard_Profile:create[@base_BehavioralFeature=$id]">
                    <create/>
                </xsl:when>
                <xsl:when test="/xmi:XMI/UML_Standard_Profile:update[@base_BehavioralFeature=$id]">
                    <update/>
                </xsl:when>
                <xsl:otherwise>
                    <operationStandard/>
                </xsl:otherwise>
            </xsl:choose>-->
            <!-- S'il y a un stéréotype sur l'action, il faut l'indiquer en ajoutant un
                 élément ayant pour nom ce stéréotype -->
            <xsl:if test="/xmi:XMI/*[@base_BehavioralFeature=$id]">
                <xsl:element name="{local-name(/xmi:XMI/*[@base_BehavioralFeature=$id])}">
                    <!-- Dans ce cas, le boundary component a une association
                         avec une entité ayant le rôle "selected". Il faut
                         ajouter le type de cette entité
                      -->
                    <type>
                        <xsl:value-of select="ete:conversionType(key('classe_par_xml_id',current()/../ownedAttribute[@name='selected']/@type)/@name)"/>
                    </type>
                    <package>
                    <xsl:apply-templates select="key('classe_par_xml_id',current()/../ownedAttribute[@name='selected']/@type)/.." mode="calcPackage"/>
                    </package>
                </xsl:element>
            </xsl:if>
        </operation>
    </xsl:template>


    <xsl:template match="ownedParameter['return' = @direction]"/>

    <xsl:template match="ownedParameter">
        <parametre>
            <name>
                <xsl:value-of select="@name"/>
            </name>
            <type>
            </type>
            <!-- TODO : cardinality -->
        </parametre>
    </xsl:template>

    <xsl:template match="ownedOperation/ownedRule">
        <body>
            <xsl:value-of select="specification/@body"/>
        </body>
        <xsl:choose>
            <xsl:when test="@name='result'">
                <result>
                    <xsl:analyze-string select="specification/@body" regex="result.*='">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
<!--                            <xsl:value-of select="translate(., ' \&amp;apos;','')"/>-->
                                <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </result>
            </xsl:when>
            <xsl:when test="@name='pre'">
                <xsl:message>Precondition</xsl:message>
            </xsl:when>
            <xsl:when test="@name='post'">
                <xsl:message>Postcondition : <xsl:value-of select="specitifcation/@body"/></xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>*** Contrainte non reconnue ***</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                       A S S O C I A T I O N S                       -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!--
      - Appelée pour une association ayant une des extrêmités l'élément
      - dont l'identifiant est passé en paramètre.
      - 
      - Appelle la règle correspondant à l'autre extrêmité dans le même mode.
      -->
    <xsl:template match="packagedElement" mode="association">
        <xsl:param name="idDepart"/>
        <!-- A REVOIR : mettre en paramètre "tunnel" ? -->
        <xsl:param name="nomElement" select="'association'"/>
        <xsl:apply-templates select="ownedEnd[@type != $idDepart]"
                mode="association">
            <xsl:with-param name="nomElement" select="$nomElement"/>
        </xsl:apply-templates>
    </xsl:template>


    <!--
      - Crée un élément dont le nom est défini par le paramètre "nomElement".
      - Utilisé pour créer des éléments "boundary" pour les acteurs mais peut
      - être utilisé ailleurs.
      -->
    <xsl:template match="ownedEnd" mode="association">
        <xsl:param name="nomElement" select="'useCase'"/>
        <xsl:if test="@xmi:type='uml:Class'">
        <xsl:element name="{ $nomElement }">
            <xsl:attribute name="idUML" select="@type"/>
             <!-- TODO : copier la définition des boundary components ici -->
        <xsl:apply-templates select="//packagedElement[@xmi:id = current()/@type]"/>              
        </xsl:element>
        </xsl:if>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                         I N V A R I A N T S                         -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="ownedRule">
        <xsl:if test="specification/@language='OCL2.0'">
        <xsl:message>Traitement d'un invariant</xsl:message>
        <invariant>
            <name>
                <xsl:value-of select="@name"/>
            </name>
            <ocl>
            <xsl:value-of select="specification/@body"/>
            </ocl>
        </invariant>
        </xsl:if>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                       E N U M E R A T I O N S                       -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!--
      - Ajoute les éléments <enumeration>.
      - Le contenu d'un élément <enumeration> est un séquence
      - d'éléments <litteral>.
      -->
    <xsl:template match="packagedElement[@xmi:type='uml:Enumeration']">
        <enumeration>
            <name>
                <xsl:value-of select="@name"/>
            </name>
            <package>
                <package><xsl:apply-templates select=".." mode="calcPackage"/></package>
            </package>
            <xsl:for-each select="ownedLiteral">
            <litteral>
                <xsl:value-of select="@name"/>
            </litteral>
            </xsl:for-each>
        </enumeration>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                    S C E N A R I O S   E T   U I                    -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->







    <!--
        Traitement des classes portant le stéréotype "boundary". Pour cela
        on traite le stéréotype et on déclenche le traitement sur tous
        les items portant ce stéréotype.
      -->
    <xsl:template match="UML_Standard_Profile:boundary">
        <boundary idUML="{ @base_Class }">
            <xsl:apply-templates select="//packagedElement[@xmi:id = current()/@base_Class]" mode="ui"/>
            <!-- Recherche des acteurs en relation avec ce composant frontière -->
<!--            <xsl:apply-templates select="//ownedEnd[@idref = current()/@xmi:id]" mode="autreExtremite">
                <xsl:with-param name="id" select="@xmi:id"/>
            </xsl:apply-templates>-->
        </boundary>
    </xsl:template>


<!--    <xsl:template match="ownedEnd" mode="autreExtremite">
        <xsl:param name="id"/>
        <xsl:message>RECHERCHE DE L'AUTRE EXTREMITE DE <xsl:value-of select="$id"/></xsl:message>
        <xsl:if test="$id != @xmi:id">
            <xsl:message>OK OK OK OK OK OK OK OK OK OK OK OK OK</xsl:message>
        </xsl:if>
    </xsl:template>-->



    <!-- Y a-t-il des éléments particuliers pour les composants "bpoundary" ? 
    TODO : reporter les cardinalités des champs en utilisant l'homonymie.
    Un boundary (ou un widget) est en association avec une entité. Les champs
    du boundary sont homonymes des champs de l'entité. Il faut reporter la
    cardinalité correspondante.
    Exemple : on a un boundary sur Livre. Ce boundary contient un champ
    "auteurs" or l'entité Livre a l'association n-m vers Auteur avec le nom
    de navigation "auteurs". Il faut donc considérer que le champ auteurs du
    boundary sert à éditer la valeur de la propriété auteurs du livre
    sélectionner.
    Il faut aussi "suivre" les associations.
    Exemple : on a un boundary sur Avion Ce boundary contient un widget
    sur le modèle Ce widget contient un champ de texte "nom".
    Dans la page correspondante, il faut générer :
    <h:inputText name="nom" value="#{ selected.modele.nom }"/>
      -->
    <xsl:template match="packagedElement[@xmi:type='uml:Class']" mode="ui">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <!--
        Il faut remettre dans l'ordre les messages envoyés et repérer les
        messages "forward" entre composants. Ces messages indiquent un
        hangement de composant, donc une navigation.
      -->
    <xsl:template match="ownedBehavior[@xmi:type='uml:Interaction']">
        <!-- Un scénario contient des "lifelines"
             Une "lifeline" est en fait une instance.
             Il faut repérer les instance d'acteurs et les instances de classes
             avec le stéréotype "boundary".
          -->
          <!-- Chercher l'origine du premier message.
          Il faudrait que ce soit un acteur -->
        <scenario>
            <xsl:apply-templates select="message"/>
        </scenario>
    </xsl:template>


    <xsl:template match="message">
        <message>
            <from>
        <xsl:apply-templates select="../lifeline[coveredBy/@xmi:idref = current()/@sendEvent]"/>
            </from>
            <subject>
        <xsl:value-of select="@name"/>
            </subject>
            <to>
        <xsl:apply-templates select="../lifeline[coveredBy/@xmi:idref = current()/@receiveEvent]"/>
        </to>
        </message>
    </xsl:template>


    <xsl:template match="lifeline">
        <xsl:value-of select="@name"/>
    </xsl:template>


    <!-- Filtre les éléments non traités (essentiellement  pour les champs de
    texte non significatifs qu'ils contiennent) -->
    <xsl:template match="*"/>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                                D A O                                -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Différentes règles pour accéder à des éléments particuliers         -->


    <!-- Calcul du paquetage. Renvoyé en notation Java -->

    <xsl:template match="packagedElement[@xmi:type='uml:Package']" mode="calcPackage">
        <xsl:if test="parent::packagedElement[@xmi:type='uml:Package']">
                <xsl:apply-templates select=".." mode="calcPackage"/>
                <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
    </xsl:template>

    <xsl:template match="*" mode="calcPackage"/>


    <!--
        Fonctionne que pour les types utilisateur, les types standard UML et
        effectue quelques conversions (si le paramètre porte le stéréotype
        <<time>>, c'est ce mot qui est renvoyé
      -->
    <xsl:function name="ete:type">
<!--        <xsl:param name="attribut-ou-operation"/>
        <xsl:value-of select="
                $attribut-ou-operation/key('classe_par_xml_id', @type)/@name"/>-->
        <!-- doit être un attribut ou une opération -->
        <xsl:param name="p"/>
        <xsl:message>APPEL DE ete:type avec <xsl:value-of select="$p"/></xsl:message>
<!--        <xsl:choose>
            <xsl:when test="/xmi:XMI/ete:time/@base_Property=$p/@xmi:id">
                <xsl:text>time</xsl:text>
            </xsl:when>
            <xsl:otherwise>-->
                <xsl:value-of select="ete:derniereSousChaine($p/type/xmi:Extension/referenceExtension/@referentPath, '::')"/>
<!--            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:function>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--              F O N C T I O N S   U T I L I T A I R E S              -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Convertit date en java.util.Date.
        TODO: mettre cette conversion dans l'application du template et non
        dans la lecture du document XML (pour que le modèle intermédiaire ne
        soit pas dépendant de Java).
      -->
    <xsl:function name="ete:conversionType">
        <xsl:param name="type" />
        <xsl:choose>
            <xsl:when test="$type='date'">
                <xsl:text>java.util.Date</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


<!--    <xsl:template name="derniereSousChaine">
        <xsl:param name="chaine"/>
        <xsl:param name="delim" select="'::'"/>
        <xsl:choose>
            <xsl:when test="contains($chaine, $delim)">
                <xsl:call-template name="derniereSousChaine">
                    <xsl:with-param name="chaine" select="substring-after($chaine, $delim)"/>
                    <xsl:with-param name="delim" select="$delim"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$chaine='date'">
                        <xsl:text>java.util.Date</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$chaine"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    
    <!-- Extrait la dernière sous-chaîne d'une chaîne après un séparateur donné
         Utilisée par exemple pour extraire le nom d'une classe dans un nom
         pleinement qualifié, le nom d'un fichier dans un chemin, le nom
         d'un terme dans une hiérarchie de paquetages.
      -->
    <xsl:function name="ete:derniereSousChaine">
        <xsl:param name="de"/>
        <xsl:param name="sep"/>
        <xsl:choose>
            <xsl:when test="contains($de, $sep)">
                <xsl:value-of select="ete:derniereSousChaine(substring-after($de, $sep), $sep)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$de"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ete:stripspace">
        <xsl:param name="s"/>
        <xsl:value-of select="translate($s, '&#10; &#13;', '')"/>
    </xsl:function>


</xsl:stylesheet>
