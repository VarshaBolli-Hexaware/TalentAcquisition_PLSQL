--Notify Candidates via Email (UTL_SMTP)

CREATE OR REPLACE PROCEDURE NotifyCandidateOffer (
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

    DBMS_OUTPUT.PUT_LINE('Notification sent to ' );
END;
/

-- Notify Candidates via REST API (UTL_HTTP)

CREATE OR REPLACE PROCEDURE NotifyCandidateOfferHTTP (
    p_CandidateEmail IN VARCHAR2,
    p_OfferDetails IN CLOB
) IS
    v_Url VARCHAR2(2000) := 'https://api.example.com/send-email';
    v_Request UTL_HTTP.REQ;
    v_Response UTL_HTTP.RESP;
    v_ResponseText VARCHAR2(4000);
    v_Body CLOB;
BEGIN
    v_Body := '{"to": " p_CandidateEmail ", "subject": "Job Offer", "body":  "body"}';

    v_Request := UTL_HTTP.BEGIN_REQUEST(v_Url, 'POST', 'HTTP/1.1');
    UTL_HTTP.SET_HEADER(v_Request, 'Content-Type', 'application/json');
    UTL_HTTP.SET_HEADER(v_Request, 'Authorization', 'Bearer YOUR_API_KEY');
    UTL_HTTP.WRITE_TEXT(v_Request, v_Body);

    v_Response := UTL_HTTP.GET_RESPONSE(v_Request);

    BEGIN
        LOOP
            UTL_HTTP.READ_TEXT(v_Response, v_ResponseText);
            DBMS_OUTPUT.PUT_LINE(v_ResponseText);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            NULL;
    END;

    UTL_HTTP.END_RESPONSE(v_Response);

    DBMS_OUTPUT.PUT_LINE('Notification sent successfully to ');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred while sending notification: ');
END;
/
