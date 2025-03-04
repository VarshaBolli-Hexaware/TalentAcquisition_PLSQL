--Enhancing Feedback Table

--Add a Rating column to the OnboardingFeedback table to capture candidate satisfaction scores.

ALTER TABLE OnboardingFeedback
ADD Rating NUMBER(1) CHECK (Rating BETWEEN 1 AND 5);

--Procedure to Collect Feedback with Rating
CREATE OR REPLACE PROCEDURE CollectFeedbackWithRating (
    p_OnboardingID IN NUMBER,
    p_CandidateID IN NUMBER,
    p_FeedbackText IN CLOB,
    p_Rating IN NUMBER
) IS
BEGIN
    -- Validate rating
    IF p_Rating < 1 OR p_Rating > 5 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Rating must be between 1 and 5.');
    END IF;

    -- Insert feedback
    INSERT INTO OnboardingFeedback (
        FeedbackID, OnboardingID, CandidateID, FeedbackText, FeedbackDate, Rating
    ) VALUES (
        Feedback_SEQ.NEXTVAL, p_OnboardingID, p_CandidateID, p_FeedbackText, SYSDATE, p_Rating
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Feedback and rating submitted successfully for OnboardingID: ' p_OnboardingID);
END;
/

--Procedure to Calculate Average Feedback Rating
CREATE OR REPLACE FUNCTION CalculateAverageRating (
    p_OnboardingID IN NUMBER
) RETURN NUMBER IS
    v_AverageRating NUMBER;
BEGIN
    SELECT AVG(Rating)
    INTO v_AverageRating
    FROM OnboardingFeedback
    WHERE OnboardingID = p_OnboardingID;

    RETURN v_AverageRating;
END;
/

--Notofy HR for low rating
CREATE OR REPLACE TRIGGER NotifyHRLowRating
AFTER INSERT ON OnboardingFeedback
FOR EACH ROW
WHEN (NEW.Rating <= 2)
DECLARE
    v_Email VARCHAR2(100);
    v_Message CLOB;
BEGIN
    SELECT Email INTO v_Email
    FROM HRTeam
    WHERE Role = 'Recruiter';

    v_Message := 'Low feedback rating received for OnboardingID: ' :NEW.OnboardingID                 '. Rating: ' :NEW.Rating                 '. Feedback: ' :NEW.FeedbackText;

    -- Use UTL_SMTP or UTL_HTTP to send notification
    NotifyHR(v_Email, v_Message);
END;
/
