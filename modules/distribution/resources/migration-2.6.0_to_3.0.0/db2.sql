CREATE TABLE AM_SYSTEM_APPS (
       ID INTEGER NOT NULL,
       NAME VARCHAR(50) NOT NULL,
       CONSUMER_KEY VARCHAR(512) NOT NULL,
       CONSUMER_SECRET VARCHAR(512) NOT NULL,
       CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (ID)
)
/

CREATE SEQUENCE AM_SYSTEM_APPS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER AM_SYSTEM_APPS_TRIGGER NO CASCADE BEFORE INSERT ON AM_SYSTEM_APPS
REFERENCING NEW AS NEW FOR EACH ROW MODE DB2SQL
  BEGIN ATOMIC
    SET (NEW.ID)
    = (NEXTVAL FOR AM_SYSTEM_APPS_SEQUENCE);
  END
/

CREATE TABLE AM_API_CLIENT_CERTIFICATE (
  TENANT_ID INT NOT NULL,
  ALIAS VARCHAR(45) NOT NULL,
  API_ID INTEGER NOT NULL,
  CERTIFICATE BLOB NOT NULL,
  REMOVED SMALLINT NOT NULL DEFAULT 0,
  TIER_NAME VARCHAR (512),
  FOREIGN KEY (API_ID) REFERENCES AM_API (API_ID) ON DELETE CASCADE,
  PRIMARY KEY (ALIAS, TENANT_ID, REMOVED)
)
/

ALTER TABLE AM_POLICY_SUBSCRIPTION 
  ADD MONETIZATION_PLAN VARCHAR(25) DEFAULT NULL
  ADD FIXED_RATE VARCHAR(15) DEFAULT NULL
  ADD BILLING_CYCLE VARCHAR(15) DEFAULT NULL 
  ADD PRICE_PER_REQUEST VARCHAR(15) DEFAULT NULL 
  ADD CURRENCY VARCHAR(15) DEFAULT NULL
/
CREATE TABLE AM_MONETIZATION_USAGE_PUBLISHER (
	ID VARCHAR(100) NOT NULL,
	STATE VARCHAR(50) NOT NULL,
	STATUS VARCHAR(50) NOT NULL,
	STARTED_TIME VARCHAR(50) NOT NULL,
	PUBLISHED_TIME VARCHAR(50) NOT NULL,
	PRIMARY KEY(ID)
)/

ALTER TABLE AM_API_COMMENTS
    ALTER COLUMN COMMENT_ID
    SET DATA TYPE VARCHAR(255) NOT NULL
/

ALTER TABLE AM_API_RATINGS
    ALTER COLUMN RATING_ID
    SET DATA TYPE VARCHAR(255) NOT NULL
/

CREATE TABLE IF NOT EXISTS AM_NOTIFICATION_SUBSCRIBER (
    UUID VARCHAR(255) NOT NULL,
    CATEGORY VARCHAR(255) NOT NULL,
    NOTIFICATION_METHOD VARCHAR(255) NOT NULL,
    SUBSCRIBER_ADDRESS VARCHAR(255) NOT NULL,
    PRIMARY KEY(UUID, SUBSCRIBER_ADDRESS)
)
 /

ALTER TABLE AM_EXTERNAL_STORES
ADD LAST_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP
/

ALTER TABLE AM_API
  ADD API_TYPE VARCHAR(10) NULL DEFAULT NULL
/

CREATE TABLE AM_API_PRODUCT_MAPPING (
  API_PRODUCT_MAPPING_ID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  API_ID INTEGER,
  URL_MAPPING_ID INTEGER,
  FOREIGN KEY (API_ID) REFERENCES AM_API(API_ID) ON DELETE CASCADE,
  FOREIGN KEY (URL_MAPPING_ID) REFERENCES AM_API_URL_MAPPING(URL_MAPPING_ID) ON DELETE CASCADE,
  PRIMARY KEY(API_PRODUCT_MAPPING_ID)
)
/

-- Start of Data Migration Scripts --
-- DB2 doesn't have an inbuilt function to generate a UUID. --
-- Make sure you have registered the jar file which does the logic as guided in the doc. --

CREATE OR REPLACE FUNCTION RANDOMUUID()
  RETURNS VARCHAR(36)
  LANGUAGE JAVA
  PARAMETER STYLE JAVA
  NOT DETERMINISTIC NO EXTERNAL ACTION NO SQL
  EXTERNAL NAME 'UUIDUDFJAR:UUIDUDF.randomUUID' ;
/

UPDATE AM_API_RATINGS SET RATING_ID=(RANDOMUUID())
/
UPDATE AM_API_COMMENTS SET COMMENT_ID=(RANDOMUUID())
/

CREATE TABLE AM_REVOKED_JWT (
  UUID VARCHAR(255) NOT NULL,
  SIGNATURE VARCHAR(2048) NOT NULL,
  EXPIRY_TIMESTAMP BIGINT NOT NULL,
  TENANT_ID INTEGER DEFAULT -1,
  TOKEN_TYPE VARCHAR(15) DEFAULT 'DEFAULT',
  TIME_CREATED TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (UUID)
)
/
