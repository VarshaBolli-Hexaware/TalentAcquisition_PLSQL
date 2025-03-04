-- procedure allows a candidate to apply for a specific job posting.

CREATE OR REPLACE PROCEDURE ApplyForJob (
    p_CandidateID IN NUMBER,
    p_JobID IN NUMBER
) IS
BEGIN
    INSERT INTO CandidateApplications (ApplicationID, CandidateID, JobID, ApplicationDate, Status)
    VALUES (CandidateApplications_SEQ.NEXTVAL, p_CandidateID, p_JobID, SYSDATE, 'Applied');

    DBMS_OUTPUT.PUT_LINE('CandidateID  successfully applied for JobID ');
END;
/



-- updates the status of a candidate's application for a specific job posting.

CREATE OR REPLACE PROCEDURE UpdateApplicationStatus (
    p_ApplicationID IN NUMBER,
    p_Status IN VARCHAR2
) IS
BEGIN
    UPDATE CandidateApplications
    SET Status = p_Status
    WHERE ApplicationID = p_ApplicationID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No application found with the given ApplicationID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Application status updated successfully.');
    END IF;
END;
/

--  retrieves all candidates who have applied for a specific job posting.

CREATE OR REPLACE PROCEDURE GetCandidatesForJob (
    p_JobID IN NUMBER
) IS
BEGIN
    FOR rec IN (SELECT c.CandidateID, c.FullName, ca.Status
                FROM Candidates c
                JOIN CandidateApplications ca ON c.CandidateID = ca.CandidateID
                WHERE ca.JobID = p_JobID) LOOP
        DBMS_OUTPUT.PUT_LINE('CandidateID: ');
    END LOOP;
END;
/

--retrieves all job postings a candidate has applied for.

CREATE OR REPLACE PROCEDURE GetJobsForCandidate (
    p_CandidateID IN NUMBER
) IS
BEGIN
    FOR rec IN (SELECT jp.JobID, jp.JobTitle, ca.Status
                FROM JobPostings jp
                JOIN CandidateApplications ca ON jp.JobID = ca.JobID
                WHERE ca.CandidateID = p_CandidateID) LOOP
        DBMS_OUTPUT.PUT_LINE('JobID: ');
    END LOOP;
END;
/