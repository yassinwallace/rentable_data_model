CREATE SCHEMA IF NOT EXISTS public;

SET search_path TO public;

CREATE TABLE "users" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"username" varchar UNIQUE NOT NULL,
"email" varchar UNIQUE NOT NULL,
"password_hash" varchar NOT NULL,
"user_type" user_type NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" timestamp
);

CREATE TABLE "password_reset_tokens" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"token" VARCHAR(255) UNIQUE NOT NULL,
"expires_at" TIMESTAMP NOT NULL,
"is_used" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);