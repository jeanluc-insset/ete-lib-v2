/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

/**
 * Certaines ressources sont dans des "jar", d'autres sont dans des fichiers
 * externes.<br/>
 * Cette classe masque les diff&eacute;rents comportements.
 *
 * @author jldeleage
 */
public abstract class ChargeurRessource {

    /**
     * Renvoie le chemin d'acc&egrave;s &agrave; cette ressource sans la
     * ressource elle-m&ecirc;me.<br/>
     * Utilis&eacute; dans les modules des templates. Quand un module en
     * importe un autre, il d&eacute;signe ce second module par un chemin
     * relatif.<br/>
     * Les templates sont transform&eacute;s en feuilles XSLT avec les
     * m&ecirc;mes chemins relatifs.<br/>
     * Pour que la feuille de transformation trouve les modules import&eacute;s,
     * elle doit conna&icirc;tre le chemin d'acc&egrave;s au module
     * importateur.<br/>
     * En effet, son r&eacute;pertoire de travail est celui de l'application,
     * non celui du plugin. Donc on ne peut pas compter sur un chemin
     * relatif canonique.<br/>
     * Si le module "pojo.xml" dans le dossier templates/java du plug-in
     * (de chemin $plugin) importe le module "operation.xml", il faut que la
     * feuille de transformation retrouve le fichier
     * $plugin/templates/java/operation.xml. Le plus simple est de fournir
     * &agrave; le feuille de transformation le chemin $plugin/templates/java/
     * 
     * @param inNomFichier
     * @return
     * @throws IOException 
     */
    public abstract String      getRacine(String inNomFichier) throws IOException;

    /**
     * 
     * @param chemin
     * @return
     * @throws IOException 
     */
    public abstract InputStream getResource(String chemin) throws IOException;

    /**
     * 
     * @param chemin
     * @return
     * @throws IOException 
     */
    public abstract boolean     isDirectory(String chemin) throws IOException;

    /**
     * 
     * @param chemin
     * @return
     * @throws IOException 
     */
    public abstract Iterable<String> getNames(String chemin) throws IOException;

    /**
     * 
     * @param nom
     * @return
     * @throws IOException
     * @throws ClassNotFoundException 
     */
    public abstract Class       chargeClasse(String nom) throws IOException, ClassNotFoundException;


}


