--Retrieve Feedback for a Candidate: Fetch feedback for all interviews a candidate has attended.

CREATE OR REPLACE PROCEDURE GetCandidateFeedback (
    p_CandidateID IN NUMBER
) IS
BEGIN
    FOR rec IN (SELECT f.FeedbackID, f.Rating, f.Comments, f.FeedbackDate
                FROM InterviewFeedback f
                JOIN Interviews i ON f.InterviewID = i.InterviewID
                WHERE i.CandidateID = p_CandidateID) LOOP
        DBMS_OUTPUT.PUT_LINE('FeedbackID: ');
    END LOOP;
END;
/

--Generate Feedback Summary for a Job Posting: Summarize feedback for all candidates who applied for a specific job.

CREATE OR REPLACE PROCEDURE GetJobFeedbackSummary (
    p_JobID IN NUMBER
) IS
    v_AvgRating NUMBER;
BEGIN
    SELECT AVG(f.Rating)
    INTO v_AvgRating
    FROM InterviewFeedback f
    JOIN Interviews i ON f.InterviewID = i.InterviewID
    WHERE i.JobID = p_JobID;

    DBMS_OUTPUT.PUT_LINE('Average Feedback Rating for JobID ');
END;
/

--Fetch feedback dynamically based on custom filtering criteria.

CREATE OR REPLACE PROCEDURE GetFeedbackDynamic (
    p_FilterCondition IN VARCHAR2
) IS
    v_SQL VARCHAR2(4000);
   
    -- Define a collection type
    TYPE t_FeedbackTable IS TABLE OF InterviewFeedback%ROWTYPE;
    v_FeedbackTable t_FeedbackTable;
BEGIN
    -- Construct dynamic SQL
    v_SQL := 'SELECT FeedbackID, Rating, Comments FROM InterviewFeedback WHERE ' || p_FilterCondition;

    -- Execute dynamic SQL and fetch results into collection
    EXECUTE IMMEDIATE v_SQL BULK COLLECT INTO v_FeedbackTable;

    -- Loop through the collection and print results
    FOR i IN 1..v_FeedbackTable.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('FeedbackID: ' || v_FeedbackTable(i).FeedbackID ||
                             ', Rating: ' || v_FeedbackTable(i).Rating ||
                             ', Comments: ' || DBMS_LOB.SUBSTR(v_FeedbackTable(i).Comments, 100));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
