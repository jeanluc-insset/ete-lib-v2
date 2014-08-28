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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:uml='http://www.omg.org/spec/UML/20110701'
 xmlns:uml_2_2='http://www.omg.org/spec/UML/20110701'
 xmlns:xmi='http://www.omg.org/spec/XMI/20110701'
 xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
 xmlns:MagicDraw_Profile='http://www.omg.org/spec/UML/20110701/MagicDrawProfile'
 xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
 xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
 xmlns:UML_Standard_Profile='http://www.omg.org/spec/UML/20110701/StandardProfileL2'
 xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>


    <xsl:import href="lecture_1.xsl" />


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

    <!-- Recupere les stereotypes d'une classe dont on fournit l'id -->
    <xsl:key name="stereotypes" match="*[@base_Class]"
             use="@base_Class"/>

    <xsl:key name="reverse" match="ownedAttribute[@association]"
             use="@association"/>


    <xsl:key name="scenarios" match="ownedBehavior[@xmi:type='uml:Interaction']" use="1"/>

    <xsl:key name="classe_par_id" match="packagedElement" use="@id"/>
    <!-- S'applique aussi aux énumérations, en fait à tout ce qui est dans un
        paquetage -->
    <xsl:key name="classe_par_xml_id" match="packagedElement" use="@xmi:id"/>


    <xsl:template match="/">
        <xsl:message>
--------------------------------------------------------------------------------------
Lecture MD 17.0.2 et 18.0
Version 2.2
Cette version de MD utilise les espaces de noms .../20110701 et
inclut une feuille pour les espaces de noms .../20131001
Le corps des contraintes des opérations est un sous-élément au lieu d'être un
attribut
Cette version de lecture.xsl est architecturée par le contenu du modèle plutôt
que par les stéréotypes
--------------------------------------------------------------------------------------
        </xsl:message>
        <xsl:apply-templates select="*" mode="racine"/>
    </xsl:template>


    <xsl:template match="*" mode="racine">
        <!-- Copie du document initial -->
        <xsl:message>DEBUT DE LA LECTURE - Version 2.0</xsl:message>
        <xsl:copy>
            <xsl:message>TODO : COPIE DU DOCUMENT INITIAL...
                    Dans cette version, la copie est désactivée</xsl:message>
<!--            <xsl:copy-of select="@*"/>
                <xsl:copye-of select="*"/>
 -->
            <xsl:message>AJOUT DES ELEMENTS DU META-MODELE Ete</xsl:message>
            <xsl:apply-templates select="uml:Model/packagedElement[@xmi:type='uml:Model']"/>
       </xsl:copy>
    </xsl:template>


    <!-- On ne traite que les "packages", pas les profils importés.
         Il y a une règle spécifique pour les "packages".
         Cette règle permet d'ignorer les autres fils directs de uml:Model
         Attention, il y a d'autres règles avec le même attribut "match"
         mais dans des modes spécifiques.
      -->
    <xsl:template match="packagedElement">
        <xsl:message>PackagedElement ignore : <xsl:value-of select="@name"/></xsl:message>
    </xsl:template>


    <xsl:template match="packagedElement[@xmi:type='uml:Model']">
        <xsl:apply-templates/>
    </xsl:template> 


    <xsl:template match="packagedElement[@xmi:type='uml:Package']">
        <xsl:message>PackagedElement traite : <xsl:value-of select="@name"/></xsl:message>
        <xmi:Extension extender="ete">
            <model version="1.0">
                <!-- Ajout des acteurs -->
                <xsl:apply-templates
                    select=".//packagedElement[@xmi:type='uml:Actor']"/>

                <xsl:message>
                    <xsl:text> - Generation des interfaces</xsl:text>
                </xsl:message>
                <xsl:apply-templates
                    select=".//packagedElement[@xmi:type='uml:Interface']"
                    />

                <!-- Chaque classe est marquee par ses stereotypes.
                     Une classe est traduite par un élément
                     <class> sauf pour les classes marquées par
                     les stereotypes "entity", "boundary"... qui sont
                     traduites respectivements par des éléments
                     <entity>, <boundary>, <session>, <webservice> (liste
                     non exhaustive).
                  -->
                <xsl:message>
                    <xsl:text> - Generation des classes</xsl:text>
                </xsl:message>
                <xsl:apply-templates
                    select=".//packagedElement[@xmi:type='uml:Class']"
                    />
                <xsl:message>
                    <xsl:text> - Generation des énumérations</xsl:text>
                </xsl:message>
                <xsl:apply-templates
                    select=".//packagedElement[@xmi:type='uml:Enumeration']"/>
            </model>
            </xmi:Extension>
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
        <xsl:variable name="nom">
            <xsl:call-template name="stripspace">
                <xsl:with-param name="name" select="@name"/>
            </xsl:call-template>
        </xsl:variable>
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


    <!--
      - Appelée pour une association ayant à l'une des extrêmités l'élément
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
            <xsl:attribute name="idUML">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
             <!-- TODO : copier la définition des boundary components ici -->
        <xsl:apply-templates select="//packagedElement[@xmi:id = current()/@type]"/>              
        </xsl:element>
        </xsl:if>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                         I N T E R F A C E S                         -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="packagedElement[@xmi:type='uml:Interface']">
        <interface>
            <xsl:apply-templates select="." mode="communs"/>
        </interface>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                            C L A S S E S                            -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="packagedElement[@xmi:type='uml:Class']">
        <xsl:variable name="typeClasse">
            <xsl:apply-templates select="." mode="determine-type-classe"/>
        </xsl:variable>
        <xsl:element name="{ $typeClasse }">
            <xsl:apply-templates select="." mode="communs"/>
        </xsl:element>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                            C O M M U N S                            -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- S'applique aux interfaces et aux classes, quel que soient leurs
         types (Entity, boundary, control, pojo...) -->
    <xsl:template match="*" mode="communs">
        <xsl:attribute name="id-ref">
            <xsl:value-of select="@xmi:id"/>
        </xsl:attribute>
        <name>
            <xsl:value-of select="@name"/>
        </name>
        <xsl:for-each select="generalization">
            <generalization>
                <xsl:message>
                    <xsl:text>Generalisation : </xsl:text>
                    <xsl:value-of select="@general"/>
                    <xsl:text> -&gt; </xsl:text>
                    <xsl:value-of select="//packagedElement[@xmi:id = current()/@general]/@name"/>
                </xsl:message>
                <xsl:value-of select="//packagedElement[@xmi:type='uml:Class' and @xmi:id = current()/@general]/@name"/>
            </generalization>
        </xsl:for-each>
        <package>
            <xsl:apply-templates select=".." mode="calcPackage"/>
        </package>
<!--        <xsl:apply-templates select="generalization"/> -->
        <xsl:apply-templates select="ownedAttribute"/>
        <xsl:apply-templates select="ownedOperation"/>
        <xsl:apply-templates select="ownedRule" mode="invariant"/>
    </xsl:template>


    <xsl:template match="generalization">
        <generalization>
          <xsl:apply-templates select="//*[@xmi:id = current()/@general]" mode="type-utilisateur"/>
        </generalization>
    </xsl:template>
        

    <!-- S'applique aussi bien à une interface qu'à une classe -->
    <xsl:template match="*" mode="general">
        <type>
            <xsl:value-of select="@name"/>
        </type>
        <package>
            <xsl:apply-templates select=".." mode="calcPackage"/>
        </package>
    </xsl:template>


    <xsl:template match="ownedAttribute">
        <xsl:choose>
            <xsl:when test="@association">
                <association>
                    <!-- Si c'est un type utilisateur -->
                    <name>
                        <xsl:value-of select="@name"/>
                    </name>
                    <xsl:apply-templates select="@type" mode="type-utilisateur"/>
                    <!-- Si c'est un type primitif -->
                    <xsl:apply-templates select="type/@href" mode="determine-type-primitif"/>
<!--                    <xsl:apply-templates select="." mode="communs"/>
                     TODO : recherche de la propriete opposee eventuelle 
                    <xsl:apply-templates select="." mode="opposite"/>-->
                    <xsl:apply-templates select="." mode="cardinality"/>
                </association>
            </xsl:when>
            <xsl:otherwise>
                <property>
                    <xsl:apply-templates select="." mode="communs"/>
                </property>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="ownedAttribute" mode="opposite">
        <!-- La clef "reverse" permet de trouver toutes les extremites
             de l'association.
             Il faut traiter l'extremite qui n'est pas "current()"
         -->
        <xsl:variable name="nom">
            <xsl:value-of select="@name"/>
        </xsl:variable>
        <xsl:message>Recherche de la reciproque de <xsl:value-of select="$nom"/></xsl:message>
        <xsl:for-each select="key('reverse', @association)/memberEnd[@xmi:idref != current()/@xmi:id]">
            <xsl:message>Etude de l'association <xsl:value-of select="@xmi:id"/></xsl:message>
            <xsl:for-each select="id(@xmi:idref)">
                <xsl:message>L'oppose de <xsl:value-of select="$nom"/> est <xsl:value-of select="@name"/></xsl:message>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>


    <!-- S'applique aussi bien aux proprietes "normales" qu'aux associations -->
    <xsl:template match="ownedAttribute" mode="communs">
        <xsl:attribute name="id-ref">
            <xsl:value-of select="@xmi:id"/>
        </xsl:attribute>
        <name>
            <xsl:value-of select="@name"/>
        </name>
        <!-- Generer le paquetage et le nom de la classe/interface -->
        <!-- ou generer le type primitif -->
        <xsl:apply-templates select="." mode="determine-type"/>
        <!-- generer la cardinalite -->
        <xsl:apply-templates select="." mode="cardinality"/>
    </xsl:template>


    <xsl:template match="*" mode="cardinality">
        <cardinality>
            <xsl:choose>
                <xsl:when test="upperValue/@value">
                    <xsl:value-of select="upperValue/@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </cardinality>
    </xsl:template>


    <xsl:template match="ownedOperation">
        <operation id-ref="{ @xmi:id }">
            <name>
                <xsl:value-of select="@name"/>
            </name>
            <type>
            <xsl:choose>
                <xsl:when test="ownedParameter[@direction='return']">
                    <!-- TODO : type de retour de l'operation -->
                    <!-- TODO : cardinalite du retour de l'operation -->
                    <xsl:message>
                        <xsl:text>RECHERCHE DU TYPE DE L'OPERATION </xsl:text>
                        <xsl:value-of select="@name"/>
                    </xsl:message>
                    <xsl:apply-templates select="ownedParameter[@direction='return']" mode="determine-type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>void</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            </type>
            <xsl:apply-templates select="ownedParameter" mode="operation"/>
            <xsl:message>        generation des conditions pour <xsl:value-of select="@name"/>
            </xsl:message>
            <xsl:apply-templates select="ownedRule" mode="prepost"/>
        </operation>
    </xsl:template>


    <xsl:template match="ownedParameter" mode="operation">
        <xsl:choose>
            <xsl:when test="@direction = 'return'">
                <return>
                    <xsl:apply-templates select="." mode="communs"/>
                </return>
            </xsl:when>
            <xsl:otherwise>
                <parameter>
                    <xsl:apply-templates select="." mode="communs"/>
                </parameter>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="ownedParameter" mode="communs">
        <xsl:attribute name="id-ref">
            <xsl:value-of select="@xmi:id"/>
        </xsl:attribute>
        <!-- Parametre "normal" -->
        <xsl:if test="@name != 'result'">
            <name>
                <xsl:value-of select="@name"/>
            </name>
        </xsl:if>
        <xsl:apply-templates select="." mode="determine-type"/>
        <xsl:apply-templates select="." mode="cardinality"/>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:template match="ownedRule" mode="invariant">
        <invariant>
            <name>
                <xsl:value-of select="@name"/>
            </name>
            <xsl:for-each select="specification">
                <xsl:variable name="nomSpec">
                    <xsl:apply-templates select="language" mode="langage"/>
                </xsl:variable>
                <xsl:element name="{ $nomSpec }">
                    <xsl:value-of select="body"/>
                </xsl:element>
            </xsl:for-each>
        </invariant>
    </xsl:template>

    <xsl:template match="ownedRule" mode="prepost">
        <xsl:variable name="nom">
            <xsl:choose>
                <xsl:when test="@name='pre'">
                    <xsl:text>pre</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>post</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{ $nom }">
            <xsl:for-each select="specification">
                <xsl:variable name="nomSpec">
                    <xsl:apply-templates select="language" mode="langage"/>
                </xsl:variable>
                <xsl:variable name="nomSpecOK">
                    <xsl:choose>
                        <xsl:when test="string-length($nomSpec)">
                            <xsl:value-of select="$nomSpec"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>OCL-2-0</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="{ $nomSpecOK }">
                    <xsl:value-of select="body"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                            E N T I T E S                            -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- Nouvelle version, pour traiter les stéréotypes non standard
         comme <<pojo>>  -->
    <xsl:template match="*[@base_Class]" mode="entity">
        <xsl:variable name="initMin">
            <xsl:call-template name="initMin">
                <xsl:with-param name="name" select="local-name()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="{ $initMin }">
            <xsl:attribute name="idUML">
                <xsl:value-of select="@base_Class"/>
            </xsl:attribute>
            <xsl:apply-templates select="//packagedElement[@xmi:id = current()/@base_Class]"/>
        </xsl:element>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!--                        U T I L I T A I R E S                        -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!--
      - A appliquer à un type utilisateur
      -->
    <xsl:template match="*" mode="determine-type">
        <xsl:if test="local-name() = 'ownedParameter'">
            <xsl:message>
                <xsl:text>     Recherche du type du parametre </xsl:text>
                <xsl:value-of select="type/xmi:Extension/referenceExtension/@referentPath"/>
            </xsl:message>
            <xsl:if test="type/@href">
                <xsl:message>
                    <xsl:text>       type/@href = </xsl:text>
                    <xsl:value-of select="type/@href"/>
                </xsl:message>
            </xsl:if>
        </xsl:if>
        
        <type>
            <!-- Si c'est un type utilisateur -->
            <xsl:apply-templates select="@type" mode="type-utilisateur"/>
            <!-- Si c'est un type primitif -->
<!--            <xsl:apply-templates select="type/@href" mode="determine-type-primitif"/>-->
            <!-- Si c'est une reference -->
            <xsl:apply-templates select="type/xmi:Extension/referenceExtension/@referentPath"
                                mode="determine-type-reference-extension"/>
        </type>
    </xsl:template>

    <xsl:template match="@type" mode="type-utilisateur">
        <xsl:message>
            <xsl:text>Recheche du type </xsl:text>
            <xsl:value-of select="."/>
        </xsl:message>
        <xsl:apply-templates select="//packagedElement[@xmi:id=current()]" mode="decris-type-utilisateur"/>
    </xsl:template>
    
    <xsl:template match="@referentPath" mode="determine-type-reference-extension">
        <xsl:call-template name="dernierMot">
            <xsl:with-param name="chaine" select="."/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="packagedElement" mode="decris-type-utilisateur">
        <xsl:message>
            <xsl:text>       Le type est </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="@name='Date'">
                <xsl:text>Date</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <type>
                    <xsl:value-of select="@name"/>
                </type>
                <package>
                    <xsl:apply-templates select=".." mode="calcPackage"/>
                </package>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="@href" mode="determine-type-primitif">
        <xsl:value-of select="substring-after(., '#')"/>
    </xsl:template>

    <xsl:template match="packagedElement" mode="determine-type-classe">
        <xsl:choose>
            <xsl:when test="key('stereotypes', @xmi:id)[local-name()='Entity']">
                <xsl:text>Entity</xsl:text>
            </xsl:when>
            <xsl:when test="key('stereotypes', @xmi:id)[local-name()='Boundary']">
                <xsl:text>Boundary</xsl:text>
            </xsl:when>
            <xsl:when test="key('stereotypes', @xmi:id)">
                <xsl:value-of select="local-name(key('stereotypes', @xmi:id)[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>class</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="calcPackage">
        <!-- TODO : permettre de determiner la racine des paquetages par
             un parametre -->
        <xsl:if test="../*[@xmi:type='uml:Package'] and ../@name!='Data'">
            <xsl:apply-templates select=".." mode="calcPackage"/>
            <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
    </xsl:template>

    <xsl:template name="stripspace">
        <xsl:param name="name"/>
        <xsl:value-of select="$name"/>
    </xsl:template>

    <xsl:template name="initMin">
        <xsl:param name="name"/>
        <xsl:value-of select="$name"/>
    </xsl:template>

    <xsl:template match="language" mode="langage">
        <xsl:choose>
            <xsl:when test="contains(., 'OCL')">
                <xsl:text>OCL</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select='.'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dernierMot">
        <xsl:param name="chaine"/>
        <xsl:choose>
            <xsl:when test="contains($chaine, ':')">
                <xsl:call-template name="dernierMot">
                    <xsl:with-param name="chaine" select="substring-after($chaine, ':')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$chaine"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
