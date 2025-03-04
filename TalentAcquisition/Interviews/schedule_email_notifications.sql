-- schedule an email notification to be sent to a candidate.

CREATE OR REPLACE PROCEDURE SendEmailNotification (
    p_Email IN VARCHAR2,
    p_Subject IN VARCHAR2,
    p_Body IN VARCHAR2
) IS
    v_Conn UTL_SMTP.CONNECTION;
BEGIN
    v_Conn := UTL_SMTP.OPEN_CONNECTION('smtp.example.com', 25);
    UTL_SMTP.HELO(v_Conn, 'example.com');
    UTL_SMTP.MAIL(v_Conn, 'recruitment@example.com');
    UTL_SMTP.RCPT(v_Conn, p_Email);
    UTL_SMTP.DATA(v_Conn, p_Body);
    UTL_SMTP.QUIT(v_Conn);

    DBMS_OUTPUT.PUT_LINE('Email sent to ');
END;
/

-- Schedule Email Using DBMS_SCHEDULER:

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Send_Email_Job',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN SendEmailNotification(''candidate@example.com'', ''Interview Scheduled'', ''Your interview is scheduled for tomorrow.''); END;',
        start_date => SYSDATE + INTERVAL '1' HOUR,
        enabled => TRUE
    );
END;
/

-- send email notifications to candidates when their application status changes.

CREATE OR REPLACE TRIGGER NotifyCandidateOnStatusChange
AFTER UPDATE OF Status ON CandidateApplications
FOR EACH ROW
DECLARE
    v_Email VARCHAR2(100);
BEGIN
    SELECT Email INTO v_Email FROM Candidates WHERE CandidateID = :NEW.CandidateID;

    -- Send email notification
    UTL_SMTP.OPEN_CONNECTION('smtp.example.com', 25);
    -- Add email sending logic here
    DBMS_OUTPUT.PUT_LINE('Notification sent to  about status change to: ');
END;
/


