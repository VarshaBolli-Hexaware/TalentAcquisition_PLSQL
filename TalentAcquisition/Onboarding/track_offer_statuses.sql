--database view to consolidate offer statuses for reporting purposes.
CREATE OR REPLACE VIEW OfferStatusReport AS
SELECT 
    o.OfferID,
    c.CandidateName,
    jp.JobTitle,
    o.OfferDate,
    o.OfferStatus,
    o.LastUpdated
FROM 
    Offers o
JOIN Candidates c ON o.CandidateID = c.CandidateID
JOIN JobPostings jp ON o.JobID = jp.JobID;

--Generate Offer Status Report

CREATE OR REPLACE PROCEDURE GenerateOfferStatusReport IS
    CURSOR offer_cursor IS
        SELECT * FROM OfferStatusReport;
    v_record OfferStatusReport%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Offer Status Report:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    FOR v_record IN offer_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('OfferID: ' v_record.OfferID 
                             ', Candidate: ' v_record.CandidateName 
                             ', Job: ' v_record.JobTitle 
                             ', Status: ' v_record.OfferStatus 
                             ', Last Updated: ' v_record.LastUpdated);
    END LOOP;
END;
/

--Custom Reporting

CREATE OR REPLACE PROCEDURE CustomOfferReport (
    p_FilterCondition IN VARCHAR2
) IS
    v_SQL VARCHAR2(4000);
    v_OfferID NUMBER;
    v_CandidateName VARCHAR2(100);
    v_JobTitle VARCHAR2(100);
    v_OfferStatus VARCHAR2(20);
    v_LastUpdated DATE;
BEGIN
    v_SQL := 'SELECT OfferID, CandidateName, JobTitle, OfferStatus, LastUpdated FROM OfferStatusReport WHERE ' p_FilterCondition;

    FOR rec IN (EXECUTE IMMEDIATE v_SQL) LOOP
        DBMS_OUTPUT.PUT_LINE('OfferID: ' rec.OfferID 
                             ', Candidate: ' rec.CandidateName 
                             ', Job: ' rec.JobTitle 
                             ', Status: ' rec.OfferStatus 
                             ', Last Updated: ' rec.LastUpdated);
    END LOOP;
END;
/

