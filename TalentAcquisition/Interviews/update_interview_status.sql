--interview status with nested conditions.

CREATE OR REPLACE PROCEDURE UpdateInterviewStatusWithConditions (
    p_InterviewID IN NUMBER,
    p_NewStatus IN VARCHAR2
) IS
    v_CurrentStatus VARCHAR2(20);
BEGIN
    SELECT InterviewStatus INTO v_CurrentStatus FROM Interviews WHERE InterviewID = p_InterviewID;

    IF v_CurrentStatus = 'Scheduled' THEN
        IF p_NewStatus = 'Completed' THEN
            UPDATE Interviews
            SET InterviewStatus = p_NewStatus,
                LastUpdated = SYSDATE
            WHERE InterviewID = p_InterviewID;

            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Interview status updated to Completed.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Invalid status transition.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Interview is not in Scheduled status.');
    END IF;
END;
/

--Log feedback for multiple interviews in a single transaction.

CREATE OR REPLACE PROCEDURE BulkLogFeedback (
    p_InterviewIDs IN SYS.ODCINUMBERLIST,
    p_FeedbackText IN CLOB,
    p_Rating IN NUMBER
) IS
BEGIN
    FOR i IN 1 .. p_InterviewIDs.COUNT LOOP
        INSERT INTO InterviewFeedback (
            FeedbackID, InterviewID, CandidateID, FeedbackText, Rating, FeedbackDate
        ) VALUES (
            Feedback_SEQ.NEXTVAL, p_InterviewIDs(i), NULL, p_FeedbackText, p_Rating, SYSDATE
        );
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Bulk feedback logged successfully.');
END;
/

