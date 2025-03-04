-- onboarding workflow

CREATE OR REPLACE PROCEDURE onboarding_workflow AS
    v_status VARCHAR2(4000);  -- Variable to hold the status message

BEGIN

	-- Calling Interview files from onboarding
	--Notify feedback to candidates
	NotifyCandidateViaHTTP;
	
	--offers
	automatic_offer_creation;
	
    candidate_offer_notifications;

    candidate_offers;
	
    offer_acc_rej;

    offer_api;
	
    offer_expiration_management;

    track_offer_statuses;
	
	bgv_mails;
	
	--onboarding
	automate_onboarding;
	
	feedback_post_onb;
	
	feedback_postonboard;
	
	fetch_onboard_data for_hr;
	
	oboarding;
	
	pending_onboard_reminders;
    

END onboarding_workflow;
/