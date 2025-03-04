-- This trigger will automatically update the Status column of the Jobs table when a job is marked as "Closed."
CREATE OR REPLACE TRIGGER UpdateJobStatusOnClosure
AFTER UPDATE OF Status ON Jobs
FOR EACH ROW
BEGIN
    IF :NEW.Status = 'Closed' THEN
        DBMS_OUTPUT.PUT_LINE('Job with JobID  has been marked as Closed.');
    END IF;
END;
/

--Update the status of a job to "Closed":

UPDATE Jobs
SET Status = 'Closed'
WHERE JobID = 1;

SELECT * FROM Jobs WHERE JobID = 1;

