---cands_interview_scheduling 
-- Schedules a new interview for a candidate.

CREATE OR REPLACE PROCEDURE ScheduleInterviews (
    p_CandidateID IN NUMBER,
    p_JobID IN NUMBER,
    p_InterviewDate IN DATE,
    p_InterviewTime IN VARCHAR2,
    p_Interviewer IN VARCHAR2,
    p_Notes IN CLOB
) IS
BEGIN
    INSERT INTO Interviews (
        InterviewID, CandidateID, JobID, InterviewDate, InterviewTime, Interviewer, InterviewStatus, Notes
    ) VALUES (
        Interviews_SEQ.NEXTVAL, p_CandidateID, p_JobID, p_InterviewDate, p_InterviewTime, p_Interviewer, 'Scheduled', p_Notes
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Interview scheduled successfully for CandidateID: ');
END;
/

-- Reschedule an Interview
-- Updates the date and time of an existing interview.

CREATE OR REPLACE PROCEDURE RescheduleInterview (
    p_InterviewID IN NUMBER,
    p_NewInterviewDate IN DATE,
    p_NewInterviewTime IN VARCHAR2
) IS
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    -- Fetch old interview details as JSON
    SELECT '{ "InterviewDate": "' || TO_CHAR(InterviewDate, 'YYYY-MM-DD') ||
           '", "InterviewTime": "' || InterviewTime || '" }'
    INTO v_OldData
    FROM Interviews
    WHERE InterviewID = p_InterviewID;

    -- Update the interview details
    UPDATE Interviews
    SET InterviewDate = p_NewInterviewDate,
        InterviewTime = p_NewInterviewTime,
        InterviewStatus = 'Rescheduled'
    WHERE InterviewID = p_InterviewID;

    -- Set new JSON-formatted data manually
    v_NewData := '{ "InterviewDate": "' || TO_CHAR(p_NewInterviewDate, 'YYYY-MM-DD') ||
                  '", "InterviewTime": "' || p_NewInterviewTime || '" }';

    -- Insert audit record
    INSERT INTO InterviewAudit (AuditID, InterviewID, Action, ActionDate, OldData, NewData)
    VALUES (InterviewAudit_SEQ.NEXTVAL, p_InterviewID, 'Update', SYSDATE, v_OldData, v_NewData);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Interview rescheduled successfully for InterviewID: ' || p_InterviewID);
END;
/


--  schedule interviews for shortlisted candidates.
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Interview_Schedule_Job',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN DBMS_OUTPUT.PUT_LINE(''Interview scheduled for CandidateID 1''); END;',
        start_date => SYSDATE + INTERVAL '1' DAY,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled => TRUE
    );
END;
/


-- Cancels an interview and logs the action in the audit table.

CREATE OR REPLACE PROCEDURE CancelInterview (
    p_InterviewID IN NUMBER
) IS
    v_OldData CLOB;
BEGIN
    -- Fetch old interview details and construct JSON manually
    SELECT '{ "InterviewDate": "' || TO_CHAR(InterviewDate, 'YYYY-MM-DD') ||
           '", "InterviewTime": "' || InterviewTime ||
           '", "Interviewer": "' || Interviewer || '" }'
    INTO v_OldData
    FROM Interviews
    WHERE InterviewID = p_InterviewID;

    -- Delete the interview
    DELETE FROM Interviews
    WHERE InterviewID = p_InterviewID;

    -- Insert audit record
    INSERT INTO InterviewAudit (AuditID, InterviewID, Action, ActionDate, OldData, NewData)
    VALUES (InterviewAudit_SEQ.NEXTVAL, p_InterviewID, 'Delete', SYSDATE, v_OldData, NULL);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Interview cancelled successfully for InterviewID: ' || p_InterviewID);
END;
/


--Logs changes to the Interviews table automatically.

CREATE OR REPLACE TRIGGER InterviewAuditTrigger
AFTER INSERT OR UPDATE OR DELETE ON Interviews
FOR EACH ROW
DECLARE
    v_Action VARCHAR2(50);
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    IF INSERTING THEN
        v_Action := 'Insert';
        v_NewData := '{ "InterviewDate": "' || TO_CHAR(:NEW.InterviewDate, 'YYYY-MM-DD') ||
                      '", "InterviewTime": "' || :NEW.InterviewTime || '" }';

    ELSIF UPDATING THEN
        v_Action := 'Update';
        v_OldData := '{ "InterviewDate": "' || TO_CHAR(:OLD.InterviewDate, 'YYYY-MM-DD') ||
                      '", "InterviewTime": "' || :OLD.InterviewTime || '" }';
        v_NewData := '{ "InterviewDate": "' || TO_CHAR(:NEW.InterviewDate, 'YYYY-MM-DD') ||
                      '", "InterviewTime": "' || :NEW.InterviewTime || '" }';

    ELSIF DELETING THEN
        v_Action := 'Delete';
        v_OldData := '{ "InterviewDate": "' || TO_CHAR(:OLD.InterviewDate, 'YYYY-MM-DD') ||
                      '", "InterviewTime": "' || :OLD.InterviewTime || '" }';
    END IF;

    INSERT INTO InterviewAudit (AuditID, InterviewID, Action, ActionDate, OldData, NewData)
    VALUES (InterviewAudit_SEQ.NEXTVAL,
            COALESCE(:NEW.InterviewID, :OLD.InterviewID),
            v_Action,
            SYSDATE,
            v_OldData,
            v_NewData);

END;
/


--Fetch interviews based on dynamic filtering criteria.

CREATE OR REPLACE PROCEDURE GetInterviews (
    p_FilterCondition IN VARCHAR2
) IS
    v_SQL VARCHAR2(4000);
    v_InterviewID NUMBER;
    v_CandidateID NUMBER;
    v_JobID NUMBER;
    v_InterviewDate DATE;
    v_InterviewTime VARCHAR2(10);
BEGIN
    v_SQL := 'SELECT InterviewID, CandidateID, JobID, InterviewDate, InterviewTime FROM Interviews WHERE ' || p_FilterCondition;

    EXECUTE IMMEDIATE v_SQL INTO v_InterviewID, v_CandidateID, v_JobID, v_InterviewDate, v_InterviewTime;

    DBMS_OUTPUT.PUT_LINE('InterviewID: ');
END;
/