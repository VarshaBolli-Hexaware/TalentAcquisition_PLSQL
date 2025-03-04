--Add an ExpirationDate column to the Offers table.

ALTER TABLE Offers ADD ExpirationDate DATE;

--Automatically expire offers that have passed their expiration date.

CREATE OR REPLACE PROCEDURE ExpireOffers IS
BEGIN
    UPDATE Offers
    SET OfferStatus = 'Expired'
    WHERE OfferStatus = 'Pending' AND ExpirationDate < SYSDATE;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Expired pending offers successfully.');
END;
/

--Scheduler Job for Offer Expiration
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'ExpireOffersJob',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN ExpireOffers; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled         => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Offer expiration job created successfully.');
END;
/
