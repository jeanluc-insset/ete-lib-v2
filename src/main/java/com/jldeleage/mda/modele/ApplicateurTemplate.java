package com.jldeleage.mda.modele;

import com.jldeleage.mda.util.Dump;
import com.jldeleage.mda.util.Lecteur;
import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
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
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 * Lit un template et le transforme en une feuille XSLT.<br/>
 * Cette feuille est ensuite appliqu&eacute;e au mod&egrave; pour produire
 * le(s) r&eacute;sultat(s)<br/>
 * La feuille interm&eacute;diaire est plac&eacute;e dans le dossier temporaire
 * du syst&egrave;me, ce qui facilite la gestion modulaire des templates ainsi
 * que la mise au point.
 *
 * @author jldeleage
 */
public class ApplicateurTemplate extends TransformationAbstraite
                                 implements Transformation {

    final static String
            PROP="javax.xml.transform.TransformerFactory";
    final static String
            SAXON="net.sf.saxon.TransformerFactoryImpl";
    final static String
            FEUILLE = "feuille";
    final static String
            ETE_NAMESPACE = "http://www.jldeleage.com/mda/ns/jld.html";




    /**
     * TODO :   Copier le template dans le dossier temporaire de l'utilisateur.
     * Générer tous les fichiers dans ce dossier temporaire
     * 
     * @param inURLTemplate
     * @throws ExceptionTransformation 
     */
//    public void setTemplate(URL inURLTemplate) throws ExceptionTransformation {
//        
//    }


    /**
     * Lit un template et le transforme en une feuille XSLT.<br/>
     * Cette feuille est ensuite appliqu&eacute;e au mod&egrave; pour produire
     * le(s) r&eacute;sultat(s)
     */


    public void setTemplate(String inNomTemplate)
                        throws ExceptionTransformation, MalformedURLException {
        Logger logger = Logger.getLogger(getClass().getName());
        logger.info("    setTemplate(String " + inNomTemplate + ")");
        URL urlSource = getUrlSource();
        if (urlSource == null) {
            File workingDir = new File(".");
            urlSource = workingDir.toURI().toURL();
        }
        logger.info("    url : " + urlSource);
        String path = urlSource.toString();
//        path += "templates/" + inNomTemplate;
        path += inNomTemplate;
        logger.info("    path : " + path);
        nomTemplate = path;
        logger.info("    nomTemplate = " + nomTemplate);
    }


    protected void setTemplate(File inFichierTemplate) throws ExceptionTransformation {
        try {
            // Anciennement, c'etait getAbsolutePath...
            nomTemplate = inFichierTemplate.getName();
            setTemplate(new FileInputStream(inFichierTemplate));
        } catch (FileNotFoundException ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (ExceptionTransformation ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
        }
    }


    /**
     * Transforme le template en feuille de transformation XSLT et place le
     * résultat dans le dossier temporaire
     */
    public void setTemplate(InputStream inTemplate) throws ExceptionTransformation, ParserConfigurationException, SAXException {
        InputStream feuille = null;
        Logger logger = Logger.getLogger(getClass().getName());
        try {
//            // 1- Récupération de la feuille de transformation de template
//            // vers XSLT et passage des paramètres
//            logger.finest("Mise en place de SAXON");
            System.setProperty(PROP, SAXON);
            TransformerFactory factory = TransformerFactory.newInstance();

            File resultat = copieTemplateDansTmp(inTemplate);

            // 4 Compilation des feuilles de transformation
            templates = factory.newTemplates(new StreamSource(resultat));
        } catch (TransformerConfigurationException ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } catch (TransformerException ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }   // setTemplate(InputStream is)


    /**
     * 
     */
    protected File copieTemplateDansTmp(InputStream inTemplate) throws ExceptionTransformation, ParserConfigurationException, SAXException {
        InputStream feuille = null;
        Logger logger = Logger.getLogger(getClass().getName());
        File resultat = null;
        try {
            // 1- Récupération de la feuille de transformation de template
            // vers XSLT et passage des paramètres
            logger.finest("Mise en place de SAXON");
            System.setProperty(PROP, SAXON);
            TransformerFactory factory = TransformerFactory.newInstance();
            logger.fine("SAXON OK");
            feuille = new Lecteur().getFichier("/rsrc/xslt/template2xslt.xsl", this);
            logger.finer("Lecture de la feuille template2xslt OK");
            Transformer template2xslt = factory.newTransformer(new StreamSource(feuille));
            logger.fine("transformation template -> xslt prête");
            // Paramètres statiques et paramètres déterminés par l'utilisateur.
            Map<String, String> parametres = getParametres();
            for (String nomParam : parametres.keySet()) {
                logger.info("Passage du parametre " + nomParam
                        + "=" + parametres.get(nomParam)
                        + " a la transformation du template en XSLT");
                template2xslt.setParameter(nomParam, parametres.get(nomParam));
            }
            // Racine du plug-in, pour que la feuille de transformation
            // puisse retrouver les sources
            // TODO : ne fonctionne pas avec un plug-in sous forme d'archive
//            String racine = null;
//            if (chargeur == null) {
//                racine = ".";
//            }
//            else {
//                racine = chargeur.getRacine(nomTemplate);
//            }
//            if (!racine.endsWith("/")) racine += '/';
//            template2xslt.setParameter("workingdir", racine);

            // 2 Préparation du résultat intermédiaire : la feuille XSLT
            // générée à partir du template
            File tempDir = new File(System.getProperty("java.io.tmpdir"));
            tempDir = new File(tempDir, "ete");
            tempDir.mkdirs();
            String cheminTempDir = tempDir.getAbsolutePath();
            if (! cheminTempDir.endsWith("/")) {
                cheminTempDir += "/";
            }
            // Extraction du nom du template (à l'exclusion de son chemin d'accès
            // dans le plug-in)
            if (nomTemplate == null) {
                nomTemplate = "template-anonyme";
            }
            int index = nomTemplate.lastIndexOf("/");
            resultat = new File(tempDir, nomTemplate.substring(index+1));

            // 3 Génération effective de(s) feuille(s) de transformation
            // intermédiaire
            // 3-1 la feuille du template
            logger.info("*** TRANSFORMATION TEMPLATE -> XSLT ***");
            template2xslt.setParameter("tempdir", cheminTempDir);
            template2xslt.transform(new StreamSource(inTemplate), new StreamResult(resultat));
            // 3-2 les feuilles importées
//            copieFeuillesImportees(resultat);
            
            // 4 Compilation des feuilles de transformation
            templates = factory.newTemplates(new StreamSource(resultat));
        } catch (TransformerException /* | IOException */ ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        } finally {
            try {
                if (feuille != null) {
                    feuille.close();
                }
            } catch (IOException ex) {
                Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return resultat;
    }       // copieTemplateDansTmp


    protected void copieFeuillesImportees(File inFeuille) throws ParserConfigurationException, SAXException, IOException, ExceptionTransformation {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document feuille = builder.parse(inFeuille);
        Logger logger = Logger.getLogger(getClass().getName());
        logger.info("Recherche des feuilles importees");
        NodeList importations = feuille.getElementsByTagNameNS(ETE_NAMESPACE, "import");
        for (int i=0 ; i<importations.getLength() ; i++) {
            Element unImport = (Element) importations.item(i);
            String attribute = unImport.getAttribute("href");
            logger.info("Chargement de la feuille importee " + attribute);
            copieTemplateDansTmp(new FileInputStream(attribute));
        }       // boucles sur les importations
    }       // copieFeuillesImportees

    /**
     * 
     * @param doc
     * @return
     * @throws ExceptionTransformation 
     */
    public Document transforme(Document doc) throws ExceptionTransformation {
        try {
            Map<String, String> parametres = getParametres();
            setTemplate(parametres.get("template"));
            // Pour le développement : on recharge le template (s'il y a une
            // nouvelle version, celle-ci est automatiquement prise en compte)
//            templates = null;
            Logger logger = Logger.getLogger("");
            logger.log(Level.INFO, "Transformation du template " + nomTemplate + " en XSLT..."); 
//            setTemplate(nomTemplate);
            DocumentBuilderFactory fact2 = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = fact2.newDocumentBuilder();
            Document resultat = builder.newDocument();
            if (templates == null) {
                if (chargeur == null) {
                    // Il faut charger dans le dossier de l'application
                    // Lecteur
                    chargeur = new Lecteur(this);
                }
                // TODO : normalement, le nom du template est un URL sur le
                // template, sous forme de chaîne.
                // Revoir le chargeur.
//                InputStream inputTemplate = chargeur.getResource(nomTemplate);
                URL url = new URL(nomTemplate);
                InputStream inputTemplate = url.openStream();
                setTemplate(inputTemplate);
            }
            
            Transformer transformer = templates.newTransformer();
            for (String nomParam : parametres.keySet()) {
                logger.log(Level.INFO, "passage du parametre " + nomParam
                        + "=" + parametres.get(nomParam)
                        + " a la feuille de transformation appliquee au modele");
                transformer.setParameter(nomParam, parametres.get(nomParam));
            }
//            String racine = chargeur.getRacine(nomTemplate);
            File tempDir = new File(System.getProperty("java.io.tmpdir"));
            tempDir = new File(tempDir, "ete");
            logger.log(Level.INFO, "tempDir : " + tempDir.getAbsolutePath());
            transformer.setParameter("workingdir", tempDir.getAbsolutePath());
            logger.log(Level.INFO, "Execution du template " + nomTemplate); 
            transformer.transform(new DOMSource(doc), new DOMResult(resultat));

            return resultat;
        } catch (Exception ex) {
            Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            throw new ExceptionTransformation(ex);
        }
    }



    public void setParameter(String nomParametre, String valeur) {
        System.out.print(nomParametre + "=" + valeur);
//        if (parametres == null) {
//            parametres = new HashMap<String, String>();
//        }
        if (FEUILLE.equals(nomParametre)) {
//            try {
                URL urlSource = this.getUrlSource();
                String path = urlSource.toString();
                path += "/" + valeur;
                Logger.getLogger(getClass().getName()).log(Level.INFO, "    URL du template : " + path);
//                setTemplate(path);
//                parametres.put(FEUILLE, valeur);
//            } catch (ExceptionTransformation ex) {
//                Logger.getLogger(TransformationXSLT.class.getName()).log(Level.SEVERE, null, ex);
//            } catch (MalformedURLException ex) {
//                Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
//            }
        }
//        else {
//            parametres.put(nomParametre, valeur);
//        }
        super.setParameter(nomParametre, valeur);
    }


    public void setParametres(Map<String, String> inParametres) {
        super.setParametres(inParametres);
        String path = inParametres.get(FEUILLE);
        if (path != null) {
            try {
                setTemplate(path);
            } catch (ExceptionTransformation ex) {
                Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            } catch (MalformedURLException ex) {
                Logger.getLogger(ApplicateurTemplate.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public String getNomTransfo() {
        Map<String, String> parametres = getParametres();
        String nom = parametres.get("nom");
        if (nom!= null) {
            return nom;
        }
        return nomTemplate;
    }

    @Override
    public void setChargeurRessource(ChargeurRessource inChargeur) {
        chargeur = inChargeur;
    }

    private ChargeurRessource   chargeur;
    private Templates           templates;
    private String              nomTemplate;
//    private Map<String, String> parametres = new HashMap<String, String>();

    /**
     * Pour faciliter les importations de modules dans le template, il faut
     * connaître son dossier initial
     */
    private String              dossierTemplate;



}

