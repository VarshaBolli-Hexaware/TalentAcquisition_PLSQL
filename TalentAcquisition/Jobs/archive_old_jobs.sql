--Archive old jobs
CREATE TABLE JobArchive AS SELECT * FROM Jobs WHERE 1=0;

CREATE OR REPLACE PROCEDURE ArchiveOldJobs (
    p_DaysOld IN NUMBER
) IS
BEGIN
    INSERT INTO JobArchive
    SELECT * FROM Jobs
    WHERE PostedDate < SYSDATE - p_DaysOld;

    DELETE FROM Jobs
    WHERE PostedDate < SYSDATE - p_DaysOld;

    DBMS_OUTPUT.PUT_LINE('Old jobs archived successfully.');
END;
/

--call the procedures in the file.

CREATE OR REPLACE PROCEDURE call_archive_old_jobs AS
BEGIN
    ArchiveOldJobs(30); -- Archive jobs older than 30 days
END;
/