-- Candidate Management Package Specification
CREATE OR REPLACE PACKAGE CandidateManagement AS
    PROCEDURE AddCandidate(
        p_CandidateName IN VARCHAR2,
        p_Email IN VARCHAR2,
        p_PhoneNumber IN VARCHAR2,
        p_Resume IN BLOB
    );

    PROCEDURE UpdateCandidateStatus(
        p_CandidateID IN NUMBER,
        p_NewStatus IN VARCHAR2
    );

    PROCEDURE LogCandidateInteraction(
        p_CandidateID IN NUMBER,
        p_InteractionType IN VARCHAR2,
        p_Notes IN CLOB  -- Corrected: Matches package body
    );

    PROCEDURE FetchCandidates(
        p_FilterCondition IN VARCHAR2,
        p_Result OUT SYS_REFCURSOR
    );

    PROCEDURE DeleteCandidate(
        p_CandidateID IN NUMBER
    );
END CandidateManagement;
/

-- Candidate Management Package Body
CREATE OR REPLACE PACKAGE BODY CandidateManagement AS
    PROCEDURE AddCandidate (
        p_CandidateName IN VARCHAR2,
        p_Email IN VARCHAR2,
        p_PhoneNumber IN VARCHAR2,
        p_Resume IN BLOB
    ) IS
        v_CandidateID NUMBER;
    BEGIN
        -- Insert candidate without the BLOB first
        INSERT INTO Candidates (
            CandidateID, FullName, Email, Phone, Status, CreatedDate
        ) VALUES (
            Candidate_SEQ.NEXTVAL, p_CandidateName, p_Email, p_PhoneNumber, 'Applied', SYSDATE
        ) RETURNING CandidateID INTO v_CandidateID;

        -- Now update the BLOB field separately
        UPDATE Candidates
        SET Resume = p_Resume
        WHERE CandidateID = v_CandidateID;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Candidate added successfully.');
    END AddCandidate;

    PROCEDURE UpdateCandidateStatus (
        p_CandidateID IN NUMBER,
        p_NewStatus IN VARCHAR2
    ) IS
    BEGIN
        UPDATE Candidates
        SET Status = p_NewStatus,
            CreatedDate = SYSDATE
        WHERE CandidateID = p_CandidateID;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Candidate status updated successfully.');
    END UpdateCandidateStatus;

    PROCEDURE LogCandidateInteraction (
        p_CandidateID IN NUMBER,
        p_InteractionType IN VARCHAR2,
        p_Notes IN CLOB  -- Corrected: Matches package spec
    ) IS
        v_InteractionID NUMBER;
    BEGIN
        -- Insert interaction without the CLOB field first
        INSERT INTO CandidateInteractions (
            InteractionID, CandidateID, InteractionType, InteractionDate
        ) VALUES (
            Interaction_SEQ.NEXTVAL, p_CandidateID, p_InteractionType, SYSDATE
        ) RETURNING InteractionID INTO v_InteractionID;

        -- Now update the CLOB field separately
        UPDATE CandidateInteractions
        SET Notes = p_Notes
        WHERE InteractionID = v_InteractionID;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Interaction logged successfully.');
    END LogCandidateInteraction;

    PROCEDURE FetchCandidates (
        p_FilterCondition IN VARCHAR2,
        p_Result OUT SYS_REFCURSOR
    ) IS
        v_SQL VARCHAR2(4000);
    BEGIN
        v_SQL := 'SELECT * FROM Candidates WHERE ' || p_FilterCondition;
        OPEN p_Result FOR v_SQL;
        DBMS_OUTPUT.PUT_LINE('Candidate details fetched successfully.');
    END FetchCandidates;

    PROCEDURE DeleteCandidate (
        p_CandidateID IN NUMBER
    ) IS
    BEGIN
        DELETE FROM CandidateInteractions WHERE CandidateID = p_CandidateID;
        DELETE FROM Candidates WHERE CandidateID = p_CandidateID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Candidate deleted successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error occurred. Transaction rolled back.');
    END DeleteCandidate;
END CandidateManagement;
/