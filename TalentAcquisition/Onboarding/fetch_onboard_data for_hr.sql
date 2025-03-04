--Linking Onboarding Progress Reports to HR Dashboard
--Database View for Real-Time Tracking

CREATE OR REPLACE VIEW HR_OnboardingProgress AS
SELECT 
    o.OnboardingID,
    c.CandidateID,
    c.CandidateName,
    jp.JobID,
    jp.JobTitle,
    o.OnboardingStatus,
    o.DocumentStatus,
    o.BackgroundCheckStatus,
    o.OrientationDate,
    o.SystemAccessStatus,
    o.LastUpdated
FROM 
    Onboarding o
JOIN Candidates c ON o.CandidateID = c.CandidateID
JOIN JobPostings jp ON o.JobID = jp.JobID;

-- retrieves onboarding progress data for the HR dashboard.
CREATE OR REPLACE PROCEDURE FetchOnboardingProgress (
    p_FilterCondition IN VARCHAR2 DEFAULT NULL,
    p_SortCondition IN VARCHAR2 DEFAULT 'OnboardingID ASC',
    p_Result OUT SYS_REFCURSOR
) IS
    v_SQL VARCHAR2(4000);
BEGIN
    v_SQL := 'SELECT * FROM HR_OnboardingProgress';
    
    -- Add filtering condition
    IF p_FilterCondition IS NOT NULL THEN
        v_SQL := v_SQL || ' WHERE ' || p_FilterCondition;
    END IF;

    -- Add sorting condition
    v_SQL := v_SQL || ' ORDER BY ' || p_SortCondition;

    -- Open cursor for result set
    OPEN p_Result FOR v_SQL;
END;
/

--Dynamic SQL for Advanced Filtering and Sorting
CREATE OR REPLACE PROCEDURE GenerateOnboardingReport (
    p_FilterCondition IN VARCHAR2 DEFAULT NULL,
    p_SortCondition IN VARCHAR2 DEFAULT 'OnboardingID ASC'
) IS
    v_SQL VARCHAR2(4000);
BEGIN
    v_SQL := 'SELECT * FROM HR_OnboardingProgress';

    -- Apply filtering condition
    IF p_FilterCondition IS NOT NULL THEN
        v_SQL := v_SQL || ' WHERE ' || p_FilterCondition;
    END IF;

    -- Apply sorting condition
    v_SQL := v_SQL || ' ORDER BY ' || p_SortCondition;

    -- Execute and display results
    FOR rec IN (EXECUTE IMMEDIATE v_SQL) LOOP
        DBMS_OUTPUT.PUT_LINE('OnboardingID: ' );
    END LOOP;
END;
/

BEGIN
    GenerateOnboardingReport('OnboardingStatus = ''Pending''', 'LastUpdated DESC');
END;
/

BEGIN
    GenerateOnboardingReport('JobID = 101', 'CandidateName ASC');
END;
/
