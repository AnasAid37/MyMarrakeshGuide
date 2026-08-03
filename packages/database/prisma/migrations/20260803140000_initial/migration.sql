-- MyMarrakeshGuide initial PostgreSQL schema.
-- Generated for PostgreSQL 18 and Prisma ORM 7.

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TYPE "GlobalRole" AS ENUM ('USER', 'SUPPORT', 'CONTENT_EDITOR', 'CONTENT_REVIEWER', 'ADMIN', 'SUPER_ADMIN');
CREATE TYPE "UserStatus" AS ENUM ('PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'DELETED');
CREATE TYPE "OAuthProvider" AS ENUM ('GOOGLE');
CREATE TYPE "HostStatus" AS ENUM ('PENDING_REVIEW', 'ACTIVE', 'SUSPENDED', 'ARCHIVED');
CREATE TYPE "HostRole" AS ENUM ('OWNER', 'ADMIN', 'MANAGER', 'ANALYST');
CREATE TYPE "MembershipStatus" AS ENUM ('INVITED', 'ACTIVE', 'SUSPENDED', 'REVOKED');
CREATE TYPE "PropertyStatus" AS ENUM ('DRAFT', 'PENDING_REVIEW', 'ACTIVE', 'SUSPENDED', 'ARCHIVED');
CREATE TYPE "PlaceStatus" AS ENUM ('DRAFT', 'IN_REVIEW', 'PUBLISHED', 'TEMPORARILY_CLOSED', 'PERMANENTLY_CLOSED', 'ARCHIVED');
CREATE TYPE "VerificationStatus" AS ENUM ('UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED', 'STALE');
CREATE TYPE "PriceLevel" AS ENUM ('FREE', 'BUDGET', 'MODERATE', 'PREMIUM', 'LUXURY');
CREATE TYPE "OpeningHourKind" AS ENUM ('REGULAR', 'SEASONAL');
CREATE TYPE "TripStatus" AS ENUM ('DRAFT', 'GENERATING', 'READY', 'FAILED', 'ARCHIVED', 'DELETED');
CREATE TYPE "TripVisibility" AS ENUM ('PRIVATE', 'LINK');
CREATE TYPE "TripSource" AS ENUM ('DIRECT', 'PROPERTY_QR', 'SHARED_TRIP', 'ADMIN');
CREATE TYPE "ActivityStatus" AS ENUM ('PLANNED', 'COMPLETED', 'SKIPPED', 'REPLACED', 'CANCELLED');
CREATE TYPE "TravelMode" AS ENUM ('WALKING', 'DRIVING', 'TRANSIT', 'CYCLING', 'TAXI');
CREATE TYPE "ReviewStatus" AS ENUM ('PENDING', 'PUBLISHED', 'REJECTED', 'HIDDEN');
CREATE TYPE "SubscriptionStatus" AS ENUM ('INCOMPLETE', 'TRIALING', 'ACTIVE', 'PAST_DUE', 'PAUSED', 'CANCELLED', 'UNPAID');
CREATE TYPE "BillingInterval" AS ENUM ('MONTH', 'YEAR');
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'REQUIRES_ACTION', 'SUCCEEDED', 'FAILED', 'REFUNDED', 'PARTIALLY_REFUNDED', 'CANCELLED');
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'EMAIL');
CREATE TYPE "NotificationStatus" AS ENUM ('PENDING', 'PROCESSING', 'SENT', 'FAILED', 'CANCELLED');
CREATE TYPE "NotificationType" AS ENUM ('SECURITY', 'BILLING', 'TRIP_READY', 'TRIP_UPDATED', 'REVIEW', 'HOST_INVITATION', 'SYSTEM');
CREATE TYPE "MediaKind" AS ENUM ('IMAGE', 'VIDEO', 'DOCUMENT');
CREATE TYPE "MediaStatus" AS ENUM ('UPLOADING', 'READY', 'REJECTED', 'ARCHIVED');
CREATE TYPE "PromptStatus" AS ENUM ('PENDING', 'SUCCEEDED', 'INVALID_OUTPUT', 'FAILED');
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'RESTORE', 'PUBLISH', 'UNPUBLISH', 'LOGIN', 'LOGOUT', 'INVITE', 'ACCEPT_INVITE', 'REVOKE', 'SUSPEND', 'ACTIVATE', 'PAYMENT', 'EXPORT');
CREATE TYPE "QrCodeStatus" AS ENUM ('DRAFT', 'ACTIVE', 'DISABLED', 'ARCHIVED');
CREATE TYPE "ConsentType" AS ENUM ('TERMS', 'PRIVACY', 'ANALYTICS', 'MARKETING_EMAIL', 'LOCATION');
CREATE TYPE "FeatureFlagType" AS ENUM ('BOOLEAN', 'PERCENTAGE', 'RULES');
CREATE TYPE "SearchType" AS ENUM ('PLACE', 'CATEGORY', 'NEIGHBORHOOD', 'GLOBAL');

CREATE TABLE "users" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" VARCHAR(320) NOT NULL,
  "email_normalized" VARCHAR(320) NOT NULL,
  "password_hash" VARCHAR(255),
  "display_name" VARCHAR(120) NOT NULL,
  "avatar_url" VARCHAR(2048),
  "global_role" "GlobalRole" NOT NULL DEFAULT 'USER',
  "status" "UserStatus" NOT NULL DEFAULT 'PENDING_VERIFICATION',
  "locale" VARCHAR(16) NOT NULL DEFAULT 'en',
  "timezone" VARCHAR(64) NOT NULL DEFAULT 'Africa/Casablanca',
  "email_verified_at" TIMESTAMPTZ(3),
  "last_login_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" TIMESTAMPTZ(3),
  CONSTRAINT "users_email_key" UNIQUE ("email"),
  CONSTRAINT "users_email_normalized_key" UNIQUE ("email_normalized")
);

CREATE TABLE "oauth_accounts" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "provider" "OAuthProvider" NOT NULL,
  "provider_account_id" VARCHAR(255) NOT NULL,
  "email" VARCHAR(320),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "oauth_accounts_provider_provider_account_id_key" UNIQUE ("provider", "provider_account_id"),
  CONSTRAINT "oauth_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "refresh_sessions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "family_id" UUID NOT NULL,
  "token_hash" VARCHAR(128) NOT NULL,
  "user_agent_hash" VARCHAR(128),
  "ip_hash" VARCHAR(128),
  "expires_at" TIMESTAMPTZ(3) NOT NULL,
  "last_used_at" TIMESTAMPTZ(3),
  "revoked_at" TIMESTAMPTZ(3),
  "revoke_reason" VARCHAR(255),
  "replaced_by_id" UUID,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "refresh_sessions_token_hash_key" UNIQUE ("token_hash"),
  CONSTRAINT "refresh_sessions_replaced_by_id_key" UNIQUE ("replaced_by_id"),
  CONSTRAINT "refresh_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "refresh_sessions_replaced_by_id_fkey" FOREIGN KEY ("replaced_by_id") REFERENCES "refresh_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "refresh_sessions_expiry_check" CHECK ("expires_at" > "created_at")
);

CREATE TABLE "user_consents" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "type" "ConsentType" NOT NULL,
  "version" VARCHAR(32) NOT NULL,
  "granted" BOOLEAN NOT NULL,
  "granted_at" TIMESTAMPTZ(3) NOT NULL,
  "withdrawn_at" TIMESTAMPTZ(3),
  "source" VARCHAR(64) NOT NULL,
  "ip_hash" VARCHAR(128),
  CONSTRAINT "user_consents_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "hosts" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "legal_name" VARCHAR(180) NOT NULL,
  "display_name" VARCHAR(120) NOT NULL,
  "slug" VARCHAR(120) NOT NULL,
  "status" "HostStatus" NOT NULL DEFAULT 'PENDING_REVIEW',
  "billing_email" VARCHAR(320) NOT NULL,
  "stripe_customer_id" VARCHAR(255),
  "settings" JSONB NOT NULL DEFAULT '{}',
  "verified_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "archived_at" TIMESTAMPTZ(3),
  CONSTRAINT "hosts_slug_key" UNIQUE ("slug"),
  CONSTRAINT "hosts_stripe_customer_id_key" UNIQUE ("stripe_customer_id")
);

CREATE TABLE "host_members" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "host_id" UUID NOT NULL,
  "user_id" UUID NOT NULL,
  "role" "HostRole" NOT NULL,
  "status" "MembershipStatus" NOT NULL DEFAULT 'INVITED',
  "invited_by" UUID,
  "invited_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "accepted_at" TIMESTAMPTZ(3),
  "revoked_at" TIMESTAMPTZ(3),
  CONSTRAINT "host_members_host_id_user_id_key" UNIQUE ("host_id", "user_id"),
  CONSTRAINT "host_members_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "host_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "properties" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "host_id" UUID NOT NULL,
  "name" VARCHAR(160) NOT NULL,
  "slug" VARCHAR(140) NOT NULL,
  "status" "PropertyStatus" NOT NULL DEFAULT 'DRAFT',
  "description" TEXT,
  "address_line_1" VARCHAR(255) NOT NULL,
  "address_line_2" VARCHAR(255),
  "neighborhood" VARCHAR(120),
  "city" VARCHAR(120) NOT NULL DEFAULT 'Marrakesh',
  "postal_code" VARCHAR(24),
  "country_code" CHAR(2) NOT NULL DEFAULT 'MA',
  "latitude" DECIMAL(10,7) NOT NULL,
  "longitude" DECIMAL(10,7) NOT NULL,
  "timezone" VARCHAR(64) NOT NULL DEFAULT 'Africa/Casablanca',
  "contact_email" VARCHAR(320),
  "contact_phone" VARCHAR(32),
  "website_url" VARCHAR(2048),
  "check_in_time" VARCHAR(5),
  "check_out_time" VARCHAR(5),
  "guide_defaults" JSONB NOT NULL DEFAULT '{}',
  "verified_at" TIMESTAMPTZ(3),
  "activated_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "archived_at" TIMESTAMPTZ(3),
  CONSTRAINT "properties_host_id_slug_key" UNIQUE ("host_id", "slug"),
  CONSTRAINT "properties_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "properties_latitude_check" CHECK ("latitude" BETWEEN -90 AND 90),
  CONSTRAINT "properties_longitude_check" CHECK ("longitude" BETWEEN -180 AND 180)
);

CREATE TABLE "categories" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "parent_id" UUID,
  "slug" VARCHAR(80) NOT NULL,
  "name" VARCHAR(100) NOT NULL,
  "description" VARCHAR(500),
  "icon" VARCHAR(64),
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "categories_slug_key" UNIQUE ("slug"),
  CONSTRAINT "categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "places" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "google_place_id" VARCHAR(255),
  "slug" VARCHAR(180) NOT NULL,
  "name" VARCHAR(180) NOT NULL,
  "short_description" VARCHAR(280) NOT NULL,
  "description" TEXT NOT NULL,
  "status" "PlaceStatus" NOT NULL DEFAULT 'DRAFT',
  "verification_status" "VerificationStatus" NOT NULL DEFAULT 'UNVERIFIED',
  "address_line_1" VARCHAR(255) NOT NULL,
  "address_line_2" VARCHAR(255),
  "neighborhood" VARCHAR(120),
  "city" VARCHAR(120) NOT NULL DEFAULT 'Marrakesh',
  "postal_code" VARCHAR(24),
  "country_code" CHAR(2) NOT NULL DEFAULT 'MA',
  "latitude" DECIMAL(10,7) NOT NULL,
  "longitude" DECIMAL(10,7) NOT NULL,
  "price_level" "PriceLevel" NOT NULL DEFAULT 'MODERATE',
  "average_visit_minutes" INTEGER NOT NULL DEFAULT 60,
  "indoor" BOOLEAN NOT NULL DEFAULT FALSE,
  "outdoor" BOOLEAN NOT NULL DEFAULT FALSE,
  "family_friendly" BOOLEAN NOT NULL DEFAULT FALSE,
  "accessibility_supported" BOOLEAN NOT NULL DEFAULT FALSE,
  "booking_required" BOOLEAN NOT NULL DEFAULT FALSE,
  "phone" VARCHAR(32),
  "website_url" VARCHAR(2048),
  "google_rating" DECIMAL(2,1),
  "google_rating_count" INTEGER,
  "popularity_score" DECIMAL(6,3) NOT NULL DEFAULT 0,
  "crowd_profile" JSONB NOT NULL DEFAULT '{}',
  "weather_suitability" JSONB NOT NULL DEFAULT '{}',
  "source_updated_at" TIMESTAMPTZ(3),
  "verified_at" TIMESTAMPTZ(3),
  "verified_by_id" UUID,
  "published_at" TIMESTAMPTZ(3),
  "closed_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "places_google_place_id_key" UNIQUE ("google_place_id"),
  CONSTRAINT "places_slug_key" UNIQUE ("slug"),
  CONSTRAINT "places_verified_by_id_fkey" FOREIGN KEY ("verified_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "places_latitude_check" CHECK ("latitude" BETWEEN -90 AND 90),
  CONSTRAINT "places_longitude_check" CHECK ("longitude" BETWEEN -180 AND 180),
  CONSTRAINT "places_rating_check" CHECK ("google_rating" IS NULL OR "google_rating" BETWEEN 0 AND 5),
  CONSTRAINT "places_duration_check" CHECK ("average_visit_minutes" > 0)
);

CREATE TABLE "place_categories" (
  "place_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "is_primary" BOOLEAN NOT NULL DEFAULT FALSE,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "place_categories_pkey" PRIMARY KEY ("place_id", "category_id"),
  CONSTRAINT "place_categories_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "place_categories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "opening_hours" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "place_id" UUID NOT NULL,
  "kind" "OpeningHourKind" NOT NULL DEFAULT 'REGULAR',
  "day_of_week" SMALLINT NOT NULL,
  "opens_at" VARCHAR(5),
  "closes_at" VARCHAR(5),
  "is_closed" BOOLEAN NOT NULL DEFAULT FALSE,
  "valid_from" DATE,
  "valid_until" DATE,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "opening_hours_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "opening_hours_day_check" CHECK ("day_of_week" BETWEEN 0 AND 6),
  CONSTRAINT "opening_hours_time_check" CHECK (
    ("is_closed" = TRUE AND "opens_at" IS NULL AND "closes_at" IS NULL)
    OR ("is_closed" = FALSE AND "opens_at" ~ '^[0-2][0-9]:[0-5][0-9]$' AND "closes_at" ~ '^[0-2][0-9]:[0-5][0-9]$')
  ),
  CONSTRAINT "opening_hours_date_check" CHECK ("valid_until" IS NULL OR "valid_from" IS NULL OR "valid_until" >= "valid_from")
);

CREATE TABLE "opening_hour_exceptions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "place_id" UUID NOT NULL,
  "date" DATE NOT NULL,
  "opens_at" VARCHAR(5),
  "closes_at" VARCHAR(5),
  "is_closed" BOOLEAN NOT NULL DEFAULT FALSE,
  "reason" VARCHAR(255),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "opening_hour_exceptions_place_id_date_key" UNIQUE ("place_id", "date"),
  CONSTRAINT "opening_hour_exceptions_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "place_sources" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "place_id" UUID NOT NULL,
  "source_type" VARCHAR(40) NOT NULL,
  "source_url" VARCHAR(2048),
  "external_id" VARCHAR(255),
  "payload_hash" VARCHAR(128),
  "observed_at" TIMESTAMPTZ(3) NOT NULL,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "place_sources_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "place_verifications" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "place_id" UUID NOT NULL,
  "status" "VerificationStatus" NOT NULL,
  "checklist" JSONB NOT NULL DEFAULT '{}',
  "notes" TEXT,
  "verified_by_id" UUID,
  "verified_at" TIMESTAMPTZ(3),
  "next_review_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "place_verifications_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "place_verifications_verified_by_id_fkey" FOREIGN KEY ("verified_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "media" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "public_id" VARCHAR(255) NOT NULL,
  "kind" "MediaKind" NOT NULL,
  "status" "MediaStatus" NOT NULL DEFAULT 'UPLOADING',
  "secure_url" VARCHAR(2048) NOT NULL,
  "format" VARCHAR(32) NOT NULL,
  "width" INTEGER,
  "height" INTEGER,
  "bytes" BIGINT,
  "alt_text" VARCHAR(280),
  "blur_hash" VARCHAR(255),
  "metadata" JSONB NOT NULL DEFAULT '{}',
  "created_by_id" UUID,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "archived_at" TIMESTAMPTZ(3),
  CONSTRAINT "media_public_id_key" UNIQUE ("public_id"),
  CONSTRAINT "media_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "place_media" (
  "place_id" UUID NOT NULL,
  "media_id" UUID NOT NULL,
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  "is_cover" BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT "place_media_pkey" PRIMARY KEY ("place_id", "media_id"),
  CONSTRAINT "place_media_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "place_media_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "property_media" (
  "property_id" UUID NOT NULL,
  "media_id" UUID NOT NULL,
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  "is_cover" BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT "property_media_pkey" PRIMARY KEY ("property_id", "media_id"),
  CONSTRAINT "property_media_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "property_media_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "qr_codes" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_id" UUID NOT NULL,
  "code" VARCHAR(64) NOT NULL,
  "label" VARCHAR(120) NOT NULL,
  "destination_path" VARCHAR(512) NOT NULL,
  "status" "QrCodeStatus" NOT NULL DEFAULT 'DRAFT',
  "activated_at" TIMESTAMPTZ(3),
  "disabled_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "qr_codes_code_key" UNIQUE ("code"),
  CONSTRAINT "qr_codes_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "guest_sessions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "anonymous_id_hash" VARCHAR(128) NOT NULL,
  "property_id" UUID,
  "qr_code_id" UUID,
  "locale" VARCHAR(16) NOT NULL DEFAULT 'en',
  "analytics_consent" BOOLEAN NOT NULL DEFAULT FALSE,
  "started_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_seen_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expires_at" TIMESTAMPTZ(3) NOT NULL,
  CONSTRAINT "guest_sessions_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "guest_sessions_qr_code_id_fkey" FOREIGN KEY ("qr_code_id") REFERENCES "qr_codes"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "trips" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID,
  "guest_session_id" UUID,
  "property_id" UUID,
  "title" VARCHAR(180) NOT NULL,
  "status" "TripStatus" NOT NULL DEFAULT 'DRAFT',
  "visibility" "TripVisibility" NOT NULL DEFAULT 'PRIVATE',
  "source" "TripSource" NOT NULL DEFAULT 'DIRECT',
  "start_date" DATE NOT NULL,
  "end_date" DATE NOT NULL,
  "timezone" VARCHAR(64) NOT NULL DEFAULT 'Africa/Casablanca',
  "party_size" INTEGER NOT NULL DEFAULT 1,
  "party_composition" JSONB NOT NULL DEFAULT '{}',
  "preferences" JSONB NOT NULL DEFAULT '{}',
  "budget_min" DECIMAL(12,2),
  "budget_max" DECIMAL(12,2),
  "currency" CHAR(3) NOT NULL DEFAULT 'MAD',
  "share_token_hash" VARCHAR(128),
  "share_expires_at" TIMESTAMPTZ(3),
  "generation_version" VARCHAR(40),
  "generated_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "archived_at" TIMESTAMPTZ(3),
  "deleted_at" TIMESTAMPTZ(3),
  CONSTRAINT "trips_share_token_hash_key" UNIQUE ("share_token_hash"),
  CONSTRAINT "trips_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "trips_guest_session_id_fkey" FOREIGN KEY ("guest_session_id") REFERENCES "guest_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "trips_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "trips_date_check" CHECK ("end_date" >= "start_date"),
  CONSTRAINT "trips_party_size_check" CHECK ("party_size" BETWEEN 1 AND 50),
  CONSTRAINT "trips_budget_check" CHECK (
    ("budget_min" IS NULL OR "budget_min" >= 0) AND
    ("budget_max" IS NULL OR "budget_max" >= 0) AND
    ("budget_min" IS NULL OR "budget_max" IS NULL OR "budget_max" >= "budget_min")
  )
);

CREATE TABLE "trip_days" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "trip_id" UUID NOT NULL,
  "day_number" INTEGER NOT NULL,
  "date" DATE NOT NULL,
  "title" VARCHAR(160),
  "summary" VARCHAR(500),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "trip_days_trip_id_day_number_key" UNIQUE ("trip_id", "day_number"),
  CONSTRAINT "trip_days_trip_id_date_key" UNIQUE ("trip_id", "date"),
  CONSTRAINT "trip_days_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "trip_days_day_number_check" CHECK ("day_number" > 0)
);

CREATE TABLE "prompt_history" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID,
  "trip_id" UUID,
  "model" VARCHAR(80) NOT NULL,
  "prompt_version" VARCHAR(40) NOT NULL,
  "system_prompt_hash" VARCHAR(128) NOT NULL,
  "input_hash" VARCHAR(128) NOT NULL,
  "candidate_place_ids" JSONB NOT NULL,
  "request_payload" JSONB NOT NULL,
  "response_payload" JSONB,
  "status" "PromptStatus" NOT NULL DEFAULT 'PENDING',
  "validation_errors" JSONB,
  "input_tokens" INTEGER,
  "output_tokens" INTEGER,
  "cost_micros" BIGINT,
  "latency_ms" INTEGER,
  "provider_request_id" VARCHAR(255),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "completed_at" TIMESTAMPTZ(3),
  CONSTRAINT "prompt_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "prompt_history_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "trip_activities" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "trip_day_id" UUID NOT NULL,
  "place_id" UUID NOT NULL,
  "prompt_history_id" UUID,
  "position" INTEGER NOT NULL,
  "status" "ActivityStatus" NOT NULL DEFAULT 'PLANNED',
  "starts_at" TIMESTAMPTZ(3) NOT NULL,
  "ends_at" TIMESTAMPTZ(3) NOT NULL,
  "planned_duration_min" INTEGER NOT NULL,
  "travel_mode" "TravelMode",
  "travel_duration_min" INTEGER,
  "travel_distance_meters" INTEGER,
  "rationale" VARCHAR(500) NOT NULL,
  "traveler_notes" TEXT,
  "place_snapshot" JSONB NOT NULL,
  "replaced_activity_id" UUID,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "trip_activities_trip_day_id_position_key" UNIQUE ("trip_day_id", "position"),
  CONSTRAINT "trip_activities_trip_day_id_fkey" FOREIGN KEY ("trip_day_id") REFERENCES "trip_days"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "trip_activities_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "trip_activities_prompt_history_id_fkey" FOREIGN KEY ("prompt_history_id") REFERENCES "prompt_history"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "trip_activities_replaced_activity_id_fkey" FOREIGN KEY ("replaced_activity_id") REFERENCES "trip_activities"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "trip_activities_time_check" CHECK ("ends_at" > "starts_at"),
  CONSTRAINT "trip_activities_duration_check" CHECK ("planned_duration_min" > 0),
  CONSTRAINT "trip_activities_travel_check" CHECK (
    ("travel_duration_min" IS NULL OR "travel_duration_min" >= 0) AND
    ("travel_distance_meters" IS NULL OR "travel_distance_meters" >= 0)
  )
);

CREATE TABLE "favorites" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "place_id" UUID NOT NULL,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "favorites_user_id_place_id_key" UNIQUE ("user_id", "place_id"),
  CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "favorites_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "reviews" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "place_id" UUID NOT NULL,
  "rating" SMALLINT NOT NULL,
  "title" VARCHAR(120),
  "body" TEXT NOT NULL,
  "status" "ReviewStatus" NOT NULL DEFAULT 'PENDING',
  "moderated_by_id" UUID,
  "moderated_at" TIMESTAMPTZ(3),
  "moderation_note" VARCHAR(500),
  "published_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "reviews_user_id_place_id_key" UNIQUE ("user_id", "place_id"),
  CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "reviews_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "reviews_moderated_by_id_fkey" FOREIGN KEY ("moderated_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "reviews_rating_check" CHECK ("rating" BETWEEN 1 AND 5),
  CONSTRAINT "reviews_body_check" CHECK (char_length("body") BETWEEN 10 AND 5000)
);

CREATE TABLE "subscriptions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "host_id" UUID NOT NULL,
  "stripe_subscription_id" VARCHAR(255) NOT NULL,
  "stripe_price_id" VARCHAR(255) NOT NULL,
  "plan_code" VARCHAR(64) NOT NULL,
  "status" "SubscriptionStatus" NOT NULL,
  "billing_interval" "BillingInterval" NOT NULL,
  "quantity" INTEGER NOT NULL DEFAULT 1,
  "current_period_start" TIMESTAMPTZ(3) NOT NULL,
  "current_period_end" TIMESTAMPTZ(3) NOT NULL,
  "cancel_at_period_end" BOOLEAN NOT NULL DEFAULT FALSE,
  "trial_ends_at" TIMESTAMPTZ(3),
  "cancelled_at" TIMESTAMPTZ(3),
  "ended_at" TIMESTAMPTZ(3),
  "metadata" JSONB NOT NULL DEFAULT '{}',
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "subscriptions_stripe_subscription_id_key" UNIQUE ("stripe_subscription_id"),
  CONSTRAINT "subscriptions_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "subscriptions_period_check" CHECK ("current_period_end" > "current_period_start"),
  CONSTRAINT "subscriptions_quantity_check" CHECK ("quantity" > 0)
);

CREATE TABLE "payments" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "host_id" UUID NOT NULL,
  "subscription_id" UUID,
  "stripe_payment_intent_id" VARCHAR(255),
  "stripe_invoice_id" VARCHAR(255),
  "amount" DECIMAL(12,2) NOT NULL,
  "refunded_amount" DECIMAL(12,2) NOT NULL DEFAULT 0,
  "currency" CHAR(3) NOT NULL,
  "status" "PaymentStatus" NOT NULL,
  "failure_code" VARCHAR(80),
  "failure_message" VARCHAR(500),
  "paid_at" TIMESTAMPTZ(3),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "payments_stripe_payment_intent_id_key" UNIQUE ("stripe_payment_intent_id"),
  CONSTRAINT "payments_stripe_invoice_id_key" UNIQUE ("stripe_invoice_id"),
  CONSTRAINT "payments_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "payments_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "subscriptions"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "payments_amount_check" CHECK ("amount" >= 0 AND "refunded_amount" >= 0 AND "refunded_amount" <= "amount")
);

CREATE TABLE "notifications" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "type" "NotificationType" NOT NULL,
  "channel" "NotificationChannel" NOT NULL,
  "status" "NotificationStatus" NOT NULL DEFAULT 'PENDING',
  "subject" VARCHAR(180) NOT NULL,
  "body" TEXT NOT NULL,
  "data" JSONB NOT NULL DEFAULT '{}',
  "dedupe_key" VARCHAR(180),
  "scheduled_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "processing_at" TIMESTAMPTZ(3),
  "sent_at" TIMESTAMPTZ(3),
  "failed_at" TIMESTAMPTZ(3),
  "read_at" TIMESTAMPTZ(3),
  "attempts" INTEGER NOT NULL DEFAULT 0,
  "last_error_code" VARCHAR(80),
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "notifications_dedupe_key_key" UNIQUE ("dedupe_key"),
  CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "notifications_attempts_check" CHECK ("attempts" >= 0)
);

CREATE TABLE "weather_cache" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "provider" VARCHAR(40) NOT NULL,
  "location_key" VARCHAR(120) NOT NULL,
  "forecast_date" DATE NOT NULL,
  "timezone" VARCHAR(64) NOT NULL,
  "payload" JSONB NOT NULL,
  "fetched_at" TIMESTAMPTZ(3) NOT NULL,
  "expires_at" TIMESTAMPTZ(3) NOT NULL,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "weather_cache_provider_location_key_forecast_date_key" UNIQUE ("provider", "location_key", "forecast_date"),
  CONSTRAINT "weather_cache_expiry_check" CHECK ("expires_at" > "fetched_at")
);

CREATE TABLE "api_logs" (
  "id" BIGSERIAL PRIMARY KEY,
  "request_id" VARCHAR(128) NOT NULL,
  "user_id" UUID,
  "method" VARCHAR(12) NOT NULL,
  "path" VARCHAR(512) NOT NULL,
  "status_code" SMALLINT NOT NULL,
  "duration_ms" INTEGER NOT NULL,
  "ip_hash" VARCHAR(128),
  "user_agent_hash" VARCHAR(128),
  "error_code" VARCHAR(80),
  "metadata" JSONB NOT NULL DEFAULT '{}',
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "api_logs_request_id_key" UNIQUE ("request_id"),
  CONSTRAINT "api_logs_status_check" CHECK ("status_code" BETWEEN 100 AND 599),
  CONSTRAINT "api_logs_duration_check" CHECK ("duration_ms" >= 0)
);

CREATE TABLE "audit_logs" (
  "id" BIGSERIAL PRIMARY KEY,
  "actor_user_id" UUID,
  "host_id" UUID,
  "action" "AuditAction" NOT NULL,
  "entity_type" VARCHAR(80) NOT NULL,
  "entity_id" VARCHAR(128),
  "request_id" VARCHAR(128),
  "ip_hash" VARCHAR(128),
  "before" JSONB,
  "after" JSONB,
  "metadata" JSONB NOT NULL DEFAULT '{}',
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "audit_logs_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "audit_logs_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "search_history" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID,
  "guest_session_id" UUID,
  "type" "SearchType" NOT NULL,
  "query" VARCHAR(255) NOT NULL,
  "normalized_query" VARCHAR(255) NOT NULL,
  "filters" JSONB NOT NULL DEFAULT '{}',
  "result_count" INTEGER NOT NULL,
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "search_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "search_history_guest_session_id_fkey" FOREIGN KEY ("guest_session_id") REFERENCES "guest_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "search_history_result_count_check" CHECK ("result_count" >= 0)
);

CREATE TABLE "analytics_events" (
  "id" BIGSERIAL PRIMARY KEY,
  "event_name" VARCHAR(100) NOT NULL,
  "user_id" UUID,
  "guest_session_id" UUID,
  "host_id" UUID,
  "property_id" UUID,
  "session_id" VARCHAR(128),
  "properties" JSONB NOT NULL DEFAULT '{}',
  "occurred_at" TIMESTAMPTZ(3) NOT NULL,
  "received_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "analytics_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "analytics_events_guest_session_id_fkey" FOREIGN KEY ("guest_session_id") REFERENCES "guest_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "analytics_events_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "hosts"("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT "analytics_events_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "feature_flags" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "key" VARCHAR(120) NOT NULL,
  "description" VARCHAR(500) NOT NULL,
  "type" "FeatureFlagType" NOT NULL DEFAULT 'BOOLEAN',
  "enabled" BOOLEAN NOT NULL DEFAULT FALSE,
  "rules" JSONB NOT NULL DEFAULT '{}',
  "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "feature_flags_key_key" UNIQUE ("key")
);

-- Search and access-path indexes.
CREATE INDEX "users_status_created_at_idx" ON "users" ("status", "created_at");
CREATE INDEX "users_display_name_trgm_idx" ON "users" USING GIN ("display_name" gin_trgm_ops);
CREATE INDEX "oauth_accounts_user_id_idx" ON "oauth_accounts" ("user_id");
CREATE INDEX "refresh_sessions_user_id_expires_at_idx" ON "refresh_sessions" ("user_id", "expires_at");
CREATE INDEX "refresh_sessions_family_id_idx" ON "refresh_sessions" ("family_id");
CREATE INDEX "user_consents_user_id_type_granted_at_idx" ON "user_consents" ("user_id", "type", "granted_at");
CREATE INDEX "hosts_status_created_at_idx" ON "hosts" ("status", "created_at");
CREATE INDEX "host_members_user_id_status_idx" ON "host_members" ("user_id", "status");
CREATE INDEX "host_members_host_id_status_idx" ON "host_members" ("host_id", "status");
CREATE INDEX "properties_host_id_status_idx" ON "properties" ("host_id", "status");
CREATE INDEX "properties_latitude_longitude_idx" ON "properties" ("latitude", "longitude");
CREATE INDEX "categories_parent_id_sort_order_idx" ON "categories" ("parent_id", "sort_order");
CREATE INDEX "places_status_verification_status_idx" ON "places" ("status", "verification_status");
CREATE INDEX "places_latitude_longitude_idx" ON "places" ("latitude", "longitude");
CREATE INDEX "places_price_level_popularity_score_idx" ON "places" ("price_level", "popularity_score");
CREATE INDEX "places_name_idx" ON "places" ("name");
CREATE INDEX "places_name_trgm_idx" ON "places" USING GIN ("name" gin_trgm_ops);
CREATE INDEX "places_neighborhood_trgm_idx" ON "places" USING GIN ("neighborhood" gin_trgm_ops);
CREATE INDEX "place_categories_category_id_is_primary_idx" ON "place_categories" ("category_id", "is_primary");
CREATE UNIQUE INDEX "place_categories_one_primary_idx" ON "place_categories" ("place_id") WHERE "is_primary" = TRUE;
CREATE INDEX "opening_hours_place_id_day_of_week_idx" ON "opening_hours" ("place_id", "day_of_week", "valid_from", "valid_until");
CREATE INDEX "place_sources_place_id_source_type_observed_at_idx" ON "place_sources" ("place_id", "source_type", "observed_at");
CREATE INDEX "place_verifications_place_id_created_at_idx" ON "place_verifications" ("place_id", "created_at");
CREATE INDEX "place_verifications_status_next_review_at_idx" ON "place_verifications" ("status", "next_review_at");
CREATE INDEX "media_status_kind_idx" ON "media" ("status", "kind");
CREATE INDEX "place_media_place_id_sort_order_idx" ON "place_media" ("place_id", "sort_order");
CREATE INDEX "property_media_property_id_sort_order_idx" ON "property_media" ("property_id", "sort_order");
CREATE UNIQUE INDEX "place_media_one_cover_idx" ON "place_media" ("place_id") WHERE "is_cover" = TRUE;
CREATE UNIQUE INDEX "property_media_one_cover_idx" ON "property_media" ("property_id") WHERE "is_cover" = TRUE;
CREATE INDEX "qr_codes_property_id_status_idx" ON "qr_codes" ("property_id", "status");
CREATE INDEX "guest_sessions_property_id_started_at_idx" ON "guest_sessions" ("property_id", "started_at");
CREATE INDEX "guest_sessions_qr_code_id_started_at_idx" ON "guest_sessions" ("qr_code_id", "started_at");
CREATE INDEX "guest_sessions_expires_at_idx" ON "guest_sessions" ("expires_at");
CREATE INDEX "trips_user_id_status_start_date_idx" ON "trips" ("user_id", "status", "start_date");
CREATE INDEX "trips_guest_session_id_created_at_idx" ON "trips" ("guest_session_id", "created_at");
CREATE INDEX "trips_property_id_created_at_idx" ON "trips" ("property_id", "created_at");
CREATE INDEX "prompt_history_trip_id_created_at_idx" ON "prompt_history" ("trip_id", "created_at");
CREATE INDEX "prompt_history_status_created_at_idx" ON "prompt_history" ("status", "created_at");
CREATE INDEX "prompt_history_input_hash_idx" ON "prompt_history" ("input_hash");
CREATE INDEX "trip_activities_place_id_starts_at_idx" ON "trip_activities" ("place_id", "starts_at");
CREATE INDEX "trip_activities_trip_day_id_starts_at_idx" ON "trip_activities" ("trip_day_id", "starts_at");
CREATE INDEX "favorites_place_id_created_at_idx" ON "favorites" ("place_id", "created_at");
CREATE INDEX "reviews_place_id_status_published_at_idx" ON "reviews" ("place_id", "status", "published_at");
CREATE INDEX "reviews_status_created_at_idx" ON "reviews" ("status", "created_at");
CREATE INDEX "subscriptions_host_id_status_idx" ON "subscriptions" ("host_id", "status");
CREATE INDEX "subscriptions_current_period_end_idx" ON "subscriptions" ("current_period_end");
CREATE INDEX "payments_host_id_created_at_idx" ON "payments" ("host_id", "created_at");
CREATE INDEX "payments_status_created_at_idx" ON "payments" ("status", "created_at");
CREATE INDEX "notifications_user_id_read_at_created_at_idx" ON "notifications" ("user_id", "read_at", "created_at");
CREATE INDEX "notifications_status_scheduled_at_idx" ON "notifications" ("status", "scheduled_at");
CREATE INDEX "weather_cache_expires_at_idx" ON "weather_cache" ("expires_at");
CREATE INDEX "api_logs_created_at_idx" ON "api_logs" ("created_at");
CREATE INDEX "api_logs_status_code_created_at_idx" ON "api_logs" ("status_code", "created_at");
CREATE INDEX "api_logs_user_id_created_at_idx" ON "api_logs" ("user_id", "created_at");
CREATE INDEX "audit_logs_actor_user_id_created_at_idx" ON "audit_logs" ("actor_user_id", "created_at");
CREATE INDEX "audit_logs_host_id_created_at_idx" ON "audit_logs" ("host_id", "created_at");
CREATE INDEX "audit_logs_entity_type_entity_id_created_at_idx" ON "audit_logs" ("entity_type", "entity_id", "created_at");
CREATE INDEX "audit_logs_request_id_idx" ON "audit_logs" ("request_id");
CREATE INDEX "search_history_user_id_created_at_idx" ON "search_history" ("user_id", "created_at");
CREATE INDEX "search_history_guest_session_id_created_at_idx" ON "search_history" ("guest_session_id", "created_at");
CREATE INDEX "search_history_normalized_query_created_at_idx" ON "search_history" ("normalized_query", "created_at");
CREATE INDEX "analytics_events_event_name_occurred_at_idx" ON "analytics_events" ("event_name", "occurred_at");
CREATE INDEX "analytics_events_host_id_occurred_at_idx" ON "analytics_events" ("host_id", "occurred_at");
CREATE INDEX "analytics_events_property_id_occurred_at_idx" ON "analytics_events" ("property_id", "occurred_at");
CREATE INDEX "analytics_events_guest_session_id_occurred_at_idx" ON "analytics_events" ("guest_session_id", "occurred_at");
CREATE INDEX "feature_flags_enabled_key_idx" ON "feature_flags" ("enabled", "key");
