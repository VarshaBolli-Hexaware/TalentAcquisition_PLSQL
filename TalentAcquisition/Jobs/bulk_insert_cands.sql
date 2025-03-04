-- bulk insertion of candidates into the Candidates table using the FORALL construct for better performance.

CREATE OR REPLACE PROCEDURE BulkInsertCandidates (
    p_CandidateList IN SYS.ODCIVARCHAR2LIST,
    p_EmailList IN SYS.ODCIVARCHAR2LIST,
    p_PhoneList IN SYS.ODCIVARCHAR2LIST
) IS
BEGIN
    FORALL i IN INDICES OF p_CandidateList
        INSERT INTO Candidates (CandidateID, FullName, Email, Phone, Status, CreatedDate)
        VALUES (Candidates_SEQ.NEXTVAL, p_CandidateList(i), p_EmailList(i), p_PhoneList(i), 'Applied', SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Bulk insert completed successfully.');
END;
/

DECLARE
    v_CandidateList SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('John Doe', 'Jane Smith', 'Alice Brown');
    v_EmailList SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('john@example.com', 'jane@example.com', 'alice@example.com');
    v_PhoneList SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('1234567890', '9876543210', '1122334455');
BEGIN
    BulkInsertCandidates(v_CandidateList, v_EmailList, v_PhoneList);
END;
/

