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
enum
{
    COMMAND = 1,
    RECEIVE_NUM = 2
};

// for .msg
enum
{
    MSG_INCREASE,
    MSG_SEND_NUM,
    MSG_FINISH
};

struct msgbuf {
    long msgtype;
    int msg;
};

void
son_server(char *filename)
{
    int num = 0;
    key_t key1 = ftok(filename, 'a');
    key_t key2 = ftok(filename, 'b');
    int son_msgid_stoc = msgget(key1, 0666);
    int son_msgid_ctos = msgget(key2, 0666);

    struct msgbuf message;

    for (;;) {
        // recieving command from client
        msgrcv(son_msgid_ctos, &message, sizeof(int), COMMAND, 0);
        
        switch (message.msg) {
        case MSG_INCREASE: {
            num++;
            break;
        }
        case MSG_SEND_NUM: {
            // sending number in a message to the client
            msgsnd(son_msgid_stoc, &(struct msgbuf){.msgtype = RECEIVE_NUM, .msg = num}, sizeof(int), 0);
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
    key_t key1 = ftok(filename, 'a');
    key_t key2 = ftok(filename, 'b');
    int son_msgid_stoc = msgget(key1, 0666);
    int son_msgid_ctos = msgget(key2, 0666);

    // sending num messages to increase number in server
    struct msgbuf message;
    for (int i = 0; i < num; ++i) {
        msgsnd(son_msgid_ctos, &(struct msgbuf){.msgtype = COMMAND, .msg = MSG_INCREASE}, sizeof(int), 0);
    }

    // sending message to send client number
    msgsnd(son_msgid_ctos, &(struct msgbuf){.msgtype = COMMAND, .msg = MSG_SEND_NUM}, sizeof(int), 0);

    // recieving number from message sent by server
    msgrcv(son_msgid_stoc, &message, sizeof message.msg, RECEIVE_NUM, 0);
    printf("%i\n", message.msg);

    // shutting down server 
    msgsnd(son_msgid_ctos, &(struct msgbuf){.msgtype = COMMAND, .msg = MSG_FINISH}, sizeof(int), 0);
}

// msgid_stoc is being used to send messages from server to client
// msgid_ctos is being used to send messages from client to server
int msgid_stoc, msgid_ctos;

void
delete_shared_res(int sig)
{
    msgctl(msgid_stoc, 0, IPC_RMID);
    msgctl(msgid_ctos, 0, IPC_RMID);
}

int
main(int argc, char **argv)
{
    signal(SIGINT, delete_shared_res);

    int num;
    scanf("%i", &num);

    key_t key1 = ftok(argv[0], 'a');
    key_t key2 = ftok(argv[0], 'b');
    msgid_stoc = msgget(key1, IPC_CREAT | 0666);
    msgid_ctos = msgget(key2, IPC_CREAT | 0666);

    // server
    if (fork() == 0) {
        son_server(argv[0]);
        exit(EXIT_SUCCESS);
    }

    // client
    if (fork() == 0) {
        son_client(argv[0], num);
        exit(EXIT_SUCCESS);
    }

    while (wait(NULL) != -1);

    raise(SIGINT);
    return 0;
}