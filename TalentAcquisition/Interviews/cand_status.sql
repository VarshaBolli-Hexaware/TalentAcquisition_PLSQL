--Update candidate status with nested conditions.


CREATE OR REPLACE PROCEDURE UpdateCandidateStatus (
    p_CandidateID IN NUMBER,
    p_NewStatus IN VARCHAR2
) IS
    v_CurrentStatus VARCHAR2(20);
BEGIN
    SELECT Status INTO v_CurrentStatus FROM Candidates WHERE CandidateID = p_CandidateID;

    IF v_CurrentStatus = 'Applied' THEN
        IF p_NewStatus = 'Interviewed' THEN
            UPDATE Candidates
            SET Status = p_NewStatus,
                Createddate = SYSDATE
            WHERE CandidateID = p_CandidateID;

            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Candidate status updated to Interviewed.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Invalid status transition.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Candidate is not in Applied status.');
    END IF;
END;
/

--Log interactions for multiple candidates in a single transaction.

CREATE OR REPLACE PROCEDURE BulkLogInteractions (
    p_CandidateIDs IN SYS.ODCINUMBERLIST,
    p_InteractionType IN VARCHAR2,
    p_Notes IN CLOB
) IS
BEGIN
    FOR i IN 1 .. p_CandidateIDs.COUNT LOOP
        INSERT INTO CandidateInteractions (
            InteractionID, CandidateID, InteractionType, InteractionDate, Notes
        ) VALUES (
            Interaction_SEQ.NEXTVAL, p_CandidateIDs(i), p_InteractionType, SYSDATE, p_Notes
        );
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Bulk interactions logged successfully.');
END;
/
