/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.jldeleage.mda.util;



import com.jldeleage.util.ChargeurRessource;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.LinkedList;
import java.util.List;



/**
 *
 * @author jldeleage
 */
public class Lecteur extends ChargeurRessource {


    public Lecteur() {
        
    }


    @Override
    public String getRacine(String nomDeFichier) throws MalformedURLException {
        return new File(".").getAbsolutePath();
    }

    public Lecteur(Object inDemandeur) {
        demandeur = inDemandeur;
    }


    @Override
    public InputStream getResource(String inNomRessource) {
        return getFichier(inNomRessource, demandeur);
    }


    public InputStream getFichier(String inNomFichier, Object demandeur) {
        try {
            return new FileInputStream(inNomFichier);
        }
        catch (Exception e) {
            try {
                InputStream resultat = demandeur.getClass().getResourceAsStream(inNomFichier);
                if (resultat != null) {
                    return resultat;
                }
                return getClass().getResourceAsStream("/" + inNomFichier);
            }
            catch (Exception e2) {
                return getClass().getResourceAsStream("/" + inNomFichier);
            }
        }
    }


    @Override
    public boolean isDirectory(String chemin) {
        return false;
    }


    @Override
    public Iterable<String> getNames(String chemin) throws IOException {
        List<String> resultat = new LinkedList<String>();
        return resultat;
    }


    @Override
    public Class chargeClasse(String nom) throws IOException, ClassNotFoundException {
        throw new UnsupportedOperationException("Not supported yet.");
    }


    private Object demandeur;


}

