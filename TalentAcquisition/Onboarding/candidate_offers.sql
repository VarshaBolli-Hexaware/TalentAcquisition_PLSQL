--Generates a new job offer for a candidate.

CREATE OR REPLACE PROCEDURE CreateOffer (
    p_CandidateID IN NUMBER,
    p_JobID IN NUMBER,
    p_OfferDetails IN CLOB
) IS
BEGIN
    INSERT INTO Offers (
        OfferID, CandidateID, JobID, OfferDate, OfferStatus, OfferDetails, LastUpdated
    ) VALUES (
        Offers_SEQ.NEXTVAL, p_CandidateID, p_JobID, SYSDATE, 'Pending', p_OfferDetails, SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Offer created successfully for CandidateID: ');
END;
/

--Updates the details of an existing job offer.

CREATE OR REPLACE PROCEDURE UpdateOffer (
    p_OfferID IN NUMBER,
    p_NewOfferDetails IN CLOB
) IS
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    -- Fetch old offer details as JSON
    SELECT OfferDetails
    INTO v_OldData
    FROM Offers
    WHERE OfferID = p_OfferID
    FOR UPDATE;  -- Lock the row to prevent conflicts

    -- Update the offer details
    UPDATE Offers
    SET OfferDetails = p_NewOfferDetails,
        LastUpdated = SYSDATE
    WHERE OfferID = p_OfferID;

    -- Set new JSON-formatted data manually
    v_NewData := p_NewOfferDetails;

    -- Insert audit record
    INSERT INTO OfferAudit (AuditID, OfferID, Action, ActionDate, OldData, NewData)
    VALUES (OfferAudit_SEQ.NEXTVAL, p_OfferID, 'Update', SYSDATE, v_OldData, v_NewData);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Offer updated successfully for OfferID: ' || p_OfferID);
END;
/


--Withdraws a job offer and logs the action.
CREATE OR REPLACE PROCEDURE WithdrawOffer (
    p_OfferID IN NUMBER
) IS
    v_OldData CLOB;
BEGIN
    -- Fetch old offer details as a JSON-formatted string
    SELECT '{ "OfferDetails": "' || OfferDetails || '", "OfferStatus": "' || OfferStatus || '" }'
    INTO v_OldData
    FROM Offers
    WHERE OfferID = p_OfferID;

    -- Update the offer status to 'Withdrawn'
    UPDATE Offers
    SET OfferStatus = 'Withdrawn',
        LastUpdated = SYSDATE
    WHERE OfferID = p_OfferID;

    -- Insert audit record
    INSERT INTO OfferAudit (AuditID, OfferID, Action, ActionDate, OldData, NewData)
    VALUES (OfferAudit_SEQ.NEXTVAL, p_OfferID, 'Withdraw', SYSDATE, v_OldData, NULL);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Offer withdrawn successfully for OfferID: ' || p_OfferID);
END;
/




--Automatically logs changes to the Offers table.

CREATE OR REPLACE TRIGGER OfferAuditTrigger
AFTER INSERT OR UPDATE OR DELETE ON Offers
FOR EACH ROW
DECLARE
    v_Action VARCHAR2(50);
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    IF INSERTING THEN
        v_Action := 'Insert';
        v_NewData := '{ "OfferDetails": "' || :NEW.OfferDetails || '", "OfferStatus": "' || :NEW.OfferStatus || '" }';
    ELSIF UPDATING THEN
        v_Action := 'Update';
        v_OldData := '{ "OfferDetails": "' || :OLD.OfferDetails || '", "OfferStatus": "' || :OLD.OfferStatus || '" }';
        v_NewData := '{ "OfferDetails": "' || :NEW.OfferDetails || '", "OfferStatus": "' || :NEW.OfferStatus || '" }';
    ELSIF DELETING THEN
        v_Action := 'Delete';
        v_OldData := '{ "OfferDetails": "' || :OLD.OfferDetails || '", "OfferStatus": "' || :OLD.OfferStatus || '" }';
    END IF;

    INSERT INTO OfferAudit (AuditID, OfferID, Action, ActionDate, OldData, NewData)
    VALUES (OfferAudit_SEQ.NEXTVAL, NVL(:NEW.OfferID, :OLD.OfferID), v_Action, SYSDATE, v_OldData, v_NewData);

END;
/


--Fetch offers based on dynamic filtering criteria.

CREATE OR REPLACE PROCEDURE GetOffersDynamic (
    p_FilterCondition IN VARCHAR2
) IS
    v_SQL VARCHAR2(4000);
    v_OfferID NUMBER;
    v_CandidateID NUMBER;
    v_JobID NUMBER;
    v_OfferStatus VARCHAR2(20);
BEGIN
    v_SQL := 'SELECT OfferID, CandidateID, JobID, OfferStatus FROM Offers WHERE ' || p_FilterCondition;

    EXECUTE IMMEDIATE v_SQL INTO v_OfferID, v_CandidateID, v_JobID, v_OfferStatus;

    DBMS_OUTPUT.PUT_LINE('OfferID: ');
END;
/

--Creates multiple offers in a single transaction.


CREATE OR REPLACE PROCEDURE BulkCreateOffers (
    p_CandidateIDs IN SYS.ODCINUMBERLIST,
    p_JobID IN NUMBER,
    p_OfferDetails IN CLOB
) IS
BEGIN
    FOR i IN 1 .. p_CandidateIDs.COUNT LOOP
        CreateOffer(p_CandidateIDs(i), p_JobID, p_OfferDetails);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Bulk offers created successfully.');
END;
/