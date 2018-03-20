/*
  1. Create a container
  2. Start a shell in a newly created container
*/

#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/wait.h>

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)

static void usage(char* pname) {
  fprintf(stderr, "Usage: %s [options]\n", pname);
  fprintf(stderr, "Options can be:\n");
  fprintf(stderr, "    -a   all namespaces\n");
  fprintf(stderr, "    -i   new IPC namespace\n");
  fprintf(stderr, "    -m   new mount namespace\n");
  fprintf(stderr, "    -n   new network namespace\n");
  fprintf(stderr, "    -p   new PID namespace\n");
  fprintf(stderr, "    -u   new UTS namespace\n");
  fprintf(stderr, "    -U   new user namespace\n");
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
  int flags = 0, opt;

  /* Parse command-line options. The initial '+' character in
     the final getopt() argument prevents GNU-style permutation
     of command-line options. That's useful, since sometimes
     the 'command' to be executed by this program itself
     has command-line options. We don't want getopt() to treat
     those as options to this program. */

  while ((opt = getopt(argc, argv, "+aimnpuU")) != -1) {
      switch (opt) {
      case 'a': flags = CLONE_NEWNS |
                        CLONE_NEWIPC |
                        CLONE_NEWNET |
                        CLONE_NEWPID |
                        CLONE_NEWUTS |
                        CLONE_NEWUSER;        break;
      case 'i': flags |= CLONE_NEWIPC;        break;
      case 'm': flags |= CLONE_NEWNS;         break;
      case 'n': flags |= CLONE_NEWNET;        break;
      case 'p': flags |= CLONE_NEWPID;        break;
      case 'u': flags |= CLONE_NEWUTS;        break;
      case 'U': flags |= CLONE_NEWUSER;       break;
      default:  usage(argv[0]);
      }
  }

  if (unshare(flags) == -1)
    errExit("unshare");

  char *argv_inner[] = {"/bin/sh", NULL};
  execvp(argv_inner[0], argv_inner);
  errExit("execvp");
}
