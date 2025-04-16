-- Polymorphic Validations for Booking Relationships (Booking Management Module) Step 12
-- Extracted from polymorphic_validations.sql on 2025-04-16

-- ==========================================
-- VALIDATION FUNCTIONS
-- ==========================================

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

-- Function to handle cascading deletes for users (booking renter)
CREATE OR REPLACE FUNCTION handle_user_delete_booking()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related bookings where the user is the renter
    DELETE FROM booking WHERE renter_id = OLD.id AND renter_type = 'user';
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Function to handle cascading deletes for businesses (booking renter)
CREATE OR REPLACE FUNCTION handle_business_delete_booking()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related bookings where the business is the renter
    DELETE FROM booking WHERE renter_id = OLD.id AND renter_type = 'business';
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger for validating booking renter on insert or update
CREATE TRIGGER validate_booking_renter_trigger
BEFORE INSERT OR UPDATE OF renter_id, renter_type ON booking
FOR EACH ROW
EXECUTE FUNCTION validate_booking_renter();

-- Trigger for handling cascading deletes when a user is deleted (booking renter)
CREATE TRIGGER handle_user_delete_booking_trigger
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION handle_user_delete_booking();

-- Trigger for handling cascading deletes when a business is deleted (booking renter)
CREATE TRIGGER handle_business_delete_booking_trigger
BEFORE DELETE ON business
FOR EACH ROW
EXECUTE FUNCTION handle_business_delete_booking();

-- ==========================================
-- DOCUMENTATION
-- ==========================================
/*
This file implements database-level checks for polymorphic booking-renter relationships in the Rentable database (Booking Management module).

Polymorphic relationship managed:
1. Booking table: renter_id + renter_type (references "user" or business)

For this relationship, we implement:
- Validation functions that check if the referenced entity exists
- Triggers that execute these validation functions on INSERT and UPDATE operations
- Cascade delete functions and triggers to maintain data integrity when entities are deleted

These validations replace traditional foreign key constraints, which cannot handle polymorphic relationships directly in PostgreSQL.
*/
