-- Procedure to Export Job Details to a File (Using UTL_FILE)
CREATE OR REPLACE PROCEDURE ExportJobsToFile IS
    file_handle UTL_FILE.FILE_TYPE;
BEGIN
    -- Open the file in write mode
    file_handle := UTL_FILE.FOPEN('JOB_DIR', 'JobDetails.txt', 'W');

    -- Write header
    UTL_FILE.PUT_LINE(file_handle, 'JobID | JobTitle | Department | PostedDate');

    -- Write job details
    FOR rec IN (SELECT JobID, JobTitle, Department, PostedDate FROM Jobs) LOOP
        -- Corrected UTL_FILE.PUT_LINE call
        UTL_FILE.PUT_LINE(file_handle, rec.JobID || ' | ' || rec.JobTitle || ' | ' || rec.Department || ' | ' || TO_CHAR(rec.PostedDate, 'YYYY-MM-DD'));
    END LOOP;

    -- Close the file
    UTL_FILE.FCLOSE(file_handle);

    DBMS_OUTPUT.PUT_LINE('Job details exported successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        IF UTL_FILE.IS_OPEN(file_handle) THEN
            UTL_FILE.FCLOSE(file_handle);
        END IF;
END;
/


BEGIN
    ExportJobsToFile;
END;
/