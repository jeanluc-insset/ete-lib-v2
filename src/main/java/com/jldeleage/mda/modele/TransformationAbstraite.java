/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

import com.jldeleage.util.ChargeurRessource;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author jldeleage
 */
public abstract class TransformationAbstraite implements Transformation {


    public void setParameter(String nomParametre, String valeur) {
        parametres.put(nomParametre, valeur);
    }

    public void setParametres(Map<String, String> inParametres) {
        parametres = inParametres;
    }

    public Map<String, String> getParametres() {
        return parametres;
    }

    public void setChargeurRessource(ChargeurRessource inClassLoader) {
        chargeur = inClassLoader;
    }


    public URL getUrlSource() {
        return urlSource;
    }

    public void setUrlSource(URL urlSource) {
        this.urlSource = urlSource;
    }

    public URL getUrlCible() {
        return urlCible;
    }

    public void setUrlCible(URL urlCible) {
        this.urlCible = urlCible;
    }


    private ChargeurRessource   chargeur;
    private URL                 urlSource;
    private URL                 urlCible;
    private Map<String, String> parametres = new HashMap<String, String>();

}
