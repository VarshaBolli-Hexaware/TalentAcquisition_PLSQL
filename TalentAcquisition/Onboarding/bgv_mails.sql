--Notify Candidate via Email (UTL_SMTP)
CREATE OR REPLACE PROCEDURE NotifyCandidate (
    p_CandidateEmail IN VARCHAR2,
    p_Message IN CLOB
) IS
    v_MailHost VARCHAR2(100) := 'smtp.example.com';
    v_MailPort NUMBER := 25;
    v_Connection UTL_SMTP.CONNECTION;
BEGIN
    v_Connection := UTL_SMTP.OPEN_CONNECTION(v_MailHost, v_MailPort);
    UTL_SMTP.HELO(v_Connection, 'example.com');
    UTL_SMTP.MAIL(v_Connection, 'hr@example.com');
    UTL_SMTP.RCPT(v_Connection, p_CandidateEmail);
    UTL_SMTP.DATA(v_Connection,  p_Message);
    UTL_SMTP.QUIT(v_Connection);

    DBMS_OUTPUT.PUT_LINE('Notification sent to ');
END;
/

--Background Verification Service Call (UTL_HTTP)
CREATE OR REPLACE PROCEDURE BackgroundCheck (
    p_CandidateID IN NUMBER,
    p_BackgroundCheckURL IN VARCHAR2
) IS
    v_Response CLOB;
    v_Request UTL_HTTP.REQ;
    v_ResponseText VARCHAR2(4000);
BEGIN
    v_Request := UTL_HTTP.BEGIN_REQUEST(p_BackgroundCheckURL, 'GET', 'HTTP/1.1');
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

    DBMS_OUTPUT.PUT_LINE('Background check completed for CandidateID: ');
END;
/

CREATE OR REPLACE PROCEDURE call_bgv_mails AS
BEGIN
    NotifyCandidate;
	BackgroundCheck;
END;
/