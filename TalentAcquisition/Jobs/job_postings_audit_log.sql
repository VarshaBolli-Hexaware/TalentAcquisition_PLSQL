--Create a trigger to log every job posting into an audit table.

CREATE TABLE JobAudit (
    AuditID NUMBER PRIMARY KEY,
    JobID NUMBER,
    JobTitle VARCHAR2(100),
    Department VARCHAR2(50),
    Action VARCHAR2(20),
    ActionDate DATE
);

CREATE SEQUENCE JobAudit_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER JobPostingAudit
AFTER INSERT OR DELETE ON Jobs
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO JobAudit (AuditID, JobID, JobTitle, Department, Action, ActionDate)
        VALUES (JobAudit_SEQ.NEXTVAL, :NEW.JobID, :NEW.JobTitle, :NEW.Department, 'INSERT', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO JobAudit (AuditID, JobID, JobTitle, Department, Action, ActionDate)
        VALUES (JobAudit_SEQ.NEXTVAL, :OLD.JobID, :OLD.JobTitle, :OLD.Department, 'DELETE', SYSDATE);
    END IF;
END;
/

BEGIN
    AddJob('Data Analyst', 'Analyze data trends.', 'Data Science');
END;
/

BEGIN
    DeleteJob(1);
END;
/

SELECT * FROM JobAudit;
