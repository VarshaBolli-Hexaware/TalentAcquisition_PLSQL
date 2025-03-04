--Function to Get Job Count by Status and Age

ALTER TABLE Jobs ADD Status VARCHAR2(20);

CREATE OR REPLACE FUNCTION GetJobCountByStatusAndAge (
    p_Status IN VARCHAR2,
    p_Age IN NUMBER
) RETURN NUMBER IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM Jobs
    WHERE Status = p_Status
      AND PostedDate >= SYSDATE - p_Age;

    RETURN v_Count;
END;
/

DECLARE
    v_Count NUMBER;
BEGIN
    v_Count := GetJobCountByStatusAndAge('Open', 30);
    DBMS_OUTPUT.PUT_LINE('Number of Open jobs posted in the last 30 days: ');
END;
/
