#!/usr/bin/env python
#
# CFD Calculation
# ===============
#
# Simulation of inviscid flow in a 2D box using the Jacobi algorithm.
#
# Basic Python version - uses lists
#
# EPCC, 2014
#

import sys
import time

# Import numpy
import numpy as np

# Import the local "util.py" methods
import util

# Import the external jacobi function from "jacobi.py"
from jacobi_numpy import jacobi

def main(argv):

    # Test we have the correct number of arguments
    if len(argv) < 2:
        print("Usage: cfd.py <scalefactor> <iterations>")
        sys.exit(1)
        
    # Get the systen parameters from the arguments
    scalefactor = int(argv[0])
    niter = int(argv[1])
    
    print("\n2D CFD Simulation")
    print("=================")
    print("Scale factor = {0}".format(scalefactor))
    print("Iterations   = {0}".format(niter))
    
    # Set the minimum size parameters
    mbase = 32
    nbase = 32
    bbase = 10
    hbase = 15
    wbase =  5
    
    # Set the dimensions of the array
    m = mbase*scalefactor
    n = nbase*scalefactor
    
    # Set the parameters for boundary conditions
    b = bbase*scalefactor 
    h = hbase*scalefactor
    w = wbase*scalefactor

    # Write the simulation details
    print("\nGrid size = {0} x {1}".format(m, n))
    
    # Define the psi array of dimension [m+2][n+2] and set it to zero
    psi = np.zeros((m+2, n+2))

    # Set the boundary conditions on bottom edge
    for i in range(b+1, b+w):
        psi[i][0] = float(i-b)
    for i in range(b+w, m+1):
        psi[i][0] = float(w)

    # Set the boundary conditions on right edge
    for j in range(1, h+1):
        psi[m+1][j] = float(w)
    for j in range(h+1, h+w):
        psi[m+1][j] = float(w-j+h)
    
    # Call the Jacobi iterative loop (and calculate timings)
    tstart = time.time()
    jacobi(niter, psi)
    tend = time.time()

    ttot = tend - tstart

    print("Time for ", niter, " iterations was ", ttot, " seconds")
    print("Each iteration took ", ttot/niter, " seconds")
  
    print("\nWriting data files ...")
# Write the output files for subsequent visualisation
    util.write_data(m, n, scalefactor, psi, "velocity.dat", "colourmap.dat")
    print("... done")
    # Finish nicely
    sys.exit(0)

# Function to create tidy way to have main method
if __name__ == "__main__":
        main(sys.argv[1:])
