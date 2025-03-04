--This procedure will insert a new job into the Jobs table.
CREATE OR REPLACE PROCEDURE AddJob (
    p_JobTitle IN VARCHAR2,
    p_JobDescription IN CLOB,
    p_Department IN VARCHAR2
) IS
BEGIN
    INSERT INTO Jobs (JobID, JobTitle, JobDescription, Department, PostedDate)
    VALUES (Jobs_SEQ.NEXTVAL, p_JobTitle, p_JobDescription, p_Department, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Job added successfully.');
END;
/
--This procedure will allow updating an existing job posting.
CREATE OR REPLACE PROCEDURE UpdateJob (
    p_JobID IN NUMBER,
    p_JobTitle IN VARCHAR2,
    p_JobDescription IN CLOB,
    p_Department IN VARCHAR2
) IS
BEGIN
    UPDATE Jobs
    SET JobTitle = p_JobTitle,
        JobDescription = p_JobDescription,
        Department = p_Department,
        PostedDate = SYSDATE
    WHERE JobID = p_JobID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No job found with the given JobID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Job updated successfully.');
    END IF;
END;
/
--This procedure will delete a job posting based on the JobID.
CREATE OR REPLACE PROCEDURE DeleteJob (
    p_JobID IN NUMBER
) IS
BEGIN
    DELETE FROM Jobs WHERE JobID = p_JobID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No job found with the given JobID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Job deleted successfully.');
    END IF;
END;
/
--This procedure will display all job postings.
CREATE OR REPLACE PROCEDURE ViewJobs IS
BEGIN
    FOR rec IN (SELECT * FROM Jobs) LOOP
        DBMS_OUTPUT.PUT_LINE('JobID: ');
    END LOOP;
END;
/
--Add a Job Posting

BEGIN
    AddJob('Software Engineer', 'Develop and maintain software applications.', 'IT');
END;
/
--Update a Job Posting
BEGIN
    UpdateJob(1, 'Senior Software Engineer', 'Lead the development team.', 'IT');
END;
/
--Delete a Job Posting

BEGIN
    DeleteJob(1);
END;
/
--View Job Postings

BEGIN
    ViewJobs;
END;
/
