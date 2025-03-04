--  process candidates based on their status and perform different actions.

CREATE OR REPLACE PROCEDURE ProcessCandidates IS
BEGIN
    FOR status_rec IN (SELECT DISTINCT Status FROM Candidates) LOOP
        DBMS_OUTPUT.PUT_LINE('Processing candidates with status: ' status_rec.Status);

        FOR candidate_rec IN (SELECT CandidateID, FullName FROM Candidates WHERE Status = status_rec.Status) LOOP
            IF status_rec.Status = 'Applied' THEN
                DBMS_OUTPUT.PUT_LINE('    Sending interview invitation to ' candidate_rec.FullName);
            ELSIF status_rec.Status = 'Shortlisted' THEN
                DBMS_OUTPUT.PUT_LINE('    Preparing offer letter for ' candidate_rec.FullName);
            ELSE
                DBMS_OUTPUT.PUT_LINE('    No action required for ' candidate_rec.FullName);
            END IF;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;
END;
/
