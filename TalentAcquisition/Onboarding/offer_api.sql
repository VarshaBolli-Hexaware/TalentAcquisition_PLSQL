-- database view that consolidates offer details for candidates to access through the portal.

CREATE OR REPLACE VIEW CandidateOfferView AS
SELECT 
    o.OfferID,
    c.CandidateID,
    c.CandidateName,
    jp.JobID,
    jp.JobTitle,
    o.OfferDate,
    o.OfferStatus,
    o.ExpirationDate,
    o.OfferDetails
FROM 
    Offers o
JOIN Candidates c ON o.CandidateID = c.CandidateID
JOIN JobPostings jp ON o.JobID = jp.JobID;

--fetches all offers for a specific candidate to display on the Candidate Portal.

CREATE OR REPLACE PROCEDURE GetCandidateOfferDetails (
    p_CandidateID IN NUMBER
) IS
    CURSOR offer_cursor IS
        SELECT OfferID, JobTitle, OfferDate, OfferStatus, ExpirationDate, OfferDetails
        FROM CandidateOfferView
        WHERE CandidateID = p_CandidateID;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Offer Details for CandidateID: ');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

    FOR rec IN offer_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('OfferID: ');
    END LOOP;
END;
/

--REST API to Fetch Offer Data

--Enable ORDS for the Database

BEGIN
    ORDS.ENABLE_SCHEMA(
        p_schema => 'HR',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'hr',
        p_auto_rest_auth => FALSE
    );
END;
/

--Create a RESTful Service for Offer Data
--Expose the CandidateOfferView as a REST endpoint.

BEGIN
    ORDS.DEFINE_SERVICE(
        p_module_name    => 'OfferManagement',
        p_base_path      => 'offers/',
        p_pattern        => 'fetchOffers/:candidateID',
        p_source_type    => ORDS.SOURCE_TYPE_QUERY,
        p_source         => 'SELECT * FROM CandidateOfferView WHERE CandidateID = :candidateID'
    );

    ORDS.DEFINE_PARAMETER(
        p_module_name    => 'OfferManagement',
        p_pattern        => 'fetchOffers/:candidateID',
        p_name           => 'candidateID',
        p_bind_variable  => 'candidateID',
        p_source_type    => ORDS.SOURCE_TYPE_QUERY
    );

    ORDS.ENABLE_SERVICE(
        p_module_name => 'OfferManagement'
    );
END;
/

--PL/SQL API for Bulk Fetching Offer Data

--external systems to fetch offer data for multiple candidates in bulk.

CREATE OR REPLACE PROCEDURE FetchOffersForCandidates (
    p_CandidateIDs IN SYS.ODCINUMBERLIST,
    p_Result OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_Result FOR
    SELECT * 
    FROM CandidateOfferView
    WHERE CandidateID IN (SELECT COLUMN_VALUE FROM TABLE(p_CandidateIDs));
END;
/
DECLARE
    v_Result SYS_REFCURSOR;
BEGIN
    FetchOffersForCandidates(SYS.ODCINUMBERLIST(1, 2, 3), v_Result);

    LOOP
        FETCH v_Result INTO v_OfferID, v_CandidateName, v_JobTitle, v_OfferStatus;
        EXIT WHEN v_Result%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('OfferID: ');
    END LOOP;

    CLOSE v_Result;
END;
/

--Notify Candidate on Offer Update
CREATE OR REPLACE TRIGGER NotifyCandidateOnOfferUpdate
AFTER UPDATE OF OfferStatus ON Offers
FOR EACH ROW
DECLARE
    v_Email VARCHAR2(100);
    v_Message CLOB;
BEGIN
    SELECT Email INTO v_Email
    FROM Candidates
    WHERE CandidateID = :NEW.CandidateID;

    v_Message := 'Dear Candidate, your offer status has been updated to: Please log in to the Candidate Portal for more details.';

    -- Send notification via UTL_SMTP or UTL_HTTP
    NotifyCandidate(v_Email, v_Message);
END;
/
