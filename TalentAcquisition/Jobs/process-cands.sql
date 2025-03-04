-- process candidates in parallel batches to improve performance.

BEGIN
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('ProcessCandidatesTask');

    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID(
        task_name => 'ProcessCandidatesTask',
        table_owner => 'YOUR_SCHEMA',
        table_name => 'Candidates',
        by_row => TRUE,
        chunk_size => 100
    );
END;
/

CREATE OR REPLACE PROCEDURE ProcessCandidateBatch (
    p_StartRowID IN ROWID,
    p_EndRowID IN ROWID
) IS
BEGIN
    UPDATE Candidates
    SET Status = 'Processed'
    WHERE ROWID BETWEEN p_StartRowID AND p_EndRowID;

    COMMIT;
END;
/

BEGIN
    DBMS_PARALLEL_EXECUTE.RUN_TASK(
        task_name => 'ProcessCandidatesTask',
        sql_stmt => 'BEGIN ProcessCandidateBatch(:start_id, :end_id); END;',
        language_flag => DBMS_SQL.NATIVE,
        parallel_level => 4
    );
END;
/
