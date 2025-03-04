--Accept Offer

CREATE OR REPLACE PROCEDURE AcceptOffer (
    p_OfferID IN NUMBER
) IS
BEGIN
    UPDATE Offers
    SET OfferStatus = 'Accepted', LastUpdated = SYSDATE
    WHERE OfferID = p_OfferID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Offer accepted successfully for OfferID: ');
END;
/

--Reject Offer
CREATE OR REPLACE PROCEDURE RejectOffer (
    p_OfferID IN NUMBER
) IS
BEGIN
    UPDATE Offers
    SET OfferStatus = 'Rejected', LastUpdated = SYSDATE
    WHERE OfferID = p_OfferID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Offer rejected successfully for OfferID: ' );
END;
/

--Notify HR on Offer Acceptance/Rejection

CREATE OR REPLACE TRIGGER NotifyHROnOfferStatusChange
AFTER UPDATE OF OfferStatus ON Offers
FOR EACH ROW
WHEN (NEW.OfferStatus IN ('Accepted', 'Rejected'))
DECLARE
    v_Email VARCHAR2(100);
    v_Message CLOB;
BEGIN
    SELECT Email INTO v_Email
    FROM HRTeam
    WHERE Role = 'Recruiter';

    v_Message := 'OfferID:  has been by CandidateID: ' ;

    -- Use UTL_SMTP or UTL_HTTP to send notification
    NotifyHR(v_Email, v_Message);
END;
/

--Notify Candidates of Offer Expiration

CREATE OR REPLACE PROCEDURE NotifyCandidateOfExpiration (
    p_CandidateEmail IN VARCHAR2,
    p_OfferDetails IN CLOB
) IS
    v_MailHost VARCHAR2(100) := 'smtp.example.com';
    v_MailPort NUMBER := 25;
    v_Connection UTL_SMTP.CONNECTION;
BEGIN
    v_Connection := UTL_SMTP.OPEN_CONNECTION(v_MailHost, v_MailPort);
    UTL_SMTP.HELO(v_Connection, 'example.com');
    UTL_SMTP.MAIL(v_Connection, 'hr@example.com');
    UTL_SMTP.RCPT(v_Connection, p_CandidateEmail);
    UTL_SMTP.DATA(v_Connection, p_OfferDetails);
    UTL_SMTP.QUIT(v_Connection);

    DBMS_OUTPUT.PUT_LINE('Expiration notification sent to ');
END;
/

--Scheduler Job for Expiration Notifications
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'NotifyExpiredOffersJob',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                              FOR rec IN (SELECT CandidateID, OfferDetails 
                                          FROM Offers 
                                          WHERE OfferStatus = ''Expired'') LOOP
                                  NotifyCandidateOfExpiration(rec.CandidateID, rec.OfferDetails);
                              END LOOP;
                          END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled         => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Expiration notification job created successfully.');
END;
/
