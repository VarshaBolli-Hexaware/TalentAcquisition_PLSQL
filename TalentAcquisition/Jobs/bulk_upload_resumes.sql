-- bulk uploading of resumes for multiple candidates.


-- Create Custom Collection Type

CREATE TYPE BLOB_TABLE AS TABLE OF BLOB;

/

CREATE OR REPLACE PROCEDURE BulkUploadResumes (

p_CandidateIDs IN SYS.ODCINUMBERLIST,

p_Resumes IN BLOB_TABLE

) IS

BEGIN

FORALL i IN INDICES OF p_CandidateIDs

UPDATE Candidates

SET Resume = p_Resumes(i)

WHERE CandidateID = p_CandidateIDs(i);


DBMS_OUTPUT.PUT_LINE('Bulk resume upload completed successfully.');

END;

/

DECLARE

v_CandidateIDs SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2, 3);

v_Resumes BLOB_TABLE := BLOB_TABLE(EMPTY_BLOB(), EMPTY_BLOB(), EMPTY_BLOB());

BEGIN

BulkUploadResumes(v_CandidateIDs, v_Resumes);

END;

/



-------