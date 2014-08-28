<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lectureMD.xsl
    Created on : 1 novembre 2010, 22:32
    Author     : jldeleage
    Description:
        Lit un document MagicDraw (ou plus généralement UML 2.2 / XMI 2.1)
        et produit un modèle "ete".

        Mise en place d'une sorte de pattern visitor :
        quand la feuille cherche à produire un certain types d'éléments à
        partir du document source, elle invoque les règles avec un mode
        "select-xxx" ou "get-xxx".
        Par exemple :
        <xsl:apply-templates select="//*" mode="select-classes"/>

        Chaque feuille importée doit implémenter l'interface correspondante
        ou plutôt la classe abstraite car des implémentations par défaut sont
        fournies dans la feuille "feuille-abstraite.xsl".

        Pour cela, elle définit une règle pour chaque mode "select-xxx" qui
        filtre les nœuds cherchés (par l'attribut "match" ou par des
        instructions de test).
        Pour chaque nœud acceptable, la règle invoque les règles sur le nœud
        de contexte dans le mode xxx.
        Suite de l'exemple :
        <xsl:template match="..." mode="select-classes">
            <xsl:apply-templates select="." mode="class"/>
        </xsl:template>

        La feuille principale a ensuite une règle particulière de traitement
        de ce mode.
        Dans l'exemple, on a donc la règle qui traite les classes de la forme :
        <xsl:template match="*" mode="class">
        </xsl:template>.
        Cette règle ne sera donc invoquée que pour les nœuds considérés comme
        des classes par la feuille importée.

        Les "méthodes" get-xxx renvoient directement la valeur demandée :

        <xsl:template match="..." mode="get-name">
            <xsl:value-of select="@name"/>
        </xsl:template>

        TODO : les "méthodes" select-xxx ne s'appliquent qu'à des éléments.
        Peut-il y avoir des termes à sélectionner qui soient des attibuts ?
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
         xmlns:fete="http://www.insset.u-picardie.fr/jeanluc/ete.html"
         xmlns:ete="http://www.magicdraw.com/schemas/ete.xmi"
         xmlns:uml='http://www.omg.org/spec/UML/20110701'
         xmlns:uml_2_2='http://www.omg.org/spec/UML/20110701'
         xmlns:xmi='http://www.omg.org/spec/XMI/20110701'
         xmlns:MagicDraw_Profile='http://www.omg.org/spec/UML/20110701/MagicDrawProfile'
         xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'
         xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi'
         xmlns:UML_Standard_Profile='http://www.omg.org/spec/UML/20110701/StandardProfileL2'
         xmlns:stéréotypes='http://www.magicdraw.com/schemas/stéréotypes.xmi'>


    <!-- Fonctions utilitaires et comportements par défaut ("super-classe"
         des pilotes spécifiques aux différentes versions UML/XMI)
      -->
    <xsl:import href="feuille_abstraite.xsl"/>

    <!-- Feuilles spécifiques aux différentes versions UML/XMI -->
    <xsl:include href="lecture_20110701.xsl" />
    <xsl:include href="lecture_20131001.xsl" />


   <xsl:param name="copie-modele-initial" select="false()"/>


    <xsl:output method="xml" indent="yes"/>



    <xsl:template match="/">
        <xsl:message>
------------------------------------------------------------------------
Lecture MD 17.0.2 et 18.0
Version 2.2
Cette version de lecture.xsl est architecturée par le contenu du modèle
plutôt que par les stéréotypes : la feuille parcourt le document en
cherchant les éléments de type classe, interface. Ensuite elle recommence
en cherchant les éléments de type acteur. Puis elle parcourt le document
en cherchant les éléments de type cas d'utilisation. Enfin elle parcourt
le document à la recherche des diagrammes d'états, d'activité, de séquence
et de communication.
Les seuls éléments pris en compte sont ceux se trouvant dans un modèle
marqué par le stéréotype "ete".
------------------------------------------------------------------------</xsl:message>
        <!--
            Il y a plusieurs espaces de noms possibles. De ce fait, on ne
            connaît pas l'espace de noms exact de l'élément racine.
            On traite tout, comme ça on est tranquille
          -->
        <xsl:apply-templates select="*" mode="racineXmi"/>
        <xsl:message>------------------------------------------------------------------------</xsl:message>
    </xsl:template>


    <!-- Construit le document
      -->
    <xsl:template match="*" mode="racineXmi">
        <!-- La feuille dédiée à l'espace de noms du document affiche des
             informations la concernant
          -->
        <xsl:apply-templates select="." mode="info"/>
        <xsl:message>------------------------------------------------------------------------</xsl:message>
        <!-- Copie de l'élément racine... -->
        <xsl:copy>
            <!-- ...et de ses attributs -->
            <xsl:copy-of select="@*"/>
            <!-- Copie du contenu du document initial -->
            <xsl:apply-templates select="." mode="copie-modele-initial"/>
            <!-- Creation du modele ete -->
            <!-- Il faut générer un élément d'extension dans le même
                espace de noms que  le document initial car on a copié l'élément
                racine de ce document.
                Sinon, on risque alors d'avoir des documents hétérogènes,
                difficiles à relire.
                Ce template est redéfini dans les feuilles d'adaptation aux
                espaces de noms et doit appeler l'instruction
                <xsl:apply-templates select="." mode="callback-extension-element/>
              -->
            <xsl:apply-templates select="." mode="create-extension-element">
                <xsl:with-param name="action" tunnel="yes"
                                select="'callback-extension-element'"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Copie du modele initial                                             -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:template match="node()" mode="copie-modele-initial">
        <xsl:choose>
            <xsl:when test="$copie-modele-initial">
                <xsl:copy-of select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Copie du modèle initial désactivée</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Contenu de l'élément extension                                      -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Appelé sur l'élément racine -->
    <xsl:template match="*" mode="callback-extension-element">
        <xsl:message>Callback</xsl:message>
        <xsl:apply-templates select="* | */*" mode="select-ete-model">
            <xsl:with-param name="action" tunnel="yes" select="'ete-model'"/>
        </xsl:apply-templates>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Parcours du document initial à la recherche d'éléments à traiter    -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- Remplissage de l'extension spécifique ete
         Cette règle est invoquée par une feuille d'adaptation à l'espace
         de noms.
      -->
    <xsl:template match="*" mode="ete-model">
        <!-- TODO : ne traiter que les modèles portant le stéréotype "ete" -->
        <!-- Traitements des éléments "modèle" 'top-level' et portant le
             stéréotype "ete".
             Chaque feuille correspondant à une version UML/XMI définit ses
             propres règles.
          -->
        <xsl:message>TRAITEMENT du modele...</xsl:message>
        <model>
        <xsl:apply-templates select=".//*" mode="select-classes">
            <xsl:with-param name="action" tunnel="yes" select="'process-class'"/>
        </xsl:apply-templates>
        </model>
        <!--<xsl:apply-templates select=".//*" mode="select-acteur"/>-->
        <!--<xsl:apply-templates select=".//*" mode="select-scenario"/>-->
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="*" mode="package">
        
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- C L A S S E S                                                       -->
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <!-- Le nœud de contexte représente une classe dans le document du
         modèle -->
    <xsl:template match="* | @*" mode="process-class">
        <xsl:message>
            <xsl:text>GENERATION DE LA CLASSE : </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:message>
        <!-- Détermine s'il faut générer un élément Entity, Boundary, Class
             ou autre
             TODO : remplacer par l'invocation d'une règle, comme pour
             le traitement des attributs en propriété ou association
        -->
        <xsl:variable name="nom-element">
            <xsl:choose>
                <xsl:when test="fete:isEntity(.)">
                    <xsl:text>Entity</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>class</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{ $nom-element}">
            <package>
                <xsl:apply-templates select="." mode="get-package"/>
            </package>
            <name>
                <xsl:apply-templates select="." mode="get-name">
                    <xsl:with-param name="action"
                            select="'get-name'" tunnel="yes"/>
                </xsl:apply-templates>
            </name>
            <xsl:apply-templates select="." mode="does-it-have-subclasses">
                <xsl:with-param name="action" tunnel="yes"
                    select="'has-subclasses'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="." mode="select-superclasses">
                <xsl:with-param name="action" tunnel="yes" select="'process-superclass'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*" mode="select-attributes">
                <xsl:with-param name="action"
                            select="'process-attribute'"
                            tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*" mode="select-operations">
                <xsl:with-param name="action"
                            select="'process-operation'"
                            tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*" mode="select-associations">
                <xsl:with-param name="action" select="process-association"
                            tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>


    <xsl:template match="*" mode="has-subclasses">
        <hasSubclasses/>
    </xsl:template>

    <!-- Le nœud de contexte est le nœud définissant la super-classe -->
    <xsl:template match="*" mode="process-superclass">
        <superclass>
            <package>
                <xsl:apply-templates select="." mode="get-package"/>
            </package>
            <name>
                <xsl:apply-templates select="." mode="get-name"/>
            </name>
        </superclass>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="*" mode="process-operation">
        <operation>
            <name>
                <xsl:apply-templates select="." mode="get-name"/>
            </name>
            <type>
                <xsl:apply-templates select="." mode="get-type-of-operation"/>
            </type>
            <xsl:apply-templates select=".//*" mode="select-params">
                <xsl:with-param name="action" select="'process-param'" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select=".//*" mode="select-preconditions">
                <xsl:with-param name="action" select="'process-precondition'" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select=".//*" mode="select-result-specification">
                <xsl:with-param name="action" select="process-result-specification" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select=".//*" mode="select-postconditions">
                <xsl:with-param name="action" select="'process-postcondition'" tunnel="yes"/>
            </xsl:apply-templates>
        </operation>
    </xsl:template>


    <xsl:template match="* | @*" mode="process-param">
        <param>
            <name>
            <xsl:apply-templates select="." mode="get-name"/>
            </name>
            <type>
                <xsl:apply-templates select="." mode="get-type"/>
            </type>
        </param>
    </xsl:template>


    <xsl:template match="* | @*" mode="process-result-specification">
        <result>
            <xsl:apply-templates select="." mode="get-result-specification"/>
        </result>
    </xsl:template>

    <xsl:template match="* | @*" mode="process-precondition">
        <precondition>
            <name>
                <xsl:apply-templates select="." mode="get-name-of-condition"/>
            </name>
            <expression>
                <xsl:apply-templates select="." mode="get-expression-of-condition"/>
            </expression>
        </precondition>
    </xsl:template>


    <xsl:template match="* | @*" mode="process-postcondition">
        <postcondition>
            <name>
                <xsl:apply-templates select="." mode="get-name-of-condition"/>
            </name>
            <expression>
                <xsl:apply-templates select="." mode="get-expression-of-condition"/>
            </expression>
        </postcondition>
    </xsl:template>



    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


    <xsl:template match="* | @*" mode="process-attribute">
        <xsl:variable name="property-or-association">
            <xsl:apply-templates select="." mode="get-nature-of-attribute"/>
        </xsl:variable>
        <xsl:element name="{ $property-or-association }">
            <name>
                <xsl:apply-templates select="." mode="get-name"/>
            </name>
            <type>
                <xsl:apply-templates select="." mode="get-type"/>
            </type>
            <cardinality>
                <xsl:apply-templates select="." mode="get-cardinality"/>
            </cardinality>
            <!-- On n'a pas forcément de "revese-cardinality", ce n'est
                donc pas un mode get-xxx -->
            <xsl:apply-templates select="." mode="reverse-cardinality"/>
            <!-- On na pas forcément d'élément "mappedBy", ce n'est donc
                pas un mode get-xxx -->
            <xsl:apply-templates select="." mode="select-mappedBy"/>
        </xsl:element>
    </xsl:template>



    <xsl:template match="*" mode="process-reverse-cardinality">
        <xsl:param name="reverseCardinality" tunnel="yes"/>
        <reverseCardinality>
            <xsl:value-of select="$reverseCardinality"/>
        </reverseCardinality>
    </xsl:template>


    <xsl:template match="* | @*" mode="process-mappedBy">
        <xsl:param name="mappedBy" tunnel="yes"/>
        <mappedBy>
            <xsl:value-of select="$mappedBy"/>
        </mappedBy>
    </xsl:template>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->



</xsl:stylesheet>
