--Integration with Interview Scheduling

-- After an interview is completed, automatically create an offer if the candidate is shortlisted.

CREATE OR REPLACE PROCEDURE CreateOfferAfterInterview (
    p_InterviewID IN NUMBER,
    p_JobID IN NUMBER,
    p_OfferDetails IN CLOB
) IS
    v_CandidateID NUMBER;
BEGIN
    SELECT CandidateID INTO v_CandidateID
    FROM Interviews
    WHERE InterviewID = p_InterviewID AND Result = 'Shortlisted';

    IF v_CandidateID IS NOT NULL THEN
        CreateOffer(v_CandidateID, p_JobID, p_OfferDetails);
        DBMS_OUTPUT.PUT_LINE('Offer created for CandidateID: ');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No shortlisted candidate for InterviewID: ');
    END IF;
END;
/

-- Fetch all offers for a specific candidate.

CREATE OR REPLACE PROCEDURE GetCandidateOffers (
    p_CandidateID IN NUMBER
) IS
    CURSOR offer_cursor IS
        SELECT OfferID, JobID, OfferStatus, OfferDate
        FROM Offers
        WHERE CandidateID = p_CandidateID;
BEGIN
    FOR rec IN offer_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('OfferID: ');
    END LOOP;
END;
/
