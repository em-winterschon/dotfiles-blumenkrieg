/* DWF 2005-04 */
#include <stdio.h>
#include <stdlib.h>
int main (int argc, char **argv) {
  size_t onemeg = 0x00100000;
  unsigned long i;
  for (i=0; ; i++) {
    if (!malloc (onemeg)) {
      printf ("Allocated %lu MiB before failure.\n", i);
      return 0;
    }
  }
}
