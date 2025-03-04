CREATE OR REPLACE PROCEDURE SearchJobsByTitle (
    p_Keyword IN VARCHAR2
) IS
    v_SQL VARCHAR2(1000);
    v_JobID NUMBER;
    v_JobTitle VARCHAR2(100);
    v_Department VARCHAR2(50);
BEGIN
    v_SQL := 'SELECT JobID, JobTitle, Department FROM Jobs WHERE JobTitle LIKE ''%' p_Keyword '%''';

    FOR rec IN (EXECUTE IMMEDIATE v_SQL RETURNING INTO v_JobID, v_JobTitle, v_Department) LOOP
        DBMS_OUTPUT.PUT_LINE('JobID: ' v_JobID ', Title: ' v_JobTitle ', Department: ' v_Department);
    END LOOP;
END;
/

BEGIN
    SearchJobsByTitle('Engineer');
END;
/
