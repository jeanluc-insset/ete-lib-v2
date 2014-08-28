/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.jldeleage.mda.util;

import com.jldeleage.mda.modele.ExceptionTransformation;
import com.jldeleage.mda.modele.TransformationAbstraite;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;

/**
 * Copie un document XML vers un flot (par exemple la console ou un fichier)
 *
 * @author jldeleage
 */
public class Dump extends TransformationAbstraite{

    public Dump() throws ExceptionTransformation {
        try {
//            Source identite = new StreamSource(Dump.class.getResourceAsStream("/rsrc/xslt/identite.xsl"));
            Source identite = new StreamSource(new Lecteur().getFichier("/rsrc/xslt/identite.xsl", this));
            TransformerFactory factory = TransformerFactory.newInstance();
            templates = factory.newTemplates(identite);
        } catch (TransformerConfigurationException ex) {
            Logger.getLogger(Dump.class.getName()).log(Level.SEVERE, "Impossible d'effectuer le \"dump\" de " + message, ex);
            throw new ExceptionTransformation(ex);
        }
    }

    public void dump(Document doc, OutputStream out) throws ExceptionTransformation {
        try {
            StreamResult resultat = new StreamResult(out);
            Transformer transformer = templates.newTransformer();
            DOMSource source = new DOMSource(doc);
            transformer.setParameter("message", message);
            transformer.transform(source, resultat);
            out.flush();
        } catch (Exception ex) {
            Logger.getLogger(Dump.class.getName()).log(Level.SEVERE, "Impossible d'effectuer le \"dump\" de " + message, ex);
            throw new ExceptionTransformation(ex);
        }
    }

    public void dump(Document doc) throws ExceptionTransformation {
        dump(doc, System.out);
    }

    public void dump(File doc, String out) throws ExceptionTransformation {
        try {
            dump(doc, new FileOutputStream(out));
        } catch (FileNotFoundException ex) {
            Logger.getLogger(Dump.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }

    public void dump(Document doc, File dump)
                throws FileNotFoundException, ExceptionTransformation {
        dump(doc, new FileOutputStream(dump));
    }

    public void dump(File doc, OutputStream out) throws ExceptionTransformation {
        try {
            StreamResult resultat = new StreamResult(out);
            Transformer transformer = templates.newTransformer();
            Source source = new StreamSource(doc);
            transformer.setParameter("message", message);
            transformer.transform(source, resultat);
            out.flush();
        } catch (Exception ex) {
            Logger.getLogger(Dump.class.getName()).log(Level.SEVERE, "Impossible d'effectuer le \"dump\" de " + message, ex);
            throw new ExceptionTransformation(ex);
        }
    }
    public void dump(Document doc, String nomFichier) throws ExceptionTransformation {
        try {
//            Logger logger = Logger.getLogger("");
//            logger.log(Level.INFO, "dump.dump de " + nomFichier);
            dump(doc, new FileOutputStream(nomFichier));
//            logger.log(Level.INFO, "dump OK");
        } catch (Exception ex) {
            Logger.getLogger(Dump.class.getName()).log(Level.SEVERE, "Impossible d'effectuer le \"dump\" de " + nomFichier, ex);
            throw new ExceptionTransformation(ex);
        }
    }


    public void setMessage(String nomTransfo) {
        message = nomTransfo;
    }

    public Document transforme(Document doc) throws ExceptionTransformation {
        try {
//            Logger.getLogger(getClass().getName()).info(
//                        "Dump de " + doc);
//            TransformerFactory factory = TransformerFactory.newInstance();
//            InputStream streamIdentite = getClass().getResourceAsStream("/rsrc/xslt/identite.xsl");
//            Source source = new StreamSource(streamIdentite);
//            Logger.getLogger(getClass().getName()).info(
//                        "XSLT dy dump OK ");
//            Transformer transformer = factory.newTransformer(source);
//            Logger.getLogger(getClass().getName()).info(
//                        "Transformer du dump OK ");
            dump(doc);
        }
        catch (Exception e) {
            Logger.getLogger(getClass().getName()).severe(
                        "Impossible d'effectuer le dump de " + doc);
        }
        return doc;
    }

    public String getNomTransfo() {
        return "dump";
    }



    private Templates templates;
    private String    message;

}
