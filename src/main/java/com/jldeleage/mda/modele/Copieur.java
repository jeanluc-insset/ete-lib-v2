/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import com.jldeleage.mda.modele.ExceptionTransformation;
import com.jldeleage.mda.modele.Transformation;
import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;

/**
 * Copie un fichier ou un dossier (r&eacute;cursivement) dans le
 * projet cible.<br/>
 * Le fichier ou dossier copi&eacute; est indiqu&eacute; par l'attribut
 * <code>fichier</code>, le dossier de destination est indiqu&eacute; par
 * l'attribut <code>destination</code>.<br/>
 * En cas de dossier, l'arborescence est copi&eacute;e telle quelle et
 * le nom de la destination doit d&eacute;signer un dossier.<br/>
 * En cas de fichier, la destination peut d&eacute;signer un fichier
 * (en ne se terminant par /) ou un nom de dossier. Dans ce dernier cas,
 * le fichier ne peut pas &ecirc;tre renomm&eacute;.<br/>
 * Dans les deux cas, la destination est optionnelle.<br/>
 * Les fichiers &agrave; copier peuvent &ecirc;tre plac&eacute;s dans un
 * dossier avec un chemin particulier qui ne doit pas &ecirc;tre pris en
 * compte dans la construction des chemins des images. Ce chemin initial
 * non copi&eacute; est la "racine".<br/>
 * Exemples (template.xhtml et rsrc/template.xhtml sont des fichiers et web est
 * un dossier dans le r&eacute;pertoire de travail)&nbsp;:<ol>
 * <li>
 *      <ul>
 *          <li>fichier="template.xhtml"</li>
 *      </ul>
 *      Copie le fichier template.xhtml du plug-in &agrave; la
 *      racine du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="template.xhtml"</li>
 *          <li>destination="web/"</li>
 *      </ul>
 *      Copie le fichier template.xhtml du plug-in dans le dossier
 *      web du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="rsrc/template.xhtml"</li>
 *          <li>destination="web/template.xhtml"</li>
 *      </ul>
 *      Copie le fichier template.xhtml du dossier rsrc du plug-in dans le
 *      dossier web du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="web/template.xhtml"</li>
 *      </ul>
 *      Copie le fichier template.xhtml du dossier web du plug-on dans le
 *      dossier web du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="template.xhtml"</li>
 *          <li>racine="rsrc"</li>
 *          <li>destination="web/"</li>
 *      </ul>
 *      Copie le fichier template.xhtml du plug-in dans le dossier
 *      web du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="web"</li>
 *          <li>destination="web/"</li>
 *      </ul>
 *      Copie le dossier web du plug-in dans le dossier
 *      web du projet cr&eacute;&eacute;
 * </li>
 * <li>
 *      <ul>
 *          <li>fichier="web"</li>
 *      </ul>
 *      Copie le dossier web du dossier de travail dans le dossier
 *      web du projet cr&eacute;&eacute;
 * </li>
 * </ol>
 *
 * @author jldeleage
 */
public class Copieur extends TransformationAbstraite implements Transformation {


    /**
     * Nouvelle version utilisant un chargeur de ressources.
     * 
     * @param doc
     * @return
     * @throws ExceptionTransformation 
     */
    @Override
    public Document transforme(Document doc) throws ExceptionTransformation {
        Logger logger = Logger.getLogger("");
//        logger.log(Level.INFO, "Copie de fichiers");
        if (chargeur == null) {
//            Logger logger = Logger.getLogger("");
//            logger.log(Level.WARNING, "Impossible de copier {0}", this.nomFichier);
            return doc;
        }

        // 1- Déterminer la source effective dans le plug-in
        if (nomFichier == null) {
            nomFichier = "";
        }
        String nomEffectif = nomFichier;
        if (racine != null && racine.length() > 0) {
            if (!racine.endsWith("/")) {
                racine += '/';
            }
            nomEffectif = racine + nomFichier;
        }

//        logger.log(Level.INFO, "fichier copi\u00e9 : {0}", nomEffectif);
        try {
            // 2 Déterminer si la source est un dossier ou un simple fichier
//            logger.log(Level.INFO,"Verification de la nature de la destination de la source");
            boolean sourceIsDossier = chargeur.isDirectory(nomEffectif);
            if (! sourceIsDossier && (nomFichier==null || nomFichier.length()==0) ) {
                sourceIsDossier = true;
            }

            // 3 Déterminer si la destination est un dossier ou un simple fichier
//            logger.log(Level.INFO, "Verification de la nature de la destination de la copie");
            if (cible == null || cible.length() == 0) {
                cible = "";
            }
            boolean destinationIsDossier = cible.endsWith("/");
            if (sourceIsDossier && ! destinationIsDossier) {
                destinationIsDossier = true;
                cible += "/";
            }


//            logger.log(Level.INFO, "Récupération du dossier du projet cible");
            if (! dossierDestinationGenerale.endsWith("/")) {
                dossierDestinationGenerale += '/';
            }
//            logger.log(Level.INFO, "Détermination de copie simple ou récursive");
//            logger.log(Level.INFO, "Détermination de copie simple ou récursive");
            if (sourceIsDossier) {
//                logger.log(Level.INFO, "Déclenchement de la copie récursive");
                copieRecursive(nomEffectif, dossierDestinationGenerale + cible);
            }
            else {
//                logger.log(Level.INFO, "Déclenchement de la copie simple");
                copieSimple(nomEffectif, dossierDestinationGenerale + cible);
            }
        } catch (IOException ex) {
            logger.log(Level.INFO, "Impossible d'effectuer la copie de " + nomEffectif + " : " + ex);
            throw new ExceptionTransformation(ex);
        }

        return doc;
    }


    protected void copieRecursive(String nomDossierSource, String nomDossierCible) throws IOException {
//        Logger logger = Logger.getLogger("");
//        logger.log(Level.INFO, "Copie récursive de " + nomDossierSource + " vers " + nomDossierCible);
        Iterable<String> contenu = chargeur.getNames(nomDossierSource);
        File dossierCible = new File(nomDossierCible);
        dossierCible.mkdirs();
        if (!nomDossierCible.endsWith("/")) {
            nomDossierCible += "/";
        }
        if (!nomDossierSource.endsWith("/")) {
            nomDossierSource += '/';
        }
        for (String name : chargeur.getNames(nomDossierSource)) {
            String nomComplet = nomDossierSource + name;
            if (chargeur.isDirectory(nomComplet)) {
//                logger.log(Level.INFO, "continuation récursive de " + nomComplet + " vers " + nomDossierCible + name);
                copieRecursive(nomComplet, nomDossierCible + name);
            }
            else {
//                logger.log(Level.INFO, "copie simple de " + nomComplet + " vers " + nomDossierCible);
                copieSimple(nomComplet, nomDossierCible);
            }
        }
    }


    protected void copieSimple(String nomFichierSource, String nomFichierOuDossierCible) throws IOException {
        String nomEffectif = nomFichierSource;
        File fichierOuDossierCible = new File(nomFichierOuDossierCible);
        fichierOuDossierCible.mkdirs();
        if (fichierOuDossierCible.isDirectory()) {
            int dernierIndice = nomFichierSource.lastIndexOf("/");
            String nomSimple = nomFichierSource.substring(dernierIndice + 1);
            fichierOuDossierCible = new File(fichierOuDossierCible, nomSimple);
        }
        InputStream input = null;
        try {
            Logger logger = Logger.getLogger("");
            logger.log(Level.INFO, "Copie du fichier " + nomFichierSource + " vers " + nomFichierOuDossierCible);
            input = chargeur.getResource(nomEffectif);
            copieSimple(input, fichierOuDossierCible);
        }
        finally {
            input.close();
        }
    }


    protected void copieSimple(InputStream input, File cible) throws IOException {
        // Copie par paquets de 10ko
        byte[] buffer = new byte[10240];
        OutputStream output = new FileOutputStream(cible);
        int    nbOctets;
        do {
            nbOctets = input.read(buffer);
            if (nbOctets <= 0) {
                break;
            }
            output.write(buffer, 0, nbOctets);
        } while (nbOctets > 0);
        output.flush();
        output.close();
    }





    @Override
    public void setParameter(String nomParametre, String valeur) {
        if ("fichier".equals(nomParametre)) {
            nomFichier = valeur;
        }
        else if ("destination".equals(nomParametre)) {
            cible = valeur;
        }
        else if ("dossier_cible".equals(nomParametre)) {
            dossierDestinationGenerale = valeur;
        }
        else if ("racine".equals(nomParametre)) {
            racine = valeur;
        }
    }


    @Override
    public void setParametres(Map<String, String> inParametres) {
        for (String nomParametre : inParametres.keySet()) {
            setParameter(nomParametre, inParametres.get(nomParametre));
        }
    }
    

    @Override
    public String getNomTransfo() {
        return "Copieur de " + nomFichier;
    }


    @Override
    public void setChargeurRessource(ChargeurRessource inChargeur) {
        chargeur = inChargeur;
    }

    private ChargeurRessource chargeur;


    /**
     * Le nom du fichier &agrave; copier. Ce nom peut &ecirc;tre en fait un
     * chemin.<br/>
     */
    private String nomFichier;

    /**
     * Emplacement o&ugrave; copier le fichier. Si cet emplacement n'est
     * pas d&eacute;fini (null) le fichier est copi&eacute; dans un emplacement
     * semblable &agrave; son chemin &agrave; partir de la racine du projet
     * cible. Exemple&#160;:<ul>
     * <li>nomFichier = "web/WEB-INF/web.xml" et cible = null<br/>
     * le fichier est copi&eacute; dans web/WEB-INF/web.xml
     * </li>
     * <li>nomFichier = "deployment-descriptor.txt" et
     * cible="web/WEB-INF/web.xml<br/>
     * le fichier es aussi copi&eacute; dans web/WEB-INF/web.xml</li>
     * <li>nomFichier = "WEB-INF/web.xml" et cible="web/"<br/>
     * le fichier est encore copi&eacute; au m&ecirc;me emplacement
     * </ul>
     */
    private String cible;

    private String dossierDestinationGenerale;

    private String racine = "";

}   // Copieur
