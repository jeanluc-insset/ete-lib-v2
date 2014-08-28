package com.jldeleage.mda.util;


import java.io.IOException;
import java.io.InputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 *
 * @author jldeleage
 */
public class JarURIResolver implements URIResolver {

    public final static Level   niveau = Level.FINEST;

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        Logger logger = Logger.getLogger(getClass().getName());
        logger.log(niveau, "Resolution de {0} dans {1}...", new Object[]{href, racine});
        Source resolutionInterne;
        try {
            resolutionInterne = resolutionInterne(href);
        } catch (Exception ex) {
            resolutionInterne = resolutionInterne(racine + href);
        }
        if (resolutionInterne == null) {
            resolutionInterne = resolutionInterne(racine + href);
        }
        return resolutionInterne;
    }

    protected Source resolutionInterne(String href) throws TransformerException {
        Logger logger = Logger.getLogger(getClass().getName());
        logger.log(niveau, "    resolution de {0}...", href);
        ClassLoader cl = getClass().getClassLoader();
        InputStream in = cl.getResourceAsStream(href);
        logger.log(niveau, "    stream : " + in);
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        try {
            DocumentBuilder documentBuilder = factory.newDocumentBuilder();
            Document doc = documentBuilder.parse(in);
            DOMSource resultat = new DOMSource(doc);
            resultat.setSystemId(href);
            logger.log(niveau, "...resolution de {0} OK", href);
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
