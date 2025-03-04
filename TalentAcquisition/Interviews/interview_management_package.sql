--Interview Management Package

CREATE OR REPLACE PACKAGE InterviewManagement AS
    PROCEDURE ScheduleInterview(
        p_CandidateID IN NUMBER,
        p_JobID IN NUMBER,
        p_InterviewerName IN VARCHAR2,
        p_InterviewDate IN DATE,
        p_InterviewTime IN VARCHAR2
    );

    PROCEDURE UpdateInterviewStatus(
        p_InterviewID IN NUMBER,
        p_NewStatus IN VARCHAR2
    );

    PROCEDURE LogFeedback(
        p_InterviewID IN NUMBER,
        p_CandidateID IN NUMBER,
        p_FeedbackText IN CLOB,
        p_Rating IN NUMBER
    );

    PROCEDURE FetchInterviews(
        p_FilterCondition IN VARCHAR2,
        p_Result OUT SYS_REFCURSOR
    );

    PROCEDURE DeleteInterview(
        p_InterviewID IN NUMBER
    );
END InterviewManagement;
/

CREATE OR REPLACE PACKAGE BODY InterviewManagement AS
    PROCEDURE ScheduleInterview (
        p_CandidateID IN NUMBER,
        p_JobID IN NUMBER,
        p_InterviewerName IN VARCHAR2,
        p_InterviewDate IN DATE,
        p_InterviewTime IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Interviews (
            InterviewID, CandidateID, JobID, InterviewerName, InterviewDate, InterviewTime, InterviewStatus, LastUpdated
        ) VALUES (
            Interview_SEQ.NEXTVAL, p_CandidateID, p_JobID, p_InterviewerName, p_InterviewDate, p_InterviewTime, 'Scheduled', SYSDATE
        );

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Interview scheduled successfully.');
    END ScheduleInterview;

    PROCEDURE UpdateInterviewStatus (
        p_InterviewID IN NUMBER,
        p_NewStatus IN VARCHAR2
    ) IS
    BEGIN
        UPDATE Interviews
        SET InterviewStatus = p_NewStatus,
            LastUpdated = SYSDATE
        WHERE InterviewID = p_InterviewID;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Interview status updated successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error occurred. Transaction rolled back.');
    END UpdateInterviewStatus;

    PROCEDURE LogFeedback (
        p_InterviewID IN NUMBER,
        p_CandidateID IN NUMBER,
        p_FeedbackText IN CLOB,
        p_Rating IN NUMBER
    ) IS
    BEGIN
        IF p_Rating < 1 OR p_Rating > 5 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Rating must be between 1 and 5.');
        END IF;

        INSERT INTO InterviewFeedback (
            FeedbackID, InterviewID, CandidateID, FeedbackText, Rating, FeedbackDate
        ) VALUES (
            Feedback_SEQ.NEXTVAL, p_InterviewID, p_CandidateID, p_FeedbackText, p_Rating, SYSDATE
        );

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Feedback logged successfully.');
    END LogFeedback;

    PROCEDURE FetchInterviews (
        p_FilterCondition IN VARCHAR2,
        p_Result OUT SYS_REFCURSOR
    ) IS
        v_SQL VARCHAR2(4000);
    BEGIN
        v_SQL := 'SELECT * FROM Interviews WHERE ' p_FilterCondition;

        OPEN p_Result FOR v_SQL;

        DBMS_OUTPUT.PUT_LINE('Interview details fetched successfully.');
    END FetchInterviews;

    PROCEDURE DeleteInterview (
        p_InterviewID IN NUMBER
    ) IS
    BEGIN
        DELETE FROM InterviewFeedback WHERE InterviewID = p_InterviewID;

        DELETE FROM Interviews WHERE InterviewID = p_InterviewID;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Interview deleted successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error occurred. Transaction rolled back.');
    END DeleteInterview;
END InterviewManagement;
/
