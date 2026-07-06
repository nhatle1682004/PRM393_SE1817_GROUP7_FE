CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS waste;
CREATE SCHEMA IF NOT EXISTS collection;
CREATE SCHEMA IF NOT EXISTS engagement;
CREATE EXTENSION IF NOT EXISTS postgis;

ALTER TABLE IF EXISTS public.roles SET SCHEMA identity;
ALTER TABLE IF EXISTS public.users SET SCHEMA identity;
ALTER TABLE IF EXISTS public.enterprise_profiles SET SCHEMA identity;
ALTER TABLE IF EXISTS public.collector_profiles SET SCHEMA identity;

ALTER TABLE IF EXISTS public.wastereports SET SCHEMA waste;
ALTER TABLE IF EXISTS waste.wastereports RENAME TO waste_reports;
ALTER TABLE IF EXISTS public.wastetypes SET SCHEMA waste;
ALTER TABLE IF EXISTS waste.wastetypes RENAME TO waste_types;
ALTER TABLE IF EXISTS public.report_waste_types SET SCHEMA waste;
ALTER TABLE IF EXISTS public.ai_waste_predictions SET SCHEMA waste;
ALTER TABLE IF EXISTS public.districts SET SCHEMA waste;

ALTER TABLE IF EXISTS public.collectionrequests SET SCHEMA collection;
ALTER TABLE IF EXISTS collection.collectionrequests RENAME TO collection_requests;
ALTER TABLE IF EXISTS public.collectorassignments SET SCHEMA collection;
ALTER TABLE IF EXISTS collection.collectorassignments RENAME TO collector_assignments;
ALTER TABLE IF EXISTS public.collectionconfirmations SET SCHEMA collection;
ALTER TABLE IF EXISTS collection.collectionconfirmations RENAME TO collection_confirmations;
ALTER TABLE IF EXISTS public.collection_details SET SCHEMA collection;

ALTER TABLE IF EXISTS public.notifications SET SCHEMA engagement;
ALTER TABLE IF EXISTS public.rewards SET SCHEMA engagement;
ALTER TABLE IF EXISTS public.rewardtransactions SET SCHEMA engagement;
ALTER TABLE IF EXISTS engagement.rewardtransactions RENAME TO reward_transactions;
ALTER TABLE IF EXISTS public.feedbacks SET SCHEMA engagement;

-- Columns introduced after the initial service split.  They are included here so
-- an existing public-schema database is immediately compatible with the current
-- EngagementService model without replaying create-table migrations.
ALTER TABLE IF EXISTS engagement.reward_transactions
    ADD COLUMN IF NOT EXISTS status character varying(20) NOT NULL DEFAULT 'Pending',
    ADD COLUMN IF NOT EXISTS source_type character varying(50),
    ADD COLUMN IF NOT EXISTS reference_id character varying(100),
    ADD COLUMN IF NOT EXISTS failure_reason text,
    ADD COLUMN IF NOT EXISTS completed_at timestamp without time zone;

ALTER TABLE IF EXISTS engagement.feedbacks
    ADD COLUMN IF NOT EXISTS resolve_failure_reason text,
    ADD COLUMN IF NOT EXISTS resolved_at timestamp without time zone;

-- Rows imported from the monolith were committed atomically, so they are already
-- completed operations rather than new pending distributed transactions.
UPDATE engagement.reward_transactions
SET status = 'Completed',
    completed_at = COALESCE(completed_at, created_at)
WHERE source_type IS NULL
  AND reference_id IS NULL
  AND status = 'Pending';

CREATE UNIQUE INDEX IF NOT EXISTS "IX_reward_transactions_source_type_reference_id_type"
    ON engagement.reward_transactions (source_type, reference_id, type)
    WHERE reference_id IS NOT NULL;

-- EF uses one history table per service schema.  Mark the schema-creation
-- migrations as applied because this script moved the existing tables instead of
-- asking EF to recreate them.  The role seed is also already present in legacy DBs.
CREATE TABLE IF NOT EXISTS identity."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL PRIMARY KEY,
    "ProductVersion" character varying(32) NOT NULL
);
CREATE TABLE IF NOT EXISTS waste."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL PRIMARY KEY,
    "ProductVersion" character varying(32) NOT NULL
);
CREATE TABLE IF NOT EXISTS collection."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL PRIMARY KEY,
    "ProductVersion" character varying(32) NOT NULL
);
CREATE TABLE IF NOT EXISTS engagement."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL PRIMARY KEY,
    "ProductVersion" character varying(32) NOT NULL
);

INSERT INTO identity."__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES
    ('20260616075432_InitialIdentitySchema', '8.0.0'),
    ('20260626002745_SeedIdentityRoles', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

INSERT INTO waste."__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES
    ('20260616075501_InitialWasteSchema', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

INSERT INTO collection."__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES
    ('20260616075530_InitialCollectionSchema', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

INSERT INTO engagement."__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES
    ('20260616075558_InitialEngagementSchema', '8.0.0'),
    ('20260623005243_AddEngagementConsistencyFields', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

-- ALTER TABLE ... SET SCHEMA moves owned sequences with their tables, but their
-- next values still need to be aligned with imported IDs.
DO $$
DECLARE
    item record;
    sequence_name text;
    maximum_id bigint;
BEGIN
    FOR item IN
        SELECT * FROM (VALUES
            ('identity', 'roles', 'role_id'),
            ('identity', 'users', 'user_id'),
            ('waste', 'waste_reports', 'report_id'),
            ('waste', 'waste_types', 'waste_type_id'),
            ('waste', 'districts', 'district_id'),
            ('waste', 'ai_waste_predictions', 'prediction_id'),
            ('collection', 'collection_requests', 'request_id'),
            ('collection', 'collector_assignments', 'assignment_id'),
            ('collection', 'collection_confirmations', 'confirmation_id'),
            ('collection', 'collection_details', 'detail_id'),
            ('engagement', 'notifications', 'notification_id'),
            ('engagement', 'rewards', 'reward_id'),
            ('engagement', 'reward_transactions', 'transaction_id'),
            ('engagement', 'feedbacks', 'feedback_id')
        ) AS targets(schema_name, table_name, column_name)
    LOOP
        IF to_regclass(format('%I.%I', item.schema_name, item.table_name)) IS NULL THEN
            CONTINUE;
        END IF;

        sequence_name := pg_get_serial_sequence(
            format('%I.%I', item.schema_name, item.table_name),
            item.column_name);
        IF sequence_name IS NULL THEN
            CONTINUE;
        END IF;

        EXECUTE format(
            'SELECT max(%I) FROM %I.%I',
            item.column_name,
            item.schema_name,
            item.table_name)
        INTO maximum_id;

        PERFORM setval(sequence_name::regclass, GREATEST(COALESCE(maximum_id, 1), 1), maximum_id IS NOT NULL);
    END LOOP;
END $$;
