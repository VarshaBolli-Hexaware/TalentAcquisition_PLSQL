--Automate Reminders for Pending Onboarding Tasks
--Send Reminder for Pending Tasks

CREATE OR REPLACE PROCEDURE SendOnboardingReminder IS
    CURSOR pending_cursor IS
        SELECT CandidateID, OnboardingID, OnboardingStatus
        FROM Onboarding
        WHERE OnboardingStatus = 'Pending';
    v_Email VARCHAR2(100);
    v_Message CLOB;
BEGIN
    FOR rec IN pending_cursor LOOP
        SELECT Email INTO v_Email
        FROM Candidates
        WHERE CandidateID = rec.CandidateID;

        v_Message := 'Dear Candidate, your onboarding process is still pending. Please complete the required tasks as soon as possible.';

        -- Use UTL_SMTP to send email
        NotifyCandidate(v_Email, v_Message);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Reminders sent for pending onboarding tasks.');
END;
/

--Scheduler Job for Sending Reminders
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SendOnboardingReminderJob',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN SendOnboardingReminder; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled         => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Reminder job for pending onboarding tasks created successfully.');
END;
/
