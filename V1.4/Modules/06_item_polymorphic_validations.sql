-- Polymorphic Validations for Item Relationships (Item Management Module) STEP 06
-- Extracted from polymorphic_validations.sql on 2025-04-16

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

-- ==========================================
-- CASCADE DELETE FUNCTIONS
-- ==========================================

-- Function to handle cascading deletes for users (item ownership)
CREATE OR REPLACE FUNCTION handle_user_delete_item()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related items where the user is the owner
    DELETE FROM item WHERE owner_id = OLD.id AND item_owner_type = 'user';
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Function to handle cascading deletes for businesses (item ownership)
CREATE OR REPLACE FUNCTION handle_business_delete_item()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related items where the business is the owner
    DELETE FROM item WHERE owner_id = OLD.id AND item_owner_type = 'business';
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

-- Trigger for handling cascading deletes when a user is deleted (item ownership)
CREATE TRIGGER handle_user_delete_item_trigger
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION handle_user_delete_item();

-- Trigger for handling cascading deletes when a business is deleted (item ownership)
CREATE TRIGGER handle_business_delete_item_trigger
BEFORE DELETE ON business
FOR EACH ROW
EXECUTE FUNCTION handle_business_delete_item();

-- Trigger for handling cascading deletes when an item is deleted
CREATE TRIGGER handle_item_delete_trigger
BEFORE DELETE ON item
FOR EACH ROW
EXECUTE FUNCTION handle_item_delete();

-- ==========================================
-- DOCUMENTATION
-- ==========================================
/*
This file implements database-level checks for polymorphic item-owner relationships in the Rentable database (Item Management module).

Polymorphic relationship managed:
1. Item table: owner_id + item_owner_type (references "user" or business)

For this relationship, we implement:
- Validation functions that check if the referenced entity exists
- Triggers that execute these validation functions on INSERT and UPDATE operations
- Cascade delete functions and triggers to maintain data integrity when entities are deleted

These validations replace traditional foreign key constraints, which cannot handle polymorphic relationships directly in PostgreSQL.
*/
