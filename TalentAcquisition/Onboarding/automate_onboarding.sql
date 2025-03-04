--Automatically initiate the onboarding process when an offer is accepted.

CREATE OR REPLACE TRIGGER StartOnboardingOnOffer
AFTER UPDATE OF OfferStatus ON Offers
FOR EACH ROW
WHEN (NEW.OfferStatus = 'Accepted')
BEGIN
    StartOnboarding(:NEW.CandidateID, :NEW.JobID);
    DBMS_OUTPUT.PUT_LINE('Onboarding triggered for CandidateID:  upon offer acceptance.');
END;
/

--Database View for Onboarding Progress
--consolidated view to track onboarding progress for all candidates.

CREATE OR REPLACE VIEW OnboardingProgressView AS
SELECT
    o.OnboardingID,
    o.CandidateID,
    c.FullName,
    o.JobID,
    jp.JobTitle,
    o.OnboardingStatus,
    o.DocumentStatus,
    o.BackgroundCheckStatus,
    o.OrientationDate,
    o.SystemAccessStatus,
    o.LastUpdated
FROM
    Onboarding o
JOIN Candidates c ON o.CandidateID = c.CandidateID
JOIN JobPostings jp ON o.JobID = jp.JobID;

--Generate Onboarding Progress Report

CREATE OR REPLACE PROCEDURE GenerateOnboardingReport IS
    CURSOR onboarding_cursor IS
        SELECT * FROM OnboardingProgressView;
    v_record OnboardingProgressView%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Onboarding Progress Report:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    FOR v_record IN onboarding_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('OnboardingID: ');
    END LOOP;
END;
/

--Dynamic SQL for Custom Onboarding Reports
--------------------------------------------
CREATE OR REPLACE PROCEDURE CustomOnboardingReport (
    p_FilterCondition IN VARCHAR2
) IS
    TYPE OnboardingRec IS TABLE OF OnboardingProgressView%ROWTYPE;
    v_OnboardingData OnboardingRec;
    v_SQL VARCHAR2(4000);
BEGIN
    v_SQL := 'SELECT * FROM OnboardingProgressView WHERE ' || p_FilterCondition;

    -- Execute dynamic SQL and fetch data into collection
    EXECUTE IMMEDIATE v_SQL BULK COLLECT INTO v_OnboardingData;

    -- Loop through the collection
    FOR i IN 1 .. v_OnboardingData.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('OnboardingID: ' || v_OnboardingData(i).OnboardingID);
    END LOOP;
END;
/



