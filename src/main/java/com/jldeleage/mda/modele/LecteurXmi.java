/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import com.jldeleage.mda.util.JarURIResolver;
import com.jldeleage.mda.util.Dump;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

/**
 *
 * @author jldeleage
 */
public class LecteurXmi {

    public Document lisXmi(String inNomFichier) throws FileNotFoundException, ParserConfigurationException, SAXException, IOException, TransformerConfigurationException, TransformerException, ExceptionTransformation {
        return lisXmi(new File(inNomFichier));
    }

    public Document lisXmi(File inFichier) throws FileNotFoundException, ParserConfigurationException, SAXException, IOException, TransformerConfigurationException, TransformerException, ExceptionTransformation {
        return lisXmi(new FileInputStream(inFichier));
    }

    public Document lisXmi(InputStream inStream) throws ParserConfigurationException, SAXException, IOException, TransformerConfigurationException, TransformerException, ExceptionTransformation {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(inStream);
        TransformerFactory f2 = TransformerFactory.newInstance();
        JarURIResolver jarURIResolver = new JarURIResolver();
        jarURIResolver.setRacine("rsrc/xslt/");
        f2.setURIResolver(jarURIResolver);
        InputStream ressource = getClass().getResourceAsStream("/rsrc/xslt/lecture.xsl");
        Transformer tr = f2.newTransformer(new StreamSource(ressource));
        Document resultat = builder.newDocument();
        tr.transform(new DOMSource(doc), new DOMResult(resultat));
        return resultat;
    }

}
