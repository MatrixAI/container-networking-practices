/**
  * Run a shell in another namespace
  * To run the code: sudo ./practice <options>
  */

#define _GNU_SOURCE
#include <sys/mount.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#define errExit(msg)    do {perror(msg); exit(EXIT_FAILURE); \
                        } while (0)
#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

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

static void mountFS(void) {
  // Mount proc
  char *mount_point = "/proc";

  mkdir(mount_point, 0555);
  if (mount("proc", mount_point, "proc", 0, NULL) == -1)
      errExit("mount");
  printf("Mounting procfs at %s\n", mount_point);

  // Mount sys
  mount_point = "/sys";

  mkdir(mount_point, 0555);
  if (mount("sys", mount_point, "sysfs", 0, NULL) == -1)
      errExit("mount");

}

static int childFunc(void* arg) {
  char *argv[] = {"/bin/sh", 0};

  if (chdir("./rootfs/") == -1)
    errExit("chdir");

  if (chroot("./") == -1)
    errExit("chroot");

  mountFS();

  execvp("/bin/bash", argv);
  errExit("execvp");
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
      case 'a': flags = CLONE_NEWIPC | CLONE_NEWNS |
                        CLONE_NEWNET | CLONE_NEWPID |
                        CLONE_NEWUTS | CLONE_NEWUSER;
                break;
      case 'i': flags |= CLONE_NEWIPC;        break;
      case 'm': flags |= CLONE_NEWNS;         break;
      case 'n': flags |= CLONE_NEWNET;        break;
      case 'p': flags |= CLONE_NEWPID;        break;
      case 'u': flags |= CLONE_NEWUTS;        break;
      case 'U': flags |= CLONE_NEWUSER;       break;
      default:  usage(argv[0]);
      }
  }

  int child_pid = clone(childFunc, child_stack + STACK_SIZE, flags | SIGCHLD, NULL);

  if (child_pid == -1)
    errExit("clone");

  printf("PID of child created by clone() is %d\n", child_pid);

  if (waitpid(child_pid, NULL, 0) == -1)
    errExit("waitpid");

  printf("Parent terminating\n");
  exit(0);
}
