CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS waste;
CREATE SCHEMA IF NOT EXISTS collection;
CREATE SCHEMA IF NOT EXISTS engagement;

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
