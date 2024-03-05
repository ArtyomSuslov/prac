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
    NUM_OF_SEMAPH = 1,
    NUM_BORDER = 50000
};

union semun
{
    int val;
    struct semid_ds *buf;
    unsigned short *array;
};

void
son_process(char *filename, int num, int son_type)
{
    key_t key_son = ftok(filename, 'a');
    int semid_son = semget(key_son, NUM_OF_SEMAPH, 0666);
    int shmid_son = shmget(key_son, sizeof(int) * num, 0666);

    int *mem_pointer = shmat(shmid_son, NULL, 0);

    switch (son_type) {
    case 1: {
        for (int i = 0; i < (num / 2); ++i) {
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = -1, .sem_flg = 0}, 1);

            mem_pointer[i] += 1;
            
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = 1, .sem_flg = 0}, 1);
        }
        break;
    }
    case 2: {
        for (int i = num - 1; i >= (num / 2); --i) {
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = -1, .sem_flg = 0}, 1);

            mem_pointer[i] += 1;
            
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = 1, .sem_flg = 0}, 1);
        }
        break;
    }
    default:
        break;
    }
    shmdt(mem_pointer);
}

// we are putting it here so son has no access to them
// but signal handler has access to delete it by id
int shmid, semid;

void
delete_shared_res(int sig)
{
    semctl(semid, 0, IPC_RMID);
    shmctl(shmid, IPC_RMID, NULL);
}

int
main(int argc, char **argv)
{
    signal(SIGINT, delete_shared_res);

    int num;
    scanf("%i", &num);

    key_t key = ftok(argv[0], 'a');

    semid = semget(key, NUM_OF_SEMAPH, IPC_CREAT | 0666);
    shmid = shmget(key, sizeof(int) * num, IPC_CREAT | 0666);

    int *shm_pointer = shmat(shmid, NULL, 0);
    for (int i = 0; i < num; ++i) {
        shm_pointer[i] = i;
    }
    shmdt(shm_pointer);

    semctl(semid, 0, SETVAL, (union semun){.val = 1});

    if (fork() == 0) {
        son_process(argv[0], num, 1);
        exit(EXIT_SUCCESS);
    }
    
    if (fork() == 0) {
        son_process(argv[0], num, 2);
        exit(EXIT_SUCCESS);
    }

    while (wait(NULL) != -1);

    shm_pointer = shmat(shmid, NULL, 0);
    if (num <= NUM_BORDER) {
        for (int i = 0; i < num; ++i) {
            printf("%i\n", shm_pointer[i]);
        }
    }
    shmdt(shm_pointer);

    raise(SIGINT);
    return 0;
}