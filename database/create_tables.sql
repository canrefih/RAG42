-- Required for vector embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. GROUP_MEMBERSHIPS
CREATE TABLE group_memberships (
    department_id UUID NOT NULL,
    employee_id UUID NOT NULL,
    PRIMARY KEY (department_id, employee_id)
);

-- 2. PRINCIPALS
CREATE TABLE principals (
    principal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    principal_type VARCHAR(10) NOT NULL
        CHECK (principal_type IN ('department', 'employee')),
    department_name VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

-- 3. ITEM_ACCESS
CREATE TABLE item_access (
    item_id UUID NOT NULL,
    principal_id UUID NOT NULL,
    PRIMARY KEY (item_id, principal_id)
);

-- 4. CLIENTS
CREATE TABLE clients (
    client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

-- 5. ITEM_CLIENTS
CREATE TABLE item_clients (
    item_id UUID NOT NULL,
    client_id UUID NOT NULL,
    PRIMARY KEY (item_id, client_id)
);

-- 6. ITEMS
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_type VARCHAR(5) NOT NULL
        CHECK (item_type IN ('email', 'file')),
    title TEXT,
    access_scope VARCHAR(10) NOT NULL
        CHECK (access_scope IN ('all', 'restricted'))
);

-- 7. EMAILS
CREATE TABLE emails (
    item_id UUID PRIMARY KEY,
    sender_email VARCHAR(255) NOT NULL,
    to_addresses JSON NOT NULL,
    cc_addresses JSON,
    sent_received_at TIMESTAMP NOT NULL,
    direction VARCHAR(10),
        CHECK (direction IN ('incoming', 'outgoing')),
    body_text TEXT
);

-- 8. DOCUMENTS / ATTACHMENTS
CREATE TABLE files (
    item_id UUID PRIMARY KEY,
    parent_email_item_id UUID,
    mime_type VARCHAR(255),
    content_text TEXT
);

-- 9. CONTENT_CHUNKS
CREATE TABLE content_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    chunk_index INTEGER NOT NULL,
    content_text TEXT NOT NULL,
    embedding VECTOR
);


-- 1. GROUP_MEMBERSHIPS -> PRINCIPALS

ALTER TABLE group_memberships
ADD CONSTRAINT fk_membership_department
FOREIGN KEY (department_id)
REFERENCES principals(principal_id);

ALTER TABLE group_memberships
ADD CONSTRAINT fk_membership_employee
FOREIGN KEY (employee_id)
REFERENCES principals(principal_id);


-- 2. ITEM_ACCESS -> ITEMS / PRINCIPALS

ALTER TABLE item_access
ADD CONSTRAINT fk_access_item
FOREIGN KEY (item_id)
REFERENCES items(id);

ALTER TABLE item_access
ADD CONSTRAINT fk_access_principal
FOREIGN KEY (principal_id)
REFERENCES principals(principal_id);


-- 3. ITEM_CLIENTS -> ITEMS / CLIENTS

ALTER TABLE item_clients
ADD CONSTRAINT fk_item_clients_item
FOREIGN KEY (item_id)
REFERENCES items(id);

ALTER TABLE item_clients
ADD CONSTRAINT fk_item_clients_client
FOREIGN KEY (client_id)
REFERENCES clients(client_id);


-- 4. EMAILS -> ITEMS

ALTER TABLE emails
ADD CONSTRAINT fk_emails_item
FOREIGN KEY (item_id)
REFERENCES items(id);


-- 5. FILES -> ITEMS

ALTER TABLE files
ADD CONSTRAINT fk_files_item
FOREIGN KEY (item_id)
REFERENCES items(id);


-- 6. FILES -> EMAILS
-- One email can have multiple attachments.

ALTER TABLE files
ADD CONSTRAINT fk_files_parent_email
FOREIGN KEY (parent_email_item_id)
REFERENCES emails(item_id);


-- 7. CONTENT_CHUNKS -> ITEMS

ALTER TABLE content_chunks
ADD CONSTRAINT fk_chunks_item
FOREIGN KEY (item_id)
REFERENCES items(id);


-- 7. Unique chunk_index -> ITEMS

ALTER TABLE content_chunks
ADD CONSTRAINT uq_item_chunk
UNIQUE (item_id, chunk_index);
