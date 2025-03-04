-- read and write large resumes stored as LOBs.

CREATE OR REPLACE PROCEDURE ReadResume (
    p_CandidateID IN NUMBER
) IS
    v_Resume BLOB;
    v_ResumeLength NUMBER;
BEGIN
    SELECT Resume INTO v_Resume FROM Candidates WHERE CandidateID = p_CandidateID;

    v_ResumeLength := DBMS_LOB.GETLENGTH(v_Resume);
    DBMS_OUTPUT.PUT_LINE('Resume size: ');
END;
/

CREATE OR REPLACE PROCEDURE WriteResume (
    p_CandidateID IN NUMBER,
    p_Resume IN BLOB
) IS
BEGIN
    UPDATE Candidates
    SET Resume = p_Resume
    WHERE CandidateID = p_CandidateID;

    DBMS_OUTPUT.PUT_LINE('Resume updated successfully.');
END;
/
