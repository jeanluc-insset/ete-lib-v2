package com.jldeleage.mda.modele;

import com.jldeleage.mda.util.Dump;
import com.jldeleage.mda.util.Lecteur;
import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;

/**
 * Lit un template et le transforme en une feuille XSLT.<br/>
 * Cette feuille est ensuite appliqu&eacute;e au mod&egrave; pour produire
 * le(s) r&eacute;sultat(s)
 *
 * @author jldeleage
 */
public class ApplicateurTemplateNonXml extends TransformationAbstraite
                                       implements Transformation {

    final static String
            PROP="javax.xml.transform.TransformerFactory";
    final static String
            SAXON="net.sf.saxon.TransformerFactoryImpl";



    public ApplicateurTemplateNonXml() {
        
    }


    /**
     * Lit un template et le transforme en une feuille XSLT.<br/>
     * Cette feuille est ensuite appliqu&eacute;e au mod&egrave; pour produire
     * le(s) r&eacute;sultat(s)
     *
     * @param template
     */
    public ApplicateurTemplateNonXml(InputStream template) throws ExceptionTransformation {
        this(template, new HashMap<String, String>());
    }


    public ApplicateurTemplateNonXml(InputStream template, Map<String, String>parametres) throws ExceptionTransformation {
        try {
            this.parametres = parametres;

            System.setProperty(PROP, SAXON);
            TransformerFactory factory = TransformerFactory.newInstance();
            // A REVOIR : injection de dépendances ?
//            System.out.println(new File(".").getAbsolutePath());
//            File dossier = new File("src/java/rsrc");
//            File[] contenu = dossier.listFiles();
//            for (int i=0 ; i<contenu.length ; i++) {
//                System.out.println("   " + contenu[i].getAbsolutePath());
//            }
            InputStream feuille
//                = getClass().getResourceAsStream("/rsrc/xslt/template2xslt.xsl");
//                = new FileInputStream("src/java/rsrc/xslt/template2xslt.xsl");
                = new Lecteur().getFichier("rsrc/xslt/template2xslt.xsl", this);
            Transformer template2xslt
                = factory.newTransformer(new StreamSource(feuille));

            // Resultat intermédiaire : la feuille XSLT générée à partir du template
            DocumentBuilderFactory fact2 = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = fact2.newDocumentBuilder();
            Document resultat = builder.newDocument();

            for (String nomParam : parametres.keySet()) {
                template2xslt.setParameter(nomParam, parametres.get(nomParam));
            }
            template2xslt.transform(new StreamSource(template), new DOMResult(resultat));
            //
            Dump dumper = new Dump();
            dumper.dump(resultat, "intermediaire.xsl");

            templates = factory.newTemplates(new DOMSource(resultat));
        } catch (Exception ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }


    protected void setTemplate(String inNomTemplate)
                        throws ExceptionTransformation {
        nomTemplate = inNomTemplate;
        try {
            InputStream input = new FileInputStream(inNomTemplate);
            setTemplate(input);
            return;
        } catch (FileNotFoundException ex) {
        }
//        setTemplate(getClass().getResourceAsStream(inNomTemplate));
        setTemplate(new Lecteur().getFichier(inNomTemplate, templates));
    }


    protected void setTemplate(File inFichierTemplate) throws ExceptionTransformation {
        try {
            setTemplate(new FileInputStream(inFichierTemplate));
        } catch (FileNotFoundException ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (ExceptionTransformation ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }


    protected void setTemplate(InputStream inTemplate) throws ExceptionTransformation {
        InputStream feuille = null;
        try {
            System.setProperty(PROP, SAXON);
            TransformerFactory factory = TransformerFactory.newInstance();
            feuille = new Lecteur().getFichier("rsrc/xslt/template2xslt.xsl", this);
//            feuille = new FileInputStream("src/java/rsrc/xslt/template2xslt.xsl");
            Transformer template2xslt = factory.newTransformer(new StreamSource(feuille));
            // Resultat intermédiaire : la feuille XSLT générée à partir du template
            DocumentBuilderFactory fact2 = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = fact2.newDocumentBuilder();
            Document resultat = builder.newDocument();
            for (String nomParam : parametres.keySet()) {
                template2xslt.setParameter(nomParam, parametres.get(nomParam));
            }
            template2xslt.transform(new StreamSource(inTemplate), new DOMResult(resultat));
            //
            Dump dumper = new Dump();
            dumper.dump(resultat, "intermediaire.xsl");
            templates = factory.newTemplates(new DOMSource(resultat));
        } catch (TransformerConfigurationException ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (TransformerException ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } finally {
            try {
                feuille.close();
            } catch (IOException ex) {
                Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }


    public Document transforme(Document doc) throws ExceptionTransformation {
        try {
            setTemplate(nomTemplate);
            DocumentBuilderFactory fact2 = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = fact2.newDocumentBuilder();
            Document resultat = builder.newDocument();
            Transformer transformer = templates.newTransformer();
            for (String nomParam : parametres.keySet()) {
                transformer.setParameter(nomParam, parametres.get(nomParam));
            }
            transformer.transform(new DOMSource(doc), new DOMResult(resultat));
            return resultat;
        } catch (Exception ex) {
            Logger.getLogger(ApplicateurTemplateNonXml.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }


//    public void setParam(String name, String value) {
//        setParameter(name, value);
//    }


    public void setParameter(String nomParametre, String valeur) {
        if ("feuille".equals(nomParametre)) {
            try {
                setTemplate(valeur);
            } catch (ExceptionTransformation ex) {
                Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        else {
            if (parametres == null) {
                parametres = new HashMap<String, String>();
            }
            parametres.put(nomParametre, valeur);
        }
    }


    public void setParametres(Map<String, String> inParametres) {
        parametres = inParametres;
    }

    public String getNomTransfo() {
        return nomTemplate;
    }


    @Override
    public void setChargeurRessource(ChargeurRessource inChargeur) {
        chargeur = inChargeur;
    }

    private ChargeurRessource chargeur;

    private Templates           templates;
    private String              nomTemplate;
    private Map<String, String> parametres = new HashMap<String, String>();


}

