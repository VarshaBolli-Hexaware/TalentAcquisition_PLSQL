-- send candidate data to an external API.

CREATE OR REPLACE PROCEDURE SendCandidateData (
    p_CandidateID IN NUMBER
) IS
    v_Url VARCHAR2(200) := 'https://api.example.com/candidates';
    v_HttpReq UTL_HTTP.REQ;
    v_HttpResp UTL_HTTP.RESP;
    v_ResponseText VARCHAR2(4000);
    v_CandidateData VARCHAR2(4000);
BEGIN
    SELECT JSON_OBJECT('CandidateID' VALUE CandidateID, 'FullName' VALUE FullName, 'Email' VALUE Email)
    INTO v_CandidateData
    FROM Candidates
    WHERE CandidateID = p_CandidateID;

    v_HttpReq := UTL_HTTP.BEGIN_REQUEST(v_Url, 'POST', 'HTTP/1.1');
    UTL_HTTP.SET_HEADER(v_HttpReq, 'Content-Type', 'application/json');
    UTL_HTTP.WRITE_TEXT(v_HttpReq, v_CandidateData);

    v_HttpResp := UTL_HTTP.GET_RESPONSE(v_HttpReq);
    UTL_HTTP.READ_TEXT(v_HttpResp, v_ResponseText);
    UTL_HTTP.END_RESPONSE(v_HttpResp);

    DBMS_OUTPUT.PUT_LINE('API Response: ');
END;
/
