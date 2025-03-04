-- Send reminders to interviewers for pending feedback using DBMS_SCHEDULER.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Feedback_Reminder_Job',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN DBMS_OUTPUT.PUT_LINE(''Reminder: Please submit feedback for pending interviews.''); END;',
        start_date => SYSDATE + INTERVAL '1' DAY,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Feedback reminder job created successfully.');
END;
/

--Notify Candidates of Feedback Results

CREATE OR REPLACE PROCEDURE NotifyCandidateViaHTTP (
    p_CandidateEmail IN VARCHAR2,
    p_FeedbackDetails IN VARCHAR2
) IS
    v_Url VARCHAR2(2000) := 'https://api.emailservice.com/send'; -- Replace with actual API endpoint
    v_Request UTL_HTTP.REQ;
    v_Response UTL_HTTP.RESP;
    v_ResponseText VARCHAR2(4000);
    v_Body CLOB;
BEGIN
    -- Prepare the JSON payload for the HTTP POST request
    v_Body := '{"to": "' || p_CandidateEmail ||'", "subject": "Interview Feedback", "body": "' ||p_FeedbackDetails ||'"}';

    -- Initialize the HTTP request
    v_Request := UTL_HTTP.BEGIN_REQUEST(v_Url, 'POST', 'HTTP/1.1');

    -- Set HTTP headers
    UTL_HTTP.SET_HEADER(v_Request, 'Content-Type', 'application/json');
    UTL_HTTP.SET_HEADER(v_Request, 'Authorization', 'Bearer YOUR_API_KEY'); -- Replace with actual API key

    -- Write the JSON payload to the HTTP request
    UTL_HTTP.WRITE_TEXT(v_Request, v_Body);

    -- Send the HTTP request and get the response
    v_Response := UTL_HTTP.GET_RESPONSE(v_Request);

    -- Read the response
    BEGIN
        LOOP
            UTL_HTTP.READ_TEXT(v_Response, v_ResponseText);
            DBMS_OUTPUT.PUT_LINE(v_ResponseText);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            NULL;
    END;

    -- Close the HTTP response
    UTL_HTTP.END_RESPONSE(v_Response);

    DBMS_OUTPUT.PUT_LINE('Notification sent successfully to ' || p_CandidateEmail);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred while sending notification: ' || SQLERRM);
END;
/

BEGIN
    NotifyCandidateViaHTTP(
        'candidate@example.com',
        'Dear Candidate, thank you for attending the interview. Here is your feedback: Excellent communication skills and strong technical knowledge.'
    );
END;
/


