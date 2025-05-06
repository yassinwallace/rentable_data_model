# Document Management Module - AI Context

## [CRITICAL] Module Purpose

The Document Management module (04) handles all compliance-related documents in the Rentable system. It manages the uploading, storage, verification, and tracking of various document types required for equipment rental operations, including manuals, certificates, licenses, and agreements.

## [IMPORTANT] Key Entities

### 1. Document Type

**Purpose**: Defines categories and requirements for different types of documents.

**Entity**: `document_type`
- Categorized by `document_category` enum (equipment, unit, operator, order)
- Has name and description
- Includes flags for mandatory status, verification requirements, and expiration dates

**Business Rules**:
- Pre-populated with standard document types for each category
- Mandatory documents must be present before equipment handover
- Some documents require verification by administrators
- Some documents have expiration dates that must be tracked

**Real-World Examples**:
- **Equipment-Level Documents**:
  - User manuals
  - Safety instructions
  - Emission certificates
  - Regulatory compliance certificates (CE/OSHA)
  - Insurance documentation
  - Warranty certificates
  
- **Unit-Level Documents**:
  - Inspection reports
  - Service records
  - Calibration logs
  - Damage reports
  
- **Operator/Profile Documents**:
  - Driver's licenses
  - Operating certifications
  - Worksite access permits
  - Insurance certificates
  
- **Order-Level Documents**:
  - Rental agreements
  - Signed waivers
  - Pre-rental checklists
  - Return inspection forms
  - Damage claim files

### 2. Document

**Purpose**: Stores information about uploaded document files.

**Entity**: `document`
- Links to a document type via `document_type_id`
- Contains file information: path, size, type
- Tracks upload details: who uploaded and when
- Includes verification status, verifier, and verification time
- Supports versioning and expiration dates
- Allows for custom metadata via JSONB field

**Business Rules**:
- Documents follow a verification workflow (pending → approved/rejected)
- Expired documents are marked with special status
- Documents can be versioned to maintain history
- Required documents can block workflow progression until provided
- Documents with expiration dates trigger notifications before expiry

### 3. Entity Document Associations

**Purpose**: Links documents to various entity types with access control.

**Entities**: 
- `item_document`: Links documents to items
- `item_unit_document`: Links documents to specific item units
- `profile_document`: Links documents to user/organization profiles
- `order_document`: Links documents to orders

**Common Fields**:
- Entity ID (e.g., `item_id`, `profile_id`)
- Document ID via `document_id`
- Access level via `access_level` enum
- Creation timestamp

**Business Rules**:
- Documents can be associated with multiple entity types
- Access levels control visibility (private, internal, restricted, public)
- The same document might have different access levels in different contexts
- Access control determines who can view sensitive documents

**Access Control Levels**:
- `private`: Only visible to the owner and administrators
- `internal`: Visible to all members of the organization
- `restricted`: Visible to specific roles or in specific contexts
- `public`: Visible to anyone with access to the entity

## [CONTEXT] Relationships with Other Modules

### User Management Module
- Documents can be associated with profiles
- Users upload and verify documents

### Item Management Module
- Documents can be associated with items and item units
- Equipment-specific documentation is managed here

### Order Management Module
- Documents can be associated with orders
- Rental agreements and inspection forms are tracked

## [IMPORTANT] Implementation Patterns

### Document Categories
- The `document_category` enum classifies documents by their associated entity type
- This affects how documents are used and displayed in the system

### Access Control
- The `document_access_level` enum provides granular control over document visibility
- Access is controlled at the relationship level, not the document level

### Verification Workflow
- The `document_verification_status` enum tracks the approval process
- Documents progress through a defined verification lifecycle

## [CONTEXT] Technical Notes

1. This module was implemented to support compliance requirements
2. Document content is stored as files with paths in the database
3. The module follows the standard naming convention: `04_document_management_module.sql`

## [CRITICAL] Business Context

Document management is crucial for equipment rental operations due to:

1. **Regulatory Compliance**:
   - Equipment must meet safety and emissions standards
   - Operators must have proper certifications
   - Documentation must be available for inspection

2. **Liability Management**:
   - Waivers and agreements protect all parties
   - Inspection forms document equipment condition
   - Damage claims require supporting documentation

3. **Operational Requirements**:
   - Manuals ensure proper equipment operation
   - Maintenance logs track service history
   - Calibration certificates ensure accuracy

The document management system ensures that all required documentation is:
- Properly uploaded and stored
- Verified by appropriate personnel
- Available to relevant parties
- Tracked for expiration and renewal

This supports both legal compliance and operational efficiency in the equipment rental process.
