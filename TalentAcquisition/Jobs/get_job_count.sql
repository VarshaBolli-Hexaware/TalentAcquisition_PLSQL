--Function to Get Job Count by Department
CREATE OR REPLACE FUNCTION GetJobCountByDepartment (
    p_Department IN VARCHAR2
) RETURN NUMBER IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM Jobs
    WHERE Department = p_Department;

    RETURN v_Count;
END;
/
DECLARE
    v_JobCount NUMBER;
BEGIN
    v_JobCount := GetJobCountByDepartment('IT');
    DBMS_OUTPUT.PUT_LINE('Number of jobs in IT: ');
END;
/
