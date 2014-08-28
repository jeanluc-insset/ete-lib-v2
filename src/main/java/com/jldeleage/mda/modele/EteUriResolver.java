/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.jldeleage.mda.modele;

import com.jldeleage.mda.util.JarURIResolver;
import static com.jldeleage.mda.util.JarURIResolver.niveau;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

/**
 *
 * @author jldeleage
 */
class EteUriResolver implements URIResolver {


    @Override
    public Source resolve(String href, String base) throws TransformerException {
        File tempDir = new File(System.getProperty("java.io.tmpdir"));
        tempDir = new File(tempDir, "ete");
        Source resultat = null;

        // 1- TODO : Recherche dans les préférences de l'utilisateur
        // 2- TODO : Recherche dans le dossier de travail
        // 3- TODO : Recherche dans les ressources
        try {
            resultat = resolutionInterne(href);
        } catch (Exception ex) {
            // L'exception n'est pas gênante
        }
        if (resultat == null) {
            resultat = resolutionInterne(racine + href);
        }

        if (resultat != null) {
            TransformerFactory factory2 = TransformerFactory.newInstance();
            InputStream feuilleIdentite = getClass().getResourceAsStream("/rsrc/xslt/identite.xsl");
            Transformer identite = factory2.newTransformer(new StreamSource(feuilleIdentite));
            identite.transform(resultat, new StreamResult(new File(tempDir, href)));
            return resultat;
        }
        throw new TransformerException("Ressource introuvable: " + href + " dans " + base);
    }


    protected Source _resolve(String href, String base) throws TransformerException {
        return null;
    }

    protected Source resolutionInterne(String href) throws TransformerException {
//        Logger logger = Logger.getLogger(getClass().getName());
//        logger.log(niveau, "    resolution de {0}...", href);
        ClassLoader cl = getClass().getClassLoader();
        InputStream in = cl.getResourceAsStream(href);
//        logger.log(niveau, "    stream : " + in);
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        try {
            DocumentBuilder documentBuilder = factory.newDocumentBuilder();
            Document doc = documentBuilder.parse(in);
            DOMSource resultat = new DOMSource(doc);
            resultat.setSystemId(href);
//            logger.log(niveau, "...resolution de {0} OK", href);
            return resultat;
        } catch (ParserConfigurationException | SAXException | IOException ex) {
            Logger.getLogger(JarURIResolver.class.getName()).log(Level.SEVERE, "Resolution ratee de " + href, ex);
        }
        return null;
    }

    public String getRacine() {
        return racine;
    }

    public void setRacine(String racine) {
        this.racine = racine;
    }

    private String      racine;


}
