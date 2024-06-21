# 
# Jacobi function for CFD calculation
#
# Basic Python version using lists
#

import sys
import math

def jacobi(niter, psi):

    # Get the inner dimensions
    m = len(psi) - 2
    n = len(psi[0]) -2

    # Compute normalisation factor for error

    bnorm = 0.0

    for i in range(0,m+2):
        for j in range(0,n+2):
            bnorm += psi[i][j]*psi[i][j]

    bnorm = math.sqrt(bnorm)

    # Define the temporary array and zero it
    psitmp = [[0 for col in range(n+2)] for row in range(m+2)]

    print("\nStarting main loop...\n");

    # Iterate for number of iterations
    for iter in range(1,niter+1):

        # Loop over the elements computing the stream function
        for i in range(1,m+1):
            for j in range(1,n+1):
                psitmp[i][j] = 0.25 * (psi[i+1][j]+psi[i-1][j]+psi[i][j+1]+psi[i][j-1])

        if (iter == niter):

            error = 0.0
    
            for i in range(1,m+1):
                for j in range(1,n+1):
                    error = error + (psitmp[i][j]-psi[i][j])*(psitmp[i][j]-psi[i][j])
            error = math.sqrt(error)
            error = error/bnorm

        # Update psi
        for i in range(1,m+1):
            for j in range(1,n+1):
                psi[i][j] = psitmp[i][j]

        # Debug output
        if iter%1000 == 0:
            print("Completed iteration ", iter)

    print("\n... finished");
    print("After ", niter, " iterations, the error is ", error);

