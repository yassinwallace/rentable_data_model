-- Polymorphic Validations for Rentable Database
-- This file contains database-level checks for polymorphic relationships
-- Created: 2025-04-14

-- ==========================================
-- VALIDATION FUNCTIONS
-- ==========================================

-- Function to validate item owner relationship
CREATE OR REPLACE FUNCTION validate_item_owner()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the owner exists based on item_owner_type
    IF NEW.item_owner_type = 'user' THEN
        IF NOT EXISTS (SELECT 1 FROM "user" WHERE id = NEW.owner_id) THEN
            RAISE EXCEPTION 'Referenced user with id % does not exist', NEW.owner_id;
        END IF;
    ELSIF NEW.item_owner_type = 'business' THEN
        IF NOT EXISTS (SELECT 1 FROM business WHERE id = NEW.owner_id) THEN
            RAISE EXCEPTION 'Referenced business with id % does not exist', NEW.owner_id;
        END IF;
    ELSE
        RAISE EXCEPTION 'Invalid item_owner_type: %', NEW.item_owner_type;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to validate booking renter relationship
CREATE OR REPLACE FUNCTION validate_booking_renter()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the renter exists based on renter_type
    IF NEW.renter_type = 'user' THEN
        IF NOT EXISTS (SELECT 1 FROM "user" WHERE id = NEW.renter_id) THEN
            RAISE EXCEPTION 'Referenced user with id % does not exist', NEW.renter_id;
        END IF;
    ELSIF NEW.renter_type = 'business' THEN
        IF NOT EXISTS (SELECT 1 FROM business WHERE id = NEW.renter_id) THEN
            RAISE EXCEPTION 'Referenced business with id % does not exist', NEW.renter_id;
        END IF;
    ELSE
        RAISE EXCEPTION 'Invalid renter_type: %', NEW.renter_type;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- CASCADE DELETE FUNCTIONS
-- ==========================================

-- Function to handle cascading deletes for users
CREATE OR REPLACE FUNCTION handle_user_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related items where the user is the owner
    DELETE FROM item WHERE owner_id = OLD.id AND item_owner_type = 'user';
    
    -- Delete related bookings where the user is the renter
    DELETE FROM booking WHERE renter_id = OLD.id AND renter_type = 'user';
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Function to handle cascading deletes for businesses
CREATE OR REPLACE FUNCTION handle_business_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related items where the business is the owner
    DELETE FROM item WHERE owner_id = OLD.id AND item_owner_type = 'business';
    
    -- Delete related bookings where the business is the renter
    DELETE FROM booking WHERE renter_id = OLD.id AND renter_type = 'business';
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Function to handle cascading deletes for items
CREATE OR REPLACE FUNCTION handle_item_delete()
RETURNS TRIGGER AS $$
BEGIN
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger for validating item owner on insert or update
CREATE TRIGGER validate_item_owner_trigger
BEFORE INSERT OR UPDATE OF owner_id, item_owner_type ON item
FOR EACH ROW
EXECUTE FUNCTION validate_item_owner();

-- Trigger for validating booking renter on insert or update
CREATE TRIGGER validate_booking_renter_trigger
BEFORE INSERT OR UPDATE OF renter_id, renter_type ON booking
FOR EACH ROW
EXECUTE FUNCTION validate_booking_renter();

-- Trigger for handling cascading deletes when a user is deleted
CREATE TRIGGER handle_user_delete_trigger
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION handle_user_delete();

-- Trigger for handling cascading deletes when a business is deleted
CREATE TRIGGER handle_business_delete_trigger
BEFORE DELETE ON business
FOR EACH ROW
EXECUTE FUNCTION handle_business_delete();

-- Trigger for handling cascading deletes when an item is deleted
CREATE TRIGGER handle_item_delete_trigger
BEFORE DELETE ON item
FOR EACH ROW
EXECUTE FUNCTION handle_item_delete();

-- ==========================================
-- DOCUMENTATION
-- ==========================================
/*
This file implements database-level checks for polymorphic relationships in the Rentable database.

The following polymorphic relationships are managed:
1. Item table: owner_id + item_owner_type (references "user" or business)
2. Booking table: renter_id + renter_type (references "user" or business)

For each relationship, we implement:
- Validation functions that check if the referenced entity exists
- Triggers that execute these validation functions on INSERT and UPDATE operations
- Cascade delete functions and triggers to maintain data integrity when entities are deleted

These validations replace traditional foreign key constraints, which cannot handle
polymorphic relationships directly in PostgreSQL.

To use this file:
1. First create all tables in the main schema file (mono_tenant_template.sql)
2. Then execute this file to add the polymorphic validations
*/

-- Cleaned: Removed all location-related validation and cascade logic. See location_polymorphic_validations.sql for location module logic.
