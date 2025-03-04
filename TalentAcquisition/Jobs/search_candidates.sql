-- search for candidates by name.

CREATE OR REPLACE PROCEDURE SearchCandidatesByName (
    p_Name IN VARCHAR2
) IS
    v_SQL VARCHAR2(1000);
    v_CandidateID NUMBER;
    v_FullName VARCHAR2(100);
BEGIN
    v_SQL := 'SELECT CandidateID, FullName FROM Candidates WHERE FullName LIKE ''%' p_Name '%''';

    FOR rec IN (EXECUTE IMMEDIATE v_SQL RETURNING INTO v_CandidateID, v_FullName) LOOP
        DBMS_OUTPUT.PUT_LINE('CandidateID: ' v_CandidateID ', FullName: ' v_FullName);
    END LOOP;
END;
/

-- print candidates grouped by their status.

CREATE OR REPLACE PROCEDURE PrintCandidatesByStatus IS
BEGIN
    FOR status_rec IN (SELECT DISTINCT Status FROM Candidates) LOOP
        DBMS_OUTPUT.PUT_LINE('Status: ');

        FOR candidate_rec IN (SELECT CandidateID, FullName FROM Candidates WHERE Status = status_rec.Status) LOOP
            DBMS_OUTPUT.PUT_LINE('    CandidateID: ');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;
END;
/
