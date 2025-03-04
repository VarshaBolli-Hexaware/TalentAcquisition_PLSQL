-- add a new candidate to the Candidates table
CREATE OR REPLACE PROCEDURE AddCandidates (
    p_FullName IN VARCHAR2,
    p_Email IN VARCHAR2,
    p_Phone IN VARCHAR2,
    p_Resume IN BLOB
) IS
BEGIN
    INSERT INTO Candidates (CandidateID, FullName, Email, Phone, Resume, Status, CreatedDate)
    VALUES (Candidates_SEQ.NEXTVAL, p_FullName, p_Email, p_Phone, p_Resume, 'Applied', SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Candidate added successfully.');
END;
/

-- update the status of a candidate.
CREATE OR REPLACE PROCEDURE UpdateCandidatesStatus (
    p_CandidateID IN NUMBER,
    p_Status IN VARCHAR2
) IS
BEGIN
    UPDATE Candidates
    SET Status = p_Status
    WHERE CandidateID = p_CandidateID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No candidate found with the given CandidateID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Candidate status updated successfully.');
    END IF;
END;
/
-- delete a candidate's record.

CREATE OR REPLACE PROCEDURE DeleteCandidates (
    p_CandidateID IN NUMBER
) IS
BEGIN
    DELETE FROM Candidates
    WHERE CandidateID = p_CandidateID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No candidate found with the given CandidateID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Candidate deleted successfully.');
    END IF;
END;
/

