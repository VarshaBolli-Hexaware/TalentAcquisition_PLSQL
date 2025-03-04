-- jobpostings workflow

CREATE OR REPLACE PROCEDURE job_postings_workflow AS
    v_status VARCHAR2(4000);  -- Variable to hold the status message

BEGIN

	-- call jobs and jobpostings modeules

	-- allows a candidate to apply for a specific job posting, updates job status, retrieves all info of candidates applied to jobs
    applyforJob;
	
	-- archieves old jobs
    archive_old_jobs;
	
	-- Exports job details to a file using UTL_file
    expot_job_details;
	
	-- Generate reports to analyze candidate applications and job postings.
    generate_cand_reports;
	
	-- Displays jobs by department
    get_job_count;
	
	-- Displays jobs by status, age
    get_jobcount_by_status_age;
	
	-- Create/update/delete/view jobs
    job_postings;
	
	-- log every job posting into an audit table
    job_postings_audit_log;
	
	-- print all job postings grouped by their status (e.g., Open, Closed) using nested loops
    job_postings_with_status;
	
	-- Search jobs by Title
    search_jobs_by_title;
	
	-- automatically update the Status column of the Jobs table when a job is marked as "Closed."
    update_status_on_job_closure;
	
	-------------------candidates
	
	-- bulk insertion of candidates into the Candidates table using the FORALL construct for better performance.
    bulk_insert_cands;
	
	-- bulk uploading of resumes for multiple candidates.
    bulk_upload_resumes;
	
	-- Logs candidate details and interactions
    cand_interaction;
	
	-- Candidate Management Package
    cand_management;
	
	-- resumes compressed before storing them in the database and decompressed when needed.
    cand_resume_compression;
	
	-- To ensure the security of resumes, they can be encrypted before storing and decrypted when accessed.
    cand_resume_encrypt;
	
	-- CRUD operations on candidates table.
    candidate_dml;
	
	-- process candidates based on their status and perform different actions.
    candidate_processing;
	
	-- export candidate details to a text file.
    export_candidate_details;
	
	-- export resumes to external files
    export_resume;
	
	-- log any changes to the Status column of the Candidates table and returns #of candidates based on status
    get_cands_status;
	
	-- log errors into an ErrorLog table using an autonomous transaction.
    logerrors_cands;
	
	-- process candidates in parallel batches to improve performance.
    process-cands;
	
	-- To maintain a history of resumes uploaded by candidates, we can implement a versioning system.
    resume_versioning;
	
	-- read and write large resumes stored as LOBs.
    resumes_lob;
	
	-- search for candidates by name.
    search_candidates;
	
	-- send candidate data to an external API.
    send_candidate_data_api;
	
	-- upload_cand_resume
    upload_cand_resume;
	   
END job_postings_workflow;
/