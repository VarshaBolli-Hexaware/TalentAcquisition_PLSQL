-- Generate reports to analyze candidate applications and job postings.

--Procedure to Generate Job Application Report:

CREATE OR REPLACE PROCEDURE GenerateJobApplicationReport (
    p_JobID IN NUMBER
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Job Application Report for JobID: ');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    FOR rec IN (SELECT c.FullName, c.Email, ca.ApplicationDate, ca.Status
                FROM Candidates c
                JOIN CandidateApplications ca ON c.CandidateID = ca.CandidateID
                WHERE ca.JobID = p_JobID) LOOP
        DBMS_OUTPUT.PUT_LINE('FullName: ');
    END LOOP;
END;
/


-- process applications in bulk for a specific job posting.

CREATE OR REPLACE PROCEDURE BulkUpdateApplicationStatus (
    p_JobID IN NUMBER,
    p_Status IN VARCHAR2
) IS
    TYPE t_ApplicationIDs IS TABLE OF CandidateApplications.ApplicationID%TYPE;
    v_ApplicationIDs t_ApplicationIDs;
BEGIN
    -- Fetch ApplicationIDs into a collection
    SELECT ApplicationID
    BULK COLLECT INTO v_ApplicationIDs
    FROM CandidateApplications
    WHERE JobID = p_JobID;

    -- Bulk update using FORALL
    FORALL i IN 1..v_ApplicationIDs.COUNT
        UPDATE CandidateApplications
        SET Status = p_Status
        WHERE ApplicationID = v_ApplicationIDs(i);

    DBMS_OUTPUT.PUT_LINE('Bulk status update completed for JobID: ' || p_JobID);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
