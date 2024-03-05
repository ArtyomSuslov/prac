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

// for .msgtype
enum { CREATE_SRVER = 1 };

// for .msg
enum
{
    MSG_INCREASE,
    MSG_SEND_NUM,
    MSG_FINISH,
    MSG_CREATE_SERVER
};

struct msgbuf {
    long msgtype;
    int msg;
};

void
son_server(char *filename, pid_t client_pid)
{
    int num = 0;
    key_t key = ftok(filename, 'a');
    int msgid = msgget(key, 0666);
    pid_t server_pid = getpid();
    struct msgbuf message;

    for (;;) {
        // recieving command from client
        msgrcv(msgid, &message, sizeof(int), server_pid, 0);
        
        switch (message.msg) {
        case MSG_INCREASE: {
            num++;
            break;
        }
        case MSG_SEND_NUM: {
            // sending number in a message to the client
            msgsnd(msgid, &(struct msgbuf){.msgtype = client_pid, .msg = num}, sizeof(int), 0);
            break;
        }
        case MSG_FINISH: {
            // shutting down a server
            exit(EXIT_SUCCESS);
            break;
        }
        default:
            break;
        }
    }
}

void
son_client(char *filename, int num)
{
    key_t key = ftok(filename, 'a');
    int msgid = msgget(key, 0666);
    struct msgbuf message;
    pid_t client_pid = getpid();

    // sending registrar a message (with client's pid) to create server
    msgsnd(msgid, &(struct msgbuf){.msgtype = CREATE_SRVER, .msg = client_pid}, sizeof(int), 0);

    // receiving message with server's pid to sent it commands
    msgrcv(msgid, &message, sizeof message.msg, client_pid, 0);
    pid_t server_pid = message.msg;

    // sending num messages to increase number in server
    for (int i = 0; i < num; ++i) {
        msgsnd(msgid, &(struct msgbuf){.msgtype = server_pid, .msg = MSG_INCREASE}, sizeof(int), 0);
    }

    // sending message to send client number
    msgsnd(msgid, &(struct msgbuf){.msgtype = server_pid, .msg = MSG_SEND_NUM}, sizeof(int), 0);

    // recieving number from message sent by server
    msgrcv(msgid, &message, sizeof message.msg, client_pid, 0);
    printf("%i\n", message.msg);

    // shutting down server 
    msgsnd(msgid, &(struct msgbuf){.msgtype = server_pid, .msg = MSG_FINISH}, sizeof(int), 0);
}

void
process_registrar(char *filename)
{
    key_t key = ftok(filename, 'a');
    int msgid = msgget(key, 0666);
    struct msgbuf message;

    for (;;) {
        // recieving message to create a server
        // P.S.: I was trying to solve deadloch with alarm but it was hopeless
        msgrcv(msgid, &message, sizeof message.msg, CREATE_SRVER, 0);
        
        // cheching whether .msg == 0
        // that means that dad send a message to terminate registrar
        pid_t client_pid = message.msg;
        if (client_pid == 0) {
            // we need to kill all of registerar's children before exiting
            // otherwise we will get presentation error
            while (wait(NULL) != -1);
            exit(EXIT_SUCCESS);
        }

        // creating server
        pid_t server_pid;
        while ((server_pid = fork()) == -1) {
            wait(NULL);
        }
        if (server_pid == 0) {
            son_server(filename, client_pid);
            exit(EXIT_SUCCESS);
        }

        // sending client a message with server's pidss
        msgsnd(msgid, &(struct msgbuf){.msgtype = client_pid, .msg = server_pid}, sizeof(int), 0);
    }
}

// msgid is being used to connect clients and server via messages
int msgid;

void
delete_shared_res(int sig)
{
    msgctl(msgid, 0, IPC_RMID);
}

int
main(int argc, char **argv)
{
    signal(SIGINT, delete_shared_res);

    key_t key = ftok(argv[0], 'a');
    msgid = msgget(key, IPC_CREAT | 0666);

    // process-registrar
    if (fork() == 0) {
        process_registrar(argv[0]);
        exit(EXIT_SUCCESS);
    }

    // for every number from stdin we create client
    int num;
    int number_of_clients = 0;
    while (scanf("%i", &num) == 1) {
        pid_t pid;
        while ((pid = fork()) == -1) {
            wait(NULL);
            number_of_clients--;
        }
        if (pid == 0) {
            son_client(argv[0], num);
            exit(EXIT_SUCCESS);
        }
        number_of_clients++;
    }


    // we have to count clients, because if we use
    // while (wait(NULL) != -1);
    // we will wait until registrar will be terminated
    // but it will happen after we send him a message to do it
    for (int i = 0; i < number_of_clients; i++) {
        wait(NULL);
    }

    // messaging registrar to terminate
    msgsnd(msgid, &(struct msgbuf){.msgtype = CREATE_SRVER, .msg = 0}, sizeof(int), 0);

    while (wait(NULL) != -1);

    // deleting resourses
    raise(SIGINT);
    return 0;
}