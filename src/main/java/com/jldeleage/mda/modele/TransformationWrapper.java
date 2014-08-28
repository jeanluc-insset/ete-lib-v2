/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import com.jldeleage.util.ChargeurRessource;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;

/**
 * Cette classe sert &agrave; d&eacute;finir des sous-&eacute;l&eacute;ments
 * de la t&acirc;che ant &lt;mda&gt;.<br/>
 * Dans le cas de
 * &lt;mda srcfile="modele.xmi" destfolder="monProjet"&gt;
 *     &lt;transformationOpaque class="fr.insset.jl.mda.EnrichissementOcl"/&gt;
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
 */
public class TransformationWrapper extends TransformationAbstraite
                                   implements Transformation {

    @Override
    public Document transforme(Document doc) throws ExceptionTransformation {
        return delegue.transforme(doc);
    }

    @Override
    public void setParameter(String nomParametre, String valeur) {
        delegue.setParameter(nomParametre, valeur);
    }

    @Override
    public void setParametres(Map<String, String> inParametres) {
        delegue.setParametres(inParametres);
    }

    @Override
    public void setChargeurRessource(ChargeurRessource inClassLoader) {
        delegue.setChargeurRessource(inClassLoader);
    }

    @Override
    public String getNomTransfo() {
        return delegue.getNomTransfo();
    }

    public void setTransformationClass(Class<? extends Transformation> inClasse) {
        try {
            delegue = inClasse.newInstance();
        } catch (Exception ex) {
            throw new RuntimeException("Impossible d'instancier " + inClasse.getName());
        }
    }

    private Transformation delegue;

}
