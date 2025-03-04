-- This procedure will print all job postings grouped by their status (e.g., Open, Closed) using nested loops.
CREATE OR REPLACE PROCEDURE PrintJobsByStatus IS
BEGIN
    FOR status_rec IN (SELECT DISTINCT Status FROM Jobs) LOOP
        DBMS_OUTPUT.PUT_LINE('Status: ');

        FOR job_rec IN (SELECT JobID, JobTitle, Department, PostedDate
                        FROM Jobs
                        WHERE Status = status_rec.Status) LOOP
            DBMS_OUTPUT.PUT_LINE('JobID: ');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;
END;
/

BEGIN
    PrintJobsByStatus;
END;
/


-- Check if a Job Posting Exists and Print a Message Accordingly
CREATE OR REPLACE PROCEDURE CheckJobExists (
    p_JobID IN NUMBER
) IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM Jobs
    WHERE JobID = p_JobID;

    IF v_Count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Job with JobID exists.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Job with JobID does not exist.');
    END IF;
END;
/

