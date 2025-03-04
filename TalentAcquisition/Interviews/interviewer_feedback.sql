-- Allows interviewers to add feedback for a specific interview.

CREATE OR REPLACE PROCEDURE AddFeedback (
    p_InterviewID IN NUMBER,
    p_Interviewer IN VARCHAR2,
    p_Rating IN NUMBER,
    p_Comments IN CLOB
) IS
BEGIN
    INSERT INTO InterviewFeedback (
        FeedbackID, InterviewID, Interviewer, FeedbackDate, Rating, Comments
    ) VALUES (
        Feedback_SEQ.NEXTVAL, p_InterviewID, p_Interviewer, SYSDATE, p_Rating, p_Comments
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Feedback added successfully for InterviewID: ' );
END;
/

--Allows interviewers to update their feedback.

CREATE OR REPLACE PROCEDURE UpdateFeedback (
    p_FeedbackID IN NUMBER,
    p_NewRating IN NUMBER,
    p_NewComments IN CLOB
) IS
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    SELECT JSON_OBJECT('Rating' VALUE Rating, 'Comments' VALUE Comments)
    INTO v_OldData
    FROM InterviewFeedback
    WHERE FeedbackID = p_FeedbackID;

    UPDATE InterviewFeedback
    SET Rating = p_NewRating,
        Comments = p_NewComments,
        FeedbackDate = SYSDATE
    WHERE FeedbackID = p_FeedbackID;

    SELECT JSON_OBJECT('Rating' VALUE p_NewRating, 'Comments' VALUE p_NewComments)
    INTO v_NewData
    FROM DUAL;

    INSERT INTO FeedbackAudit (AuditID, FeedbackID, Action, ActionDate, OldData, NewData)
    VALUES (FeedbackAudit_SEQ.NEXTVAL, p_FeedbackID, 'Update', SYSDATE, v_OldData, v_NewData);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Feedback updated successfully for FeedbackID: ' );
END;
/

--Allows the deletion of feedback and logs the action in the audit table.

CREATE OR REPLACE PROCEDURE DeleteFeedback (
    p_FeedbackID IN NUMBER
) IS
    v_OldData CLOB;
BEGIN
    SELECT JSON_OBJECT('Rating' VALUE Rating, 'Comments' VALUE Comments)
    INTO v_OldData
    FROM InterviewFeedback
    WHERE FeedbackID = p_FeedbackID;

    DELETE FROM InterviewFeedback
    WHERE FeedbackID = p_FeedbackID;

    INSERT INTO FeedbackAudit (AuditID, FeedbackID, Action, ActionDate, OldData, NewData)
    VALUES (FeedbackAudit_SEQ.NEXTVAL, p_FeedbackID, 'Delete', SYSDATE, v_OldData, NULL);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Feedback deleted successfully for FeedbackID: ' );
END;
/

--Automatically logs changes to the InterviewFeedback table.

CREATE OR REPLACE TRIGGER FeedbackAuditTrigger
AFTER INSERT OR UPDATE OR DELETE ON InterviewFeedback
FOR EACH ROW
DECLARE
    v_Action VARCHAR2(50);
    v_OldData CLOB;
    v_NewData CLOB;
BEGIN
    IF INSERTING THEN
        v_Action := 'Insert';
        v_NewData := JSON_OBJECT('Rating' VALUE :NEW.Rating, 'Comments' VALUE :NEW.Comments);
    ELSIF UPDATING THEN
        v_Action := 'Update';
        v_OldData := JSON_OBJECT('Rating' VALUE :OLD.Rating, 'Comments' VALUE :OLD.Comments);
        v_NewData := JSON_OBJECT('Rating' VALUE :NEW.Rating, 'Comments' VALUE :NEW.Comments);
    ELSIF DELETING THEN
        v_Action := 'Delete';
        v_OldData := JSON_OBJECT('Rating' VALUE :OLD.Rating, 'Comments' VALUE :OLD.Comments);
    END IF;

    INSERT INTO FeedbackAudit (AuditID, FeedbackID, Action, ActionDate, OldData, NewData)
    VALUES (FeedbackAudit_SEQ.NEXTVAL, :OLD.FeedbackID, v_Action, SYSDATE, v_OldData, v_NewData);
END;
/
