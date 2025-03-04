-- Collect Feedback
CREATE OR REPLACE PROCEDURE CollectOnboardingFeedback (
    p_OnboardingID IN NUMBER,
    p_CandidateID IN NUMBER,
    p_FeedbackText IN CLOB
) IS
BEGIN
    INSERT INTO OnboardingFeedback (
        FeedbackID, OnboardingID, CandidateID, FeedbackText, FeedbackDate
    ) VALUES (
        Feedback_SEQ.NEXTVAL, p_OnboardingID, p_CandidateID, p_FeedbackText, SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Feedback collected successfully for OnboardingID: ');
END;
/

--Notify HR Upon Feedback Submission

CREATE OR REPLACE TRIGGER NotifyHROnFeedback
AFTER INSERT ON OnboardingFeedback
FOR EACH ROW
DECLARE
    v_Email VARCHAR2(100);
    v_Message CLOB;
BEGIN
    SELECT Email INTO v_Email
    FROM HRTeam
    WHERE Role = 'Recruiter';

    v_Message := 'Feedback submitted for OnboardingID:  Please review the feedback in the system.';

    -- Use UTL_SMTP or UTL_HTTP to send notification
    NotifyHR(v_Email, v_Message);
END;
/
