-- Send automated reminders to candidates using DBMS_SCHEDULER.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'InterviewReminderJob',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN DBMS_OUTPUT.PUT_LINE(''Reminder: Interview scheduled tomorrow.''); END;',
        start_date => SYSDATE + INTERVAL '1' DAY,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Interview reminder job created successfully.');
END;
/

--Use UTL_SMTP to send email notifications for interview schedules.

CREATE OR REPLACE PROCEDURE SendInterviewNotification (
    p_CandidateEmail IN VARCHAR2,
    p_InterviewDetails IN VARCHAR2
) IS
    v_MailHost VARCHAR2(100) := 'smtp.example.com';
    v_MailPort NUMBER := 25;
    v_Connection UTL_SMTP.CONNECTION;
BEGIN
    v_Connection := UTL_SMTP.OPEN_CONNECTION(v_MailHost, v_MailPort);
    UTL_SMTP.HELO(v_Connection, 'example.com');
    UTL_SMTP.MAIL(v_Connection, 'hr@example.com');
    UTL_SMTP.RCPT(v_Connection, p_CandidateEmail);
    UTL_SMTP.DATA(v_Connection,  p_InterviewDetails);
    UTL_SMTP.QUIT(v_Connection);

    DBMS_OUTPUT.PUT_LINE('Notification sent to ');
END;
/

