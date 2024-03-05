#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    struct Node *next, *previous;
    int data;
} Node;

int
find_list_length(Node *node)
{
    int len = 1;
    Node *temp = node->next;
    while (temp != node) {
        len++;
        temp = temp->next;
    }
    return len;
}

void
kill_node(Node list, Node *node)
{
    Node *prev = node->previous, *next = node->next;
    prev->next = next;
    next->previous = prev;
}

void
kill_list(Node *list)
{
    Node *cur = list->next;
    while (cur != list) {
        Node *temp = cur;
        cur = cur->next;
        free(temp);
    }
    free(list);
}

Node
add_node(Node list, Node *node)
{
    node->previous = list.previous;
    node->next = list.next->previous;
    
    if (list.previous == list.next->previous) {
        list.next = node;
    } else {
        list.previous->next = node;
    }
    list.previous = node;

    return list;
}

void
initialize_node(Node *node)
{
    node->next = node;
    node->previous = node;
}

void
print_looped_list(Node *list)
{
    Node *temp = list->previous;
    printf("%i ", temp->data);
    temp = temp->previous;
    while (temp != list->previous) {
        printf("%i ", temp->data);
        temp = temp->previous;
    }
}

int
main(void)
{
    int temp;
    // list - pointer to "head"
    Node *list = (Node *)calloc(sizeof(*list), 1);

    // initialize "head" node
    if (scanf("%i", &temp) == 1) {
        list->data = temp;
        initialize_node(list);
    } else {
        free(list);
        return 0;
    }
    
    // add other nodes
    while (scanf("%i", &temp) == 1) {
        Node *node = (Node *)calloc(sizeof(*node), 1);
        node->data = temp;
        *list = add_node(*list, node);
    }

    int len = find_list_length(list), cur_len = len;

    Node *temp_node = list;
    for (int i = 0; i < len; ++i) {
        Node *one_more_temp = temp_node->next;
        if (temp_node->data > 100) {
            if (temp_node == list) {
                list = list->next;
                if (temp_node != list) {
                    kill_node(*list, list->previous);
                }
            } else {
                kill_node(*list, temp_node);
            }
            *list = add_node(*list, temp_node);
            temp_node = one_more_temp;
        } else if ((temp_node->data < 100) && ((temp_node->data & 1) == 1)) {
            if (temp_node == list) {
                list = list->next;
                if (temp_node != list) {
                    kill_node(*list, list->previous);
                }
            } else {
                kill_node(*list, temp_node);
            }
            free(temp_node);
            cur_len--;
            temp_node = one_more_temp;
        } else {
            temp_node = one_more_temp;
        }
    }

    if (cur_len > 0) {
        print_looped_list(list);
        printf("\n");
        kill_list(list);
    }

    return 0;
}