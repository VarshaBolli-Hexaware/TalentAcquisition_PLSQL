-- return the number of candidates based on their status.
CREATE OR REPLACE FUNCTION GetCandidateCountByStatus (
    p_Status IN VARCHAR2
) RETURN NUMBER IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM Candidates
    WHERE Status = p_Status;

    RETURN v_Count;
END;
/

-- log any changes to the Status column of the Candidates table.

CREATE TABLE CandidateStatusLog (
    LogID NUMBER PRIMARY KEY,
    CandidateID NUMBER,
    OldStatus VARCHAR2(20),
    NewStatus VARCHAR2(20),
    ChangeDate DATE
);

CREATE SEQUENCE CandidateStatusLog_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER CandidateStatusChangeLog
AFTER UPDATE OF Status ON Candidates
FOR EACH ROW
BEGIN
    INSERT INTO CandidateStatusLog (LogID, CandidateID, OldStatus, NewStatus, ChangeDate)
    VALUES (CandidateStatusLog_SEQ.NEXTVAL, :OLD.CandidateID, :OLD.Status, :NEW.Status, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Candidate status change logged.');
END;
/
