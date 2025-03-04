-- log errors into an ErrorLog table using an autonomous transaction.

CREATE TABLE ErrorLog (
    LogID NUMBER PRIMARY KEY,
    ErrorMessage VARCHAR2(4000),
    ErrorDate DATE
);

CREATE SEQUENCE ErrorLog_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE LogError (
    p_ErrorMessage IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO ErrorLog (LogID, ErrorMessage, ErrorDate)
    VALUES (ErrorLog_SEQ.NEXTVAL, p_ErrorMessage, SYSDATE);

    COMMIT;
END;
/

BEGIN
    -- Simulate an error
    RAISE_APPLICATION_ERROR(-20001, 'Simulated error for testing.');

EXCEPTION
    WHEN OTHERS THEN
        LogError(SQLERRM);
END;
/
