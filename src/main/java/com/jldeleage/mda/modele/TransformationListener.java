/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.modele;

/**
 * Re&ccedil;oit les notifications au fur et &agrave; mesure de la progression
 * des transformations.
 *
 * @author jldeleage
 */
public interface TransformationListener {

    public void transformationStarted(Transformation inTransfo);

    public void transformationEnded(Transformation inTransfo);

}
