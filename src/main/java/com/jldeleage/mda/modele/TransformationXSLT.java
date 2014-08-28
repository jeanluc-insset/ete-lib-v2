/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.jldeleage.mda.modele;


import com.jldeleage.mda.util.Lecteur;
import com.jldeleage.util.ChargeurRessource;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;

/**
 *
 * @author jldeleage
 */
public class TransformationXSLT extends TransformationAbstraite implements Transformation {


    final static String
            PROP="javax.xml.transform.TransformerFactory";
    final static String
            SAXON="net.sf.saxon.TransformerFactoryImpl";


    public TransformationXSLT() {
        Logger.getLogger(getClass().getName()).setUseParentHandlers(true);
    }

    public TransformationXSLT(InputStream inFeuille) throws ExceptionTransformation {
        Logger.getLogger(getClass().getName()).setUseParentHandlers(true);
        setFeuille(inFeuille);
    }

    public void setFeuille(String inNomFichierFeuille) throws ExceptionTransformation, IOException {
        nomFeuille = inNomFichierFeuille;
//        try {
//            setFeuille(new File(inNomFichierFeuille));
//        } catch (FileNotFoundException ex) {
////            setFeuille(getClass().getResourceAsStream(inNomFichierFeuille));
        InputStream input = null;
        if (chargeurRessource != null) {
            input = chargeurRessource.getResource(inNomFichierFeuille);
        }
        else {
            input = new Lecteur().getFichier(inNomFichierFeuille, this);
        }
        setFeuille(input);
//        }
    }

//    public void setFeuille(File inFichierFeuille)
//            throws ExceptionTransformation, FileNotFoundException {
//        setFeuille(new FileInputStream(inFichierFeuille));
//    }

    public void setFeuille(InputStream inFeuille) throws ExceptionTransformation {
        try {
            System.setProperty(PROP, SAXON);
            TransformerFactory factory = TransformerFactory.newInstance();
            templates = factory.newTemplates(new StreamSource(inFeuille));
        } catch (TransformerConfigurationException ex) {
            Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }

    @Override
    public Document transforme(Document doc) throws ExceptionTransformation {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document resultat = builder.newDocument();
            Source s = new DOMSource(doc);
            Result r = new DOMResult(resultat);
            if (templates == null) {
                setFeuille(nomFeuille);
            }
            Transformer tr = templates.newTransformer();
            Map<String, String> parametres = getParametres();
            if (parametres != null) {
                for (String nomParam : parametres.keySet()) {
                    String valeurParam = parametres.get(nomParam);
                    tr.setParameter(nomParam, valeurParam);
                }
            }
            tr.transform(s, r);
            return resultat;
        } catch (Exception ex) {
            Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }


    public void setParameter(String nomParametre, String valeur) {
        if ("feuille".equals(nomParametre)) {
            try {
                setFeuille(valeur);
            } catch (IOException ex) {
                Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
            } catch (ExceptionTransformation ex) {
                Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        else {
            super.setParameter(nomParametre, valeur);
        }
    }

//    public void setParametres(Map<String, String> inParametres) {
//        parametres = inParametres;
//    }

    public String getNomTransfo() {
        return nomFeuille;
    }


    public String toString() {
        return nomFeuille;
    }

    @Override
    public void setChargeurRessource(ChargeurRessource inClassLoader) {
        chargeurRessource = inClassLoader;
    }

    private ChargeurRessource chargeurRessource;
    private Templates templates;
//    private Map<String, String> parametres;
    private String nomFeuille;


}
