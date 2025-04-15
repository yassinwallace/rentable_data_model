-- location_polymorphic_validations.sql
-- Validation and cascade logic for polymorphic relationships in the location module
-- This file should be executed after the location module tables are created

-- ==========================================
-- VALIDATION FUNCTION
-- ==========================================

CREATE OR REPLACE FUNCTION validate_location_link_entity()
RETURNS TRIGGER AS $$
DECLARE
    entity_exists BOOLEAN;
BEGIN
    IF NEW.linked_entity_type = 'user' THEN
        SELECT EXISTS(SELECT 1 FROM "user" WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSIF NEW.linked_entity_type = 'item' THEN
        SELECT EXISTS(SELECT 1 FROM item WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSIF NEW.linked_entity_type = 'business' THEN
        SELECT EXISTS(SELECT 1 FROM business WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSE
        RAISE EXCEPTION 'Invalid linked_entity_type: %', NEW.linked_entity_type;
    END IF;
    IF NOT entity_exists THEN
        RAISE EXCEPTION 'Referenced entity (type %, id %) does not exist', NEW.linked_entity_type, NEW.linked_entity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGER FOR VALIDATION
-- ==========================================

CREATE TRIGGER validate_location_link_entity_trigger
BEFORE INSERT OR UPDATE OF linked_entity_type, linked_entity_id ON location_link
FOR EACH ROW
EXECUTE FUNCTION validate_location_link_entity();

-- ==========================================
-- CASCADE DELETE FUNCTIONS
-- ==========================================

-- When a user is deleted, delete their location links
CREATE OR REPLACE FUNCTION handle_user_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'user' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_user_delete_location_link_trigger
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION handle_user_delete_location_link();

-- When an item is deleted, delete its location links
CREATE OR REPLACE FUNCTION handle_item_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'item' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_item_delete_location_link_trigger
BEFORE DELETE ON item
FOR EACH ROW
EXECUTE FUNCTION handle_item_delete_location_link();

-- When a business is deleted, delete its location links
CREATE OR REPLACE FUNCTION handle_business_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'business' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_business_delete_location_link_trigger
BEFORE DELETE ON business
FOR EACH ROW
EXECUTE FUNCTION handle_business_delete_location_link();

-- ==========================================
-- DOCUMENTATION
-- ==========================================
/*
This file implements validation and cascading delete logic for the polymorphic relationship in the location_link table.

- On INSERT/UPDATE, it checks that the referenced entity exists in the corresponding table based on linked_entity_type.
- On DELETE of a user, item, or business, it deletes associated location_link rows.

This replaces traditional FKs, which are not possible for polymorphic relationships in PostgreSQL.
*/
