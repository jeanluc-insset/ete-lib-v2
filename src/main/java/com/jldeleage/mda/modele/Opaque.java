/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;

/**
 * Cette classe sert &agrave; d&eacute;finir des sous-&eacute;l&eacute;ments
 * de la t&acirc;che ant &lt;mda&gt; ou du plugin maven.<br/>
 * Dans le cas (ant) de
 * &lt;mda srcfile="modele.xmi" destfolder="monProjet"&gt;
 *     &lt;opaque class="fr.insset.jl.mda.EnrichissementOcl"/&gt;
 * &lt;/mda&gt;
 * Ant demande la cr&eacute;ation de l'instance de TransformationOpaque puis
 * passe l'attribut class.<br/>
 * M&ecirc;me si on utilise une autre approche ant, il faut pouvoir associer
 * statiquement un type concret &agrave; l'&eacute;l&eacute;ment
 * &lt;transformationOpaque&gt;, la classe effective &eacute;tant
 * d&eacute;termin&eacute;e dynamiquement (on peut avoir plusieurs
 * transformations opaques de types diff&eacute;rents dans un m&ecirc;me
 * script).
 *
 * @author jldeleage
 */public class Opaque extends TransformationAbstraite {

    public Document transforme(Document doc) throws ExceptionTransformation {
        try {
            Class classe = Class.forName(nomClasse);
            Transformation tr = (Transformation) classe.newInstance();
            return tr.transforme(doc);
        }
        catch (Exception e) {
            throw new ExceptionTransformation(e);
        }
    }

    public String getNomTransfo() {
        try {
            Class classe = Class.forName(nomClasse);
            Transformation tr = (Transformation) classe.newInstance();
            return tr.getNomTransfo();
        }
        catch (Exception e) {
            Logger logger = Logger.getLogger(getClass().getName());
            logger.log(Level.WARNING, "Impossible d'obtenir le nom de cette tranformation ", e);
            return "";
        }
    }

    @Override
    public void setParameter(String nomParametre, String valeur) {
        if ("class".equals(nomParametre)) {
            nomClasse = valeur;
        }
        else {
            super.setParameter(nomParametre, valeur);
        }
    }

    private String   nomClasse;

}
