--Tables for Job Postings

CREATE TABLE Jobs (
    JobID NUMBER PRIMARY KEY,
    JobTitle VARCHAR2(100),
    JobDescription CLOB,
    Department VARCHAR2(50),
    PostedDate DATE
);

-- Sequence for JobID
CREATE SEQUENCE Jobs_SEQ START WITH 1 INCREMENT BY 1;

--Tables for Candidate Management

CREATE TABLE Candidates (
    CandidateID NUMBER PRIMARY KEY,
    FullName VARCHAR2(100),
    Email VARCHAR2(100),
    Phone VARCHAR2(15),
    Resume BLOB,
    Status VARCHAR2(20), -- Applied, Shortlisted, Rejected, etc.
    CreatedDate DATE
);

-- Sequence for CandidateID
CREATE SEQUENCE Candidates_SEQ START WITH 1 INCREMENT BY 1;

--mapping table to associate candidates with job postings.

CREATE TABLE JobPostings (
    JobID NUMBER PRIMARY KEY,
    JobTitle VARCHAR2(100),
    JobDescription CLOB,
    Department VARCHAR2(50),
    Location VARCHAR2(50),
    PostedDate DATE,
    Status VARCHAR2(20) -- Open, Closed, etc.
);

-- Sequence for JobID
CREATE SEQUENCE JobPostings_SEQ START WITH 1 INCREMENT BY 1;


-- map candidates to job postings.

CREATE TABLE CandidateApplications (
    ApplicationID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    JobID NUMBER REFERENCES JobPostings(JobID),
    ApplicationDate DATE,
    Status VARCHAR2(20) -- Applied, Shortlisted, Rejected, etc.
);

-- Sequence for ApplicationID
CREATE SEQUENCE CandidateApplications_SEQ START WITH 1 INCREMENT BY 1;


-- Stores details of scheduled interviews.
CREATE TABLE Interviews (
    InterviewID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    JobID NUMBER REFERENCES JobPostings(JobID),
    InterviewDate DATE,
    InterviewTime VARCHAR2(10),
    Interviewer VARCHAR2(100),
    InterviewStatus VARCHAR2(20), -- Scheduled, Completed, Rescheduled, Cancelled
    Notes CLOB,
	 LastUpdated DATE
);

CREATE SEQUENCE Interviews_SEQ START WITH 1 INCREMENT BY 1;

-- Audit Table Tracks changes to interview schedules for auditing purposes.

CREATE TABLE InterviewAudit (
    AuditID NUMBER PRIMARY KEY,
    InterviewID NUMBER REFERENCES Interviews(InterviewID),
    Action VARCHAR2(50), -- Insert, Update, Delete
    ActionDate DATE,
    OldData CLOB,
    NewData CLOB
);

CREATE SEQUENCE InterviewAudit_SEQ START WITH 1 INCREMENT BY 1;

--Stores feedback provided by interviewers.

CREATE TABLE InterviewFeedback (
    FeedbackID NUMBER PRIMARY KEY,
    InterviewID NUMBER REFERENCES Interviews(InterviewID),
    Interviewer VARCHAR2(100),
	CandidateID NUMBER REFERENCES Candidates(CandidateID),
    FeedbackDate DATE,
    Rating NUMBER(1), -- Scale of 1 to 5
    Comments CLOB
);

CREATE SEQUENCE Feedback_SEQ START WITH 1 INCREMENT BY 1;

--Tracks changes to feedback for auditing purposes.

CREATE TABLE FeedbackAudit (
    AuditID NUMBER PRIMARY KEY,
    FeedbackID NUMBER REFERENCES InterviewFeedback(FeedbackID),
    Action VARCHAR2(50), -- Insert, Update, Delete
    ActionDate DATE,
    OldData CLOB,
    NewData CLOB
);

CREATE SEQUENCE FeedbackAudit_SEQ START WITH 1 INCREMENT BY 1;


--Stores details of job offers sent to candidates.

CREATE TABLE Offers (
    OfferID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    JobID NUMBER REFERENCES JobPostings(JobID),
    OfferDate DATE,
    OfferStatus VARCHAR2(20), -- Pending, Accepted, Rejected, Withdrawn
    OfferDetails CLOB,
    LastUpdated DATE
);

CREATE SEQUENCE Offers_SEQ START WITH 1 INCREMENT BY 1;

--Tracks changes to job offers for auditing purposes.

CREATE TABLE OfferAudit (
    AuditID NUMBER PRIMARY KEY,
    OfferID NUMBER REFERENCES Offers(OfferID),
    Action VARCHAR2(50), -- Insert, Update, Delete
    ActionDate DATE,
    OldData CLOB,
    NewData CLOB
);

CREATE SEQUENCE OfferAudit_SEQ START WITH 1 INCREMENT BY 1;

-- Onboarding Table

CREATE TABLE Onboarding (
    OnboardingID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    JobID NUMBER REFERENCES JobPostings(JobID),
    OnboardingStatus VARCHAR2(20), -- Pending, Completed, In Progress
    DocumentStatus VARCHAR2(20), -- Pending, Verified, Rejected
    BackgroundCheckStatus VARCHAR2(20), -- Pending, Cleared, Failed
    OrientationDate DATE,
    SystemAccessStatus VARCHAR2(20), -- Pending, Completed
    LastUpdated DATE
);

CREATE SEQUENCE Onboarding_SEQ START WITH 1 INCREMENT BY 1;

--Tracks changes to onboarding details for auditing purposes.

CREATE TABLE OnboardingAudit (
    AuditID NUMBER PRIMARY KEY,
    OnboardingID NUMBER REFERENCES Onboarding(OnboardingID),
    Action VARCHAR2(50), -- Insert, Update, Delete
    ActionDate DATE,
    OldData CLOB,
    NewData CLOB
);

CREATE SEQUENCE OnboardingAudit_SEQ START WITH 1 INCREMENT BY 1;

--store feedback from candidates after completing onboarding.
CREATE TABLE OnboardingFeedback (
    FeedbackID NUMBER PRIMARY KEY,
    OnboardingID NUMBER REFERENCES Onboarding(OnboardingID),
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    FeedbackText CLOB,
    FeedbackDate DATE
);

CREATE SEQUENCE Feedback_SEQ START WITH 1 INCREMENT BY 1;

--Tracks communication and interactions with candidates.

CREATE TABLE CandidateInteractions (
    InteractionID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    InteractionType VARCHAR2(50), -- Email, Call, Meeting
    InteractionDate DATE,
    Notes CLOB
);

CREATE SEQUENCE Interaction_SEQ START WITH 1 INCREMENT BY 1;

CREATE TABLE HRTeam (
    Email VARCHAR2(100),
    Role VARCHAR2(50)
);

--Recruitment Workflow

CREATE OR REPLACE PROCEDURE recruitment_process_workflow AS
    v_status VARCHAR2(4000);  -- Variable to hold the status message

BEGIN
	
	-- call jobs and jobpostings modeules
    job_postings_workflow;
		
	-- call Interview modeules
    interviews_workflow;
	
	-- call Onboarding modeules
    onboarding_workflow;

END recruitment_process_workflow;
/
