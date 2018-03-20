/*
  1. Create a container
  2. Start a shell in a newly created container
*/

#include <stdio.h>
#include <sched.h>
#include <getopt.h>

static void usage(char* pname) {
  fprintf(stderr, "Usage: %s [options] cmd [arg...]\n", pname);
  fprintf(stderr, "Options can be:\n");
  fprintf(stderr, "    -i   new IPC namespace\n");
  fprintf(stderr, "    -m   new mount namespace\n");
  fprintf(stderr, "    -n   new network namespace\n");
  fprintf(stderr, "    -p   new PID namespace\n");
  fprintf(stderr, "    -u   new UTS namespace\n");
  fprintf(stderr, "    -U   new user namespace\n");
  fprintf(stderr, "    -v   Display verbose messages\n");
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
  int flags, opt, verbose;

  while ((opt = getopt(argc, argv, "+imnpuUv")) != -1) {
      if (opt == 'a') {
        flags |= CLONE_NEWIPC;
        flags |= CLONE_NEWNS;
        flags |= CLONE_NEWNET;
        flags |= CLONE_NEWPID;
        flags |= CLONE_NEWUTS;
        flags |= CLONE_NEWUSER;
        break;
      }
      switch (opt) {
      case 'i': flags |= CLONE_NEWIPC;        break;
      case 'm': flags |= CLONE_NEWNS;         break;
      case 'n': flags |= CLONE_NEWNET;        break;
      case 'p': flags |= CLONE_NEWPID;        break;
      case 'u': flags |= CLONE_NEWUTS;        break;
      case 'U': flags |= CLONE_NEWUSER;       break;
      case 'v': verbose = 1;                  break;
      default:  usage(argv[0]);
      }
  }

  if (unshare(flags) == -1)
    errExit("unshare")

  execvp("/bin/sh", NULL);
  errExit("execvp");
}
