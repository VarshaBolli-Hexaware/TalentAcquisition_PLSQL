--upload candidate resume

CREATE OR REPLACE PROCEDURE UploadResume (
    p_CandidateID IN NUMBER,
    p_Resume IN BLOB
) IS
BEGIN
    UPDATE Candidates
    SET Resume = p_Resume
    WHERE CandidateID = p_CandidateID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No candidate found with the given CandidateID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Resume uploaded successfully.');
    END IF;
END;
/
