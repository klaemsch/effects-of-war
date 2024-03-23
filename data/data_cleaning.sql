-- make column GLOBALEVENTID primary key and unique
ALTER TABLE events
ADD CONSTRAINT pk_unique_global_event_id PRIMARY KEY (GLOBALEVENTID);


-- if column source domain doesnt exist yet, create it:
-- ALTER TABLE events ADD COLUMN source_domain TEXT;


UPDATE events
SET source_domain = 
    SUBSTR(SOURCEURL, INSTR(SOURCEURL, '://') + 3, INSTR(SUBSTR(SOURCEURL, INSTR(SOURCEURL, '://') + 3), '/') - 1);

UPDATE events
	SET source_domain = SUBSTR(source_domain, 1, INSTR(source_domain, ':') - 1)
	WHERE source_domain LIKE '%:%';