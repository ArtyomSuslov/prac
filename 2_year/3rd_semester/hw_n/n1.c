#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <fcntl.h>
#include <wait.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/shm.h>
#include <sys/sem.h>

enum
{
    MEMORY = 1024,
    NUM_OF_SEMAPH = 2
};

union semun
{
    int val;
    struct semid_ds *buf;
    unsigned short *array;
};

void
son_process(char *filename)
{
    // opening all of these resourses
    key_t key = ftok(filename, 'a');
    msgget(key, 0666);
    shmget(key, MEMORY, 0666);
    semget(key, NUM_OF_SEMAPH, 0666);
}

// we are putting them here so son has no access to them
// but signal handler has access to delete them by id
int msgid, shmid, semid;

void
delete_shared_res(int sig)
{
    msgctl(msgid, IPC_RMID, NULL);
    shmctl(shmid, IPC_RMID, NULL);
    semctl(semid, 0, IPC_RMID);
}

int
main(int argc, char **argv)
{
    signal(SIGINT, delete_shared_res);

    key_t key = ftok(argv[0], 'a');
    msgid = msgget(key, IPC_CREAT | 0666);
    shmid = shmget(key, MEMORY, IPC_CREAT | 0666);
    semid = semget(key, NUM_OF_SEMAPH, IPC_CREAT | 0666);

    semctl(semid, 0, SETVAL, (union semun){.val = 0});
    semctl(semid, 1, SETVAL, (union semun){.val = 0});

    if (fork() == 0) {
        son_process(argv[0]);
        exit(EXIT_SUCCESS);
    }

    while (wait(NULL) != -1);

    raise(SIGINT);

    return 0;
}