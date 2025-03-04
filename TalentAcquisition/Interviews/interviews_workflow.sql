-- interviews workflow

CREATE OR REPLACE PROCEDURE interviews_workflow AS
    v_status VARCHAR2(4000);  -- Variable to hold the status message

BEGIN

	-- calling procedure from candidates
	-- send candidate data to an external API.
    SendCandidateData;

	-- Interviews
    cand_status;

    cands_interview_scheduling;
	
    feedback_analysis;

    feedback_results;
	
    interview_management_package;

    interview_reminders;
	
    interviewer_feedback;

    schedule_email_notifications;
	
    schedule_interview_tcl;

    update_interview_status;
	
END interviews_workflow;
/