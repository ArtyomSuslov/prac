unit MatType;

interface

type
    ref_mat_elem_t = ^mat_elem_t;

    mat_elem_t = record
        value:       double;
        node_num:    LongWord
    end;

    mat_arr_t = array of mat_elem_t;

    mat_tree_t = ^tree_node_t;

    tree_node_t = record
        row, column: longword;
        element:     ref_mat_elem_t;
        left, right: mat_tree_t;
        depth:       LongWord
    end;

    dimensions_t = array[1..3] of longword;

const
    SPARSE = 0;
    DENCE = 1;

implementation

end.