-- create a temporary table to store shortlisted candidates.

CREATE OR REPLACE PROCEDURE CreateShortlistTable IS
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE ShortlistedCandidates AS SELECT * FROM Candidates WHERE Status = ''Shortlisted''';
    DBMS_OUTPUT.PUT_LINE('ShortlistedCandidates table created.');
END;
/
CREATE OR REPLACE PROCEDURE CreateShortlistTable IS
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE ShortlistedCandidates AS SELECT * FROM Candidates WHERE Status = ''Shortlisted''';
    DBMS_OUTPUT.PUT_LINE('ShortlistedCandidates table created.');
END;
/
