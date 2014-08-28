package com.jldeleage.mda.modele;


import com.jldeleage.mda.modele.ExceptionTransformation;
import com.jldeleage.mda.modele.Transformation;
import com.jldeleage.mda.util.Dump;
import com.jldeleage.mda.util.Lecteur;
import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;



/**
 * Un Pipeline est l'encha&icirc;nement de plusieurs Transformations.<br/>
 * Il transmet &agrave; chaque Transformation qu'il contient les
 * param&egrave;tres qu'il a re&ccedil;us.
 *
 * @author jldeleage
 */
public class Pipeline extends TransformationAbstraite implements Transformation {

    public Pipeline() {
        Logger.getLogger(getClass().getName()).setUseParentHandlers(true);
    }

    /**
     * M&eacute;thode pour faciliter l'utilisation de la classe.<br/>
     * Encapsule l'appel standard <code>transform(d:Document):Document</code>
     * TODO : envoyer la trace vers un autre dossier que le dossier cible.
     *
     * @param inSource
     * @param inoutCible
     * @throws ExceptionTransformation
     */
    public void transforme(File inSource, File inoutCible) throws ExceptionTransformation {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        Logger logger = Logger.getLogger("");
        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            logger.log(Level.INFO, "Chargement du fichier source : " + inSource);
            Document source = builder.parse(inSource);            
            logger.log(Level.INFO, "Chargement du dossier cible : " + inoutCible);
            Document resultat = transforme(source);
            // Le résultat devrait être gardé quelque part. Il peut contenir
            // des informations sur la transformation
            // En théorie c'est le modèle initial enrichi par les
            // transformations…
            File tempDir = new File(System.getProperty("java.io.tmpdir"));
            File dossierTraces = new File(tempDir, "ete/traces");
            dossierTraces.mkdirs();
            TransformerFactory factory2 = TransformerFactory.newInstance();
            InputStream identite = new Lecteur().getFichier("/rsrc/xslt/identite.xsl", this);
            Transformer transformer = factory2.newTransformer(new StreamSource(identite));
            String nomFichier = inoutCible.getAbsolutePath() + "/trace.xml";
            inoutCible = new File(nomFichier);
            transformer.transform(new DOMSource(resultat), new StreamResult(inoutCible));
        } catch (TransformerConfigurationException ex) {
            Logger.getLogger(Pipeline.class.getName()).log(Level.SEVERE, "TransformerConfigurationException", ex);
            throw new ExceptionTransformation(ex);
        } catch (TransformerException ex) {
            Logger.getLogger(Pipeline.class.getName()).log(Level.SEVERE, "ExceptionTransformation", ex);
            throw new ExceptionTransformation(ex);
        } catch (SAXException ex) {
            Logger.getLogger(Pipeline.class.getName()).log(Level.SEVERE, "SAXException", ex);
            throw new ExceptionTransformation(ex);
        } catch (IOException ex) {
            Logger.getLogger(Pipeline.class.getName()).log(Level.SEVERE, "IOException", ex);
            throw new ExceptionTransformation(ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(Pipeline.class.getName()).log(Level.SEVERE, "ParserConfigurationException", ex);
            throw new ExceptionTransformation(ex);
        }
    }


    @Override
    public Document transforme(Document doc) throws ExceptionTransformation {
        Logger logger = Logger.getLogger("");
        Document courant = doc;
        Dump dumper = new Dump();
        int i=0;
        Map<String, String> parametres = getParametres();
        for (Transformation t : transformations) {
            notifieListenersDebut(t);
            if (arret) {
                // NOtidier les listeners..
                break;
            }
            if (parametres != null) {
                t.setParametres(parametres);
            }
            try {
                // TODO : paramétrer la génération de la trace
                dumper.setMessage(t.getNomTransfo());
                File tempDir = new File(System.getProperty("java.io.tmpdir"));
                File dossierTraces = new File(tempDir, "traces");
                dossierTraces.mkdirs();
//                System.out.println("Dossier de traces : " + dossierTraces.getAbsolutePath());
                File fichierTrace = new File(dossierTraces, "intermediaire_" + i + ".xml");
                dumper.dump(courant, fichierTrace.getAbsolutePath());
            }
            catch (Exception e) {
                logger.log(Level.INFO, "    impossible d'effectuer le dump", e);
            }
            i++;
            Logger.getLogger(getClass().getName()).log(Level.INFO, "Lancement de " + t.getNomTransfo() + "...");
            courant = t.transforme(courant);
            Logger.getLogger(getClass().getName()).log(Level.INFO, t.getNomTransfo() + " OK");
        }
        Logger.getLogger(getClass().getName()).log(Level.INFO, "Fin des transformations");
        dumper.dump(courant, "trace/intermediaire_" + i + ".xml");
        return courant;
    }


    public void ajouteTransformation(Transformation t) {
        transformations.add(t);
    }


//    public void setParameter(String nomParametre, String valeur) {
//        parametres.put(nomParametre, valeur);
//    }


//    public void setParametres(Map<String, String> inParametres) {
//        parametres = inParametres;
//    }


    @Override
    public String getNomTransfo() {
        return "Pipeline";
    }


    @Override
    public void setChargeurRessource(ChargeurRessource inChargeur) {
        chargeur = inChargeur;
    }


    public int getSize() {
        return transformations.size();
    }


    //========================================================================//
    //                         P A R A L E L L I S M E                        //
    //========================================================================//


    public void stoppe() {
        arret = true;
    }


    public void addListener(TransformationListener inListener) {
        listeners.add(inListener);
    }


    public void removeListener(TransformationListener inListener) {
        listeners.remove(inListener);
    }


    private void notifieListenersDebut(Transformation transformation) {
        for (TransformationListener listener : listeners) {
            listener.transformationStarted(transformation);
        }
    }



    //========================================================================//
    //                 V A R I A B L E S   D ' I N S T A N C E                //
    //========================================================================//


    private boolean              arret;
    private ChargeurRessource    chargeur;
    private List<Transformation> transformations = new LinkedList<Transformation>();
//    private Map<String, String>  parametres = new HashMap<String, String>();

    private Collection<TransformationListener> listeners = new LinkedList<TransformationListener>();


}
