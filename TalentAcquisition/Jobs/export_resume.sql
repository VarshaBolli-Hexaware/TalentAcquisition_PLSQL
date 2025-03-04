--  export resumes to external files

--Setup Directory:

CREATE OR REPLACE DIRECTORY ResumeDir AS '/path/to/resume/directory';

-- Export Resume:

CREATE OR REPLACE PROCEDURE ExportResumeToFile (
    p_CandidateID IN NUMBER,
    p_FileName IN VARCHAR2
) IS
    v_Resume BLOB;
    v_File UTL_FILE.FILE_TYPE;
    v_Buffer RAW(32767);
    v_ResumeLength NUMBER;
    v_Offset NUMBER := 1;
    v_ChunkSize NUMBER := 32767;
BEGIN
    -- Fetch the resume BLOB for the given candidate
    SELECT Resume INTO v_Resume FROM Candidates WHERE CandidateID = p_CandidateID;

    -- Get the length of the BLOB
    v_ResumeLength := DBMS_LOB.GETLENGTH(v_Resume);

    -- Open the file in binary write mode
    v_File := UTL_FILE.FOPEN('ResumeDir', p_FileName, 'WB');

    -- Loop to write the BLOB data in chunks
    WHILE v_Offset <= v_ResumeLength LOOP
        DBMS_LOB.READ(v_Resume, v_ChunkSize, v_Offset, v_Buffer);
        UTL_FILE.PUT_RAW(v_File, v_Buffer, TRUE);
        v_Offset := v_Offset + v_ChunkSize;
    END LOOP;

    -- Close the file
    UTL_FILE.FCLOSE(v_File);

    -- Print success message
    DBMS_OUTPUT.PUT_LINE('Resume exported successfully to file: ' || p_FileName);

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_File) THEN
            UTL_FILE.FCLOSE(v_File);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/