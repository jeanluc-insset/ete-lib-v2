/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.jldeleage.mda.util;

/**
 *
 * @author Dr. Heinz M. Kabutz http://www.javaspecialists.co.za/archive/Issue145.html
 */

public enum TristateState {
  SELECTED {
    public TristateState next() {
      return INDETERMINATE;
    }
  },
  INDETERMINATE {
    public TristateState next() {
      return DESELECTED;
    }
  },
  DESELECTED {
    public TristateState next() {
      return SELECTED;
    }
  };

  public abstract TristateState next();
}
  