package fr.insset.jean_luc.master.etelibmaven;


import com.jldeleage.mda.modele.ApplicateurTemplate;
import com.jldeleage.mda.modele.ExceptionTransformation;
import com.jldeleage.mda.modele.LecteurXmi;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

/**
 * Unit test for simple App.
 */
public class AppTest {

    public final static String NOM_FICHIER_MODELE = "src/test/java/modele.xml"; 
    public final static String NOM_FICHIER_TEMPLATE= "src/test/java/toutesclasses2java.xml";
    public final static String DOSSIER_CIBLE = "target/test-classes/generated-sources/mda/";


    /**
     * Lit un mod&egrave;le et applique un template.<br/>
     * Cela produit des sources Java (bugg&eacute;s si le mod&egrave;le
     * n'est pas consistent).
     * 
     * @throws com.jldeleage.mda.modele.ExceptionTransformation
     */
    @Test
    public void testApp() throws ExceptionTransformation,
                                 ParserConfigurationException, SAXException,
                                 IOException, FileNotFoundException,
                                 TransformerException {
        System.out.println("PWD : " + new File(".").getAbsolutePath());
        LecteurXmi lecteurXmi = new LecteurXmi();
        File fichierModele = new File(NOM_FICHIER_MODELE);
        System.out.println(fichierModele.getAbsolutePath());
        Document doc = lecteurXmi.lisXmi(fichierModele);
        ApplicateurTemplate applicateurTemplate = new ApplicateurTemplate();
        applicateurTemplate.setParameter("template", NOM_FICHIER_TEMPLATE);
        applicateurTemplate.setParameter("dossier_cible", DOSSIER_CIBLE);
        applicateurTemplate.transforme(doc);
    }    // testApp

}
