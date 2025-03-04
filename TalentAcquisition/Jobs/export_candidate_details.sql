-- export candidate details to a text file.

CREATE OR REPLACE DIRECTORY CandidateDir AS '/path/to/directory';

CREATE OR REPLACE PROCEDURE ExportCandidatesToFile IS
    file_handle UTL_FILE.FILE_TYPE;
BEGIN
    -- Open file for writing
    file_handle := UTL_FILE.FOPEN('CandidateDir', 'Candidates.txt', 'W');

    -- Write header row
    UTL_FILE.PUT_LINE(file_handle, 'CandidateID | FullName | Email | Phone | Status');

    -- Loop through candidates and write data
    FOR rec IN (SELECT CandidateID, FullName, Email, Phone, Status FROM Candidates) LOOP
        UTL_FILE.PUT_LINE(file_handle,
            rec.CandidateID || ' | ' || rec.FullName || ' | ' || rec.Email || ' | ' || rec.Phone || ' | ' || rec.Status);
    END LOOP;

    -- Close the file
    UTL_FILE.FCLOSE(file_handle);

    -- Confirmation message
    DBMS_OUTPUT.PUT_LINE('Candidate details exported successfully.');

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(file_handle) THEN
            UTL_FILE.FCLOSE(file_handle);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/