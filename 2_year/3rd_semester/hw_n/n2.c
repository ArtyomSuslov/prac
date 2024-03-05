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

enum { NUM_OF_SEMAPH = 2 };

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

    switch (son_type) {
    case 1:
        // this son is writing even numbers
        for (int i = 0; i < num; i += 2) {
            // decreasing first semaphore which is responsible for printing even numbers
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = -1, .sem_flg = 0}, 1);

            printf("%i\n", i);
            fflush(stdout);
            
            // increasing second semaphore which is responsible for printing odd numbers
            semop(semid_son, &(struct sembuf){.sem_num = 1, .sem_op = 1, .sem_flg = 0}, 1);
        }
        break;
    
    case 2:
        // this son is writing odd numbers
        for (int i = 1; i < num; i += 2) {
            // decreasing second semaphore which is responsible for printing odd numbers
            semop(semid_son, &(struct sembuf){.sem_num = 1, .sem_op = -1, .sem_flg = 0}, 1);

            printf("%i\n", i);
            fflush(stdout);
            
            // increasing first semaphore which is responsible for printing even numbers
            semop(semid_son, &(struct sembuf){.sem_num = 0, .sem_op = 1, .sem_flg = 0}, 1);
        }
        break;
    
    default:
        break;
    }
}

// we are putting it here so son has no access to them
// but signal handler has access to delete it by id
int semid;

void
delete_shared_res(int sig)
{
    semctl(semid, 0, IPC_RMID);
}

int
main(int argc, char **argv)
{
    signal(SIGINT, delete_shared_res);

    key_t key = ftok(argv[0], 'a');
    // we are using semaphores to create an order in which 
    // sons will print odd or even numbers
    semid = semget(key, NUM_OF_SEMAPH, IPC_CREAT | 0666);

    // we will use first semaphor for even numbers
    //             second         for odd
    semctl(semid, 0, SETVAL, (union semun){.val = 1});
    semctl(semid, 1, SETVAL, (union semun){.val = 0});

    int num;
    scanf("%i", &num);

    if (fork() == 0) {
        son_process(argv[0], num, 1);
        exit(EXIT_SUCCESS);
    }
    
    if (fork() == 0) {
        son_process(argv[0], num, 2);
        exit(EXIT_SUCCESS);
    }

    while (wait(NULL) != -1);

    raise(SIGINT);

    return 0;
}