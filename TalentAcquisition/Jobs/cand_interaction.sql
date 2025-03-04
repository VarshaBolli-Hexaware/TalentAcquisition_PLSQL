--create sequence

CREATE SEQUENCE Candidate_SEQ

START WITH 1

INCREMENT BY 1

NOCACHE;

--Adds a new candidate to the system.


CREATE OR REPLACE PROCEDURE AddCandidate (

p_CandidateName IN VARCHAR2,

p_Email IN VARCHAR2,

p_PhoneNumber IN VARCHAR2,

p_Resume IN BLOB

) IS

BEGIN

INSERT INTO Candidates (

CandidateID, FullName, Email, Phone, Resume, Status, createddate

) VALUES (

Candidate_SEQ.NEXTVAL, p_CandidateName, p_Email, p_PhoneNumber, p_Resume, 'Applied', SYSDATE

);


COMMIT;


DBMS_OUTPUT.PUT_LINE('Candidate added successfully.');

END;

/


--Updates the status of a candidate.


CREATE OR REPLACE PROCEDURE UpdateCandidateStatus (

p_CandidateID IN NUMBER,

p_NewStatus IN VARCHAR2

) IS

BEGIN

UPDATE Candidates

SET Status = p_NewStatus,

Createddate = SYSDATE

WHERE CandidateID = p_CandidateID;


COMMIT;


DBMS_OUTPUT.PUT_LINE('Candidate status updated successfully.');

END;

/


--Logs an interaction with a candidate.


CREATE OR REPLACE PROCEDURE LogCandidateInteraction (

p_CandidateID IN NUMBER,

p_InteractionType IN VARCHAR2,

p_Notes IN CLOB

) IS

BEGIN

INSERT INTO CandidateInteractions (

InteractionID, CandidateID, InteractionType, InteractionDate, Notes

) VALUES (

Interaction_SEQ.NEXTVAL, p_CandidateID, p_InteractionType, SYSDATE, p_Notes

);


COMMIT;


DBMS_OUTPUT.PUT_LINE('Interaction logged successfully.');

END;

/


--Fetches candidate details based on a dynamic filter.


CREATE OR REPLACE PROCEDURE FetchCandidates (

p_FilterCondition IN VARCHAR2,

p_Result OUT SYS_REFCURSOR

) IS

v_SQL VARCHAR2(4000);

BEGIN

v_SQL := 'SELECT * FROM Candidates WHERE ' || p_FilterCondition;


OPEN p_Result FOR v_SQL;


DBMS_OUTPUT.PUT_LINE('Candidate details fetched successfully.');

END;

/


--Deletes a candidate and rolls back if any issue occurs.


CREATE OR REPLACE PROCEDURE DeleteCandidate (

p_CandidateID IN NUMBER

) IS

BEGIN

DELETE FROM CandidateInteractions WHERE CandidateID = p_CandidateID;


DELETE FROM Candidates WHERE CandidateID = p_CandidateID;


COMMIT;


DBMS_OUTPUT.PUT_LINE('Candidate deleted successfully.');

EXCEPTION

WHEN OTHERS THEN

ROLLBACK;

DBMS_OUTPUT.PUT_LINE('Error occurred. Transaction rolled back.');

END;

/