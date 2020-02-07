/* $Id: find_big_files.c 6 2006-03-13 02:00:20Z flaterco $ */

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/types.h>
#include <dirent.h>
#include <signal.h>

#define buflen 10000

void
do_dir (char *path, unsigned long nmegs) {
  DIR *dirp;
  struct dirent *dp;
  char buf[buflen];
  assert (path);
  assert (path[strlen(path)-1] == '/');
  dirp = opendir(path);
  if (!dirp) { /* opendir failed */
    perror (path);
  } else {
    for (dp = readdir(dirp); dp != NULL; dp = readdir(dirp)) {
      if ((!strcmp (dp->d_name, ".")) ||
          (!strcmp (dp->d_name, "..")))
        continue;
      else {
        struct stat s;
        sprintf (buf, "%s%s", path, dp->d_name);
        if (lstat (buf, &s) == 0) {
          if (s.st_size >= nmegs * 1048576)
            puts (buf);
          if (S_ISDIR (s.st_mode)) {
            /* Recurse directory */
            strcat (buf, "/");
            do_dir (buf, nmegs);
          }
        } else { /* stat failed */
	  perror (buf); // stat failed
        }
      }
    }
    closedir(dirp);
  }
}

int main (int argc, char **argv) {
  unsigned long nmegs;
  char buf[buflen];
  if (argc != 3) {
    fprintf (stderr, "Usage:  find_big_files search-directory nmegs\n");
    exit (-1);
  }
  assert (sscanf (argv[2], "%lu", &nmegs) == 1);
  strcpy (buf, argv[1]);
  if (buf[strlen(buf)-1] != '/')
    strcat (buf, "/");
  do_dir (buf, nmegs);
  exit (0);
}
