--Initiates the onboarding process for a candidate.

CREATE OR REPLACE PROCEDURE StartOnboarding (
    p_CandidateID IN NUMBER,
    p_JobID IN NUMBER
) IS
BEGIN
    INSERT INTO Onboarding (
        OnboardingID, CandidateID, JobID, OnboardingStatus, DocumentStatus,
        BackgroundCheckStatus, OrientationDate, SystemAccessStatus, LastUpdated
    ) VALUES (
        Onboarding_SEQ.NEXTVAL, p_CandidateID, p_JobID, 'Pending', 'Pending',
        'Pending', NULL, 'Pending', SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Onboarding process started for CandidateID: ' p_CandidateID);
END;
/

--Updates the status of the onboarding process.

CREATE OR REPLACE PROCEDURE UpdateOnboardingStatus (
    p_OnboardingID IN NUMBER,
    p_NewStatus IN VARCHAR2
) IS
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    SELECT JSON_OBJECT('OnboardingStatus' VALUE OnboardingStatus)
    INTO v_OldData
    FROM Onboarding
    WHERE OnboardingID = p_OnboardingID;

    UPDATE Onboarding
    SET OnboardingStatus = p_NewStatus,
        LastUpdated = SYSDATE
    WHERE OnboardingID = p_OnboardingID;

    SELECT JSON_OBJECT('OnboardingStatus' VALUE p_NewStatus)
    INTO v_NewData
    FROM DUAL;

    INSERT INTO OnboardingAudit (AuditID, OnboardingID, Action, ActionDate, OldData, NewData)
    VALUES (OnboardingAudit_SEQ.NEXTVAL, p_OnboardingID, 'Update', SYSDATE, v_OldData, v_NewData);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Onboarding status updated successfully for OnboardingID: ' || p_OnboardingID);
END;
/

--Automatically logs changes to the Onboarding table.

CREATE OR REPLACE TRIGGER OnboardingAuditTrigger
AFTER INSERT OR UPDATE OR DELETE ON Onboarding
FOR EACH ROW
DECLARE
    v_Action VARCHAR2(50);
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    IF INSERTING THEN
        v_Action := 'Insert';
        v_NewData := JSON_OBJECT('OnboardingStatus' VALUE :NEW.OnboardingStatus);
    ELSIF UPDATING THEN
        v_Action := 'Update';
        v_OldData := JSON_OBJECT('OnboardingStatus' VALUE :OLD.OnboardingStatus);
        v_NewData := JSON_OBJECT('OnboardingStatus' VALUE :NEW.OnboardingStatus);
    ELSIF DELETING THEN
        v_Action := 'Delete';
        v_OldData := JSON_OBJECT('OnboardingStatus' VALUE :OLD.OnboardingStatus);
    END IF;

    INSERT INTO OnboardingAudit (AuditID, OnboardingID, Action, ActionDate, OldData, NewData)
    VALUES (OnboardingAudit_SEQ.NEXTVAL, :OLD.OnboardingID, v_Action, SYSDATE, v_OldData, v_NewData);
END;
/

--Fetch onboarding details based on dynamic filtering criteria.

CREATE OR REPLACE PROCEDURE GetOnboardingDetailsDynamic (
    p_FilterCondition IN VARCHAR2
) IS
    v_SQL VARCHAR2(4000);
    v_OnboardingID NUMBER;
    v_CandidateID NUMBER;
    v_JobID NUMBER;
    v_OnboardingStatus VARCHAR2(20);
BEGIN
    v_SQL := 'SELECT OnboardingID, CandidateID, JobID, OnboardingStatus FROM Onboarding WHERE ' || p_FilterCondition;

    EXECUTE IMMEDIATE v_SQL INTO v_OnboardingID, v_CandidateID, v_JobID, v_OnboardingStatus;

    DBMS_OUTPUT.PUT_LINE('OnboardingID: ' || v_OnboardingID || ', CandidateID: ' || v_CandidateID ||
                ', JobID: ' || v_JobID || ', OnboardingStatus: ' || v_OnboardingStatus);
END;
/

--Handles onboarding for multiple candidates in a single transaction.

CREATE OR REPLACE PROCEDURE BulkOnboarding (
    p_CandidateIDs IN SYS.ODCINUMBERLIST,
    p_JobID IN NUMBER
) IS
BEGIN
    FOR i IN 1 .. p_CandidateIDs.COUNT LOOP
        StartOnboarding(p_CandidateIDs(i), p_JobID);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Bulk onboarding process initiated successfully.');
END;
/
