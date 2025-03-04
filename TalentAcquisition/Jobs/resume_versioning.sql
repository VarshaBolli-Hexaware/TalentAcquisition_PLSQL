-- To maintain a history of resumes uploaded by candidates, we can implement a versioning system.

-- Create a Resume Versions Table:

CREATE TABLE ResumeVersions (
    VersionID NUMBER PRIMARY KEY,
    CandidateID NUMBER,
    Resume BLOB,
    VersionDate DATE,
    VersionNumber NUMBER
);

CREATE SEQUENCE ResumeVersions_SEQ START WITH 1 INCREMENT BY 1;

-- Procedure to Save a New Version of Resume:

CREATE OR REPLACE PROCEDURE SaveResumeVersion (
    p_CandidateID IN NUMBER,
    p_Resume IN BLOB
) IS
    v_VersionNumber NUMBER;
BEGIN
    SELECT NVL(MAX(VersionNumber), 0) + 1
    INTO v_VersionNumber
    FROM ResumeVersions
    WHERE CandidateID = p_CandidateID;

    INSERT INTO ResumeVersions (VersionID, CandidateID, Resume, VersionDate, VersionNumber)
    VALUES (ResumeVersions_SEQ.NEXTVAL, p_CandidateID, p_Resume, SYSDATE, v_VersionNumber);

    DBMS_OUTPUT.PUT_LINE('New resume version saved successfully for CandidateID: ');
END;
/

-- search resumes for specific keywords

CREATE OR REPLACE PROCEDURE SearchResumes (
    p_Keyword IN VARCHAR2
) IS
    v_Resume BLOB;
    v_Position NUMBER;
BEGIN
    FOR rec IN (SELECT CandidateID, FullName, Resume FROM Candidates) LOOP
        v_Position := DBMS_LOB.INSTR(rec.Resume, UTL_RAW.CAST_TO_RAW(p_Keyword));

        IF v_Position > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Keyword found in resume of CandidateID: ');
        END IF;
    END LOOP;
END;
/
