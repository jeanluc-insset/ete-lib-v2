/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.jldeleage.mda.modele;

import com.jldeleage.util.ChargeurRessource;
import java.net.URL;
import java.util.Map;
import org.w3c.dom.Document;

/**
 *
 * @author jldeleage
 */
public interface Transformation {

    public Document transforme(Document doc) throws ExceptionTransformation;

    public void setParameter(String nomParametre, String valeur);

    public void setParametres(Map<String, String> inParametres);

    public void setChargeurRessource(ChargeurRessource inClassLoader);

    public String getNomTransfo();

    public void setUrlSource(URL inSource);
    public void setUrlCible(URL inDirectory);

}
