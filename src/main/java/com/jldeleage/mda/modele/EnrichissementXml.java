/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import com.jldeleage.mda.modele.ExceptionTransformation;
import com.jldeleage.mda.modele.Transformation;
import com.jldeleage.mda.util.Lecteur;
import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Result;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

/**
 * Enrichit un document XML d&eacute;j&eagrave; pr&eacute;sent dans les
 * fichiers copi&eacute;s.<br/>
 * Si ce fichier n'est pas pr&eacute;sent, le cr&eacute;e en copiant un
 * mod&egrave;le.<br/>
 * Param&egrave;tres&#160;:<ul>
 *  <li>feuille : template d'enrichissement</li>
 *  <li>fichier : chemin relatif &agrave; la cible du fichier &agrave; enrichir</li>
 *  <li>defaut (optionnel) : chemin relatif au programme du fichier &agrave;
 *  copier si le fichier cible n'existe pas</li>
 *  <li>modele : chemin relatif au programme du mod&egrave;ve de fichier
 *  &agrave; g&eacnte;n&eacute;rer. Le mod&egrave;ve permet de trouver les
 *  emplacements o&ugrave; copier les nouveaux &eacute;l&eacute;ments.</li>
 * </ul>
 *
 * @author jldeleage
 */
public class EnrichissementXml extends TransformationAbstraite implements Transformation {

    final static String
            PROP="javax.xml.transform.TransformerFactory";
    final static String
            SAXON="net.sf.saxon.TransformerFactoryImpl";


    /**
     * <ol>
     * <li>transforme le template en une feuille de transformation</li>
     * <li>lit le document XML &agrave; enrichir pour le garder sous forme
     * de DOM</li>
     * <li>applique la transformation sur le DOM et envoie le r&eacute;sultat
     * dans le fichier qu'il a lu</li>
     * </ol>
     */
    @Override
    public Document transforme(Document xmi) throws ExceptionTransformation {
        // 1-a Préparer un document pour contenir la feuille de transformation
        DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = null;
        try {
            builder = domFactory.newDocumentBuilder();
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(EnrichissementXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
        Document feuilleDOM = builder.newDocument();

        // 1-b  Lire le template
        System.setProperty(PROP, SAXON);
        Lecteur lecteur = new Lecteur();
        InputStream feuilleStream = lecteur.getFichier(nomTemplate, this);

        // 1-c  Transformer le template en feuille de transformation
        TransformerFactory factory = TransformerFactory.newInstance();
        Transformer transformer = null;
        try {
            transformer
                    = factory.newTransformer(new StreamSource(
                        lecteur.getFichier("rsrc/xslt/ajout.xsl", this)));
            transformer.transform(new StreamSource(feuilleStream),
                    new StreamResult(new File("feuille_intermediaire.xsl")));
            transformer = factory.newTransformer(new StreamSource("feuille_intermediaire.xsl"));
        } catch (Exception ex) {
            Logger.getLogger(EnrichissementXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }

        // 1-d- Passer les paramètres à la nouvelle feuille
        Map<String, String> parametres = getParametres();
        for (String clef : parametres.keySet()) {
            transformer.setParameter(clef, parametres.get(clef));
        }

        // 2- Charger le document à transformer sous forme de DOM.
        // Si le document n'est pas déjà présent, le créer.
        Document aEnrichir;
        try {
            aEnrichir = builder.parse(new File(nomFichier));
        }
        catch (Exception e) {
            try {
                // Si le paramètre "defaut" n'a pas été fourni, il faut
                // prendre un fichier homonyme (en fait, de même chemin
                // relatif) soit dans l'archive, soit à partir du
                // dossier de travail
                if (nomFichierParDefaut == "" || nomFichierParDefaut == null) {
                    nomFichierParDefaut = nomFichier;
                }
                InputStream input = lecteur.getFichier(nomFichierParDefaut, this);
                aEnrichir = builder.parse(getClass().getResourceAsStream(""));
            } catch (SAXException ex) {
                Logger.getLogger(EnrichissementXml.class.getName()).log(Level.SEVERE, null, ex);
                throw new ExceptionTransformation(ex);
            } catch (IOException ex) {
                Logger.getLogger(EnrichissementXml.class.getName()).log(Level.SEVERE, null, ex);
                throw new ExceptionTransformation(ex);
            }
        }

        // 3- Appliquer la feuille au document
        // Le résultat est écrit dans le fichier initial ou créé à cet
        // emplacement si ce fichier n'existait pas
        Result resultat = new StreamResult(nomFichier);
        try {
            transformer.transform(new DOMSource(aEnrichir), resultat);
        } catch (TransformerException ex) {
                throw new ExceptionTransformation(ex);
        }

        return xmi;
    }


    @Override
    public void setParameter(String nomParametre, String valeur) {
        if ("template".equals(nomParametre)) {
            nomTemplate = valeur;
            return;
        }
        if ("fichier".equals(nomParametre)) {
            nomFichier = valeur;
            return;
        }
        if ("defaut".equals(nomParametre)) {
            nomFichierParDefaut = valeur;
            return;
        }
//        if (parametres == null) {
//            parametres = new HashMap<String, String>();
//        }
        super.setParameter(nomParametre, valeur);
//        parametres.put(nomParametre, valeur);
    }


//    @Override
//    public void setParametres(Map<String, String> inParametres) {
//        for (String clef : inParametres.keySet()) {
//            setParameter(clef, inParametres.get(clef));
//        }
//    }


    @Override
    public String getNomTransfo() {
        return "Enrichissement : " + nomTemplate;
    }


    @Override
    public void setChargeurRessource(ChargeurRessource inChargeur) {
        chargeur = inChargeur;
    }

    private ChargeurRessource chargeur;

//    private Map<String, String> parametres;
    private String              nomTemplate;
    private String              nomFichier;
    private String              nomFichierParDefaut;

}
