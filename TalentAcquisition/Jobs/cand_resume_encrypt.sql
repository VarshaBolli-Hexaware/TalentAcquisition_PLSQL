- To ensure the security of resumes, they can be encrypted before storing and decrypted when accessed.

-- Procedure to Encrypt Resume:

CREATE OR REPLACE PROCEDURE EncryptResume (
    p_CandidateID IN NUMBER
) IS
    v_Resume BLOB;
    v_EncodedResume CLOB;
BEGIN
    -- Fetch the resume
    SELECT Resume INTO v_Resume FROM Candidates WHERE CandidateID = p_CandidateID;

    -- Encode the BLOB to Base64 (CLOB)
    v_EncodedResume := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(v_Resume));

    -- Update the encoded resume back into the table
    UPDATE Candidates
    SET Resume = TO_BLOB(UTL_RAW.CAST_TO_RAW(v_EncodedResume))
    WHERE CandidateID = p_CandidateID;

    COMMIT;
   
    DBMS_OUTPUT.PUT_LINE('Resume encoded successfully for CandidateID: ' || p_CandidateID);
END;
/

--------------------------------------------
--Procedure to Decrypt Resume:

CREATE OR REPLACE PROCEDURE DecryptResume (
    p_CandidateID IN NUMBER
) IS
    v_EncodedResume BLOB;
    v_DecodedResume BLOB;
BEGIN
    -- Fetch the encoded resume
    SELECT Resume INTO v_EncodedResume FROM Candidates WHERE CandidateID = p_CandidateID;

    -- Decode the Base64 BLOB back to its original form
    v_DecodedResume := UTL_ENCODE.BASE64_DECODE(v_EncodedResume);

    -- Update the decoded resume back into the table
    UPDATE Candidates
    SET Resume = v_DecodedResume
    WHERE CandidateID = p_CandidateID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Resume decoded successfully for CandidateID: ' || p_CandidateID);
END;
/
