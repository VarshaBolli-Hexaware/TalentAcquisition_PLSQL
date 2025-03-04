-- To save storage space, resumes can be compressed before storing them in the database and decompressed when needed.

-- Procedure to Compress Resume:

CREATE OR REPLACE PROCEDURE CompressResume (
    p_CandidateID IN NUMBER
) IS
    v_Resume BLOB;
    v_CompressedResume BLOB;
    v_Compressed RAW(32767);
BEGIN
    -- Fetch the resume (BLOB) from the table
    SELECT Resume INTO v_Resume FROM Candidates WHERE CandidateID = p_CandidateID;

    -- Compress the BLOB data
    v_Compressed := UTL_COMPRESS.LZ_COMPRESS(DBMS_LOB.SUBSTR(v_Resume, DBMS_LOB.GETLENGTH(v_Resume), 1));

    -- Store compressed data back in a BLOB
    DBMS_LOB.CREATETEMPORARY(v_CompressedResume, TRUE);
    DBMS_LOB.WRITEAPPEND(v_CompressedResume, LENGTH(v_Compressed), v_Compressed);

    -- Update the Candidates table with the compressed resume
    UPDATE Candidates
    SET Resume = v_CompressedResume
    WHERE CandidateID = p_CandidateID;

    DBMS_OUTPUT.PUT_LINE('Resume compressed successfully for CandidateID: ' || p_CandidateID);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Procedure to Decompress Resume:

CREATE OR REPLACE PROCEDURE DecompressResume (
    p_CandidateID IN NUMBER
) IS
    v_CompressedResume BLOB;
    v_DecompressedResume BLOB;
    v_Decompressed RAW(32767);
BEGIN
    -- Fetch the compressed resume (BLOB)
    SELECT Resume INTO v_CompressedResume FROM Candidates WHERE CandidateID = p_CandidateID;

    -- Decompress the BLOB data
    v_Decompressed := UTL_COMPRESS.LZ_UNCOMPRESS(DBMS_LOB.SUBSTR(v_CompressedResume, DBMS_LOB.GETLENGTH(v_CompressedResume), 1));

    -- Store decompressed data back in a BLOB
    DBMS_LOB.CREATETEMPORARY(v_DecompressedResume, TRUE);
    DBMS_LOB.WRITEAPPEND(v_DecompressedResume, LENGTH(v_Decompressed), v_Decompressed);

    -- Update the Candidates table with the decompressed resume
    UPDATE Candidates
    SET Resume = v_DecompressedResume
    WHERE CandidateID = p_CandidateID;

    DBMS_OUTPUT.PUT_LINE('Resume decompressed successfully for CandidateID: ' || p_CandidateID);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
