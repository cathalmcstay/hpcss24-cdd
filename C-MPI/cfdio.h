#include <mpi.h>

void writedatafiles( int m, int n, double psi[m+2][n+2], int scale,  MPI_Comm comm);

void writeplotfile(int m, int n, int scale);

void hue2rgb(double hue, int *r, int *g, int *b);

double colfunc(double x);
