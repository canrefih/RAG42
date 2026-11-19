BEGIN;

-- ============================================================================
-- 1. PRINCIPALS (4 Departments & 10 Employees)
-- ============================================================================
-- Departments: 10000000-0000-0000-0000-00000000000X
INSERT INTO principals (principal_id, principal_type, department_name, first_name, last_name) VALUES
('10000000-0000-0000-0000-000000000001', 'department', 'Engineering', NULL, NULL),
('10000000-0000-0000-0000-000000000002', 'department', 'Sales', NULL, NULL),
('10000000-0000-0000-0000-000000000003', 'department', 'Finance', NULL, NULL),
('10000000-0000-0000-0000-000000000004', 'department', 'Human Resources', NULL, NULL);

-- Employees: 20000000-0000-0000-0000-00000000000X
INSERT INTO principals (principal_id, principal_type, department_name, first_name, last_name) VALUES
-- Engineering
('20000000-0000-0000-0000-000000000001', 'employee', NULL, 'Alice', 'Chen'),         -- Lead Engineer
('20000000-0000-0000-0000-000000000002', 'employee', NULL, 'Bob', 'Martinez'),       -- Backend Engineer
('20000000-0000-0000-0000-000000000003', 'employee', NULL, 'Charlie', 'Davis'),      -- DevOps Engineer
-- Sales
('20000000-0000-0000-0000-000000000004', 'employee', NULL, 'Diana', 'Prince'),       -- VP of Sales
('20000000-0000-0000-0000-000000000005', 'employee', NULL, 'Evan', 'Wright'),        -- Account Executive
('20000000-0000-0000-0000-000000000006', 'employee', NULL, 'Fiona', 'Gallagher'),    -- Account Executive
-- Finance
('20000000-0000-0000-0000-000000000007', 'employee', NULL, 'George', 'Kim'),         -- CFO
('20000000-0000-0000-0000-000000000008', 'employee', NULL, 'Hannah', 'Abbott'),      -- Financial Analyst
-- Human Resources
('20000000-0000-0000-0000-000000000009', 'employee', NULL, 'Ian', 'Malcolm'),        -- HR Director
('20000000-0000-0000-0000-000000000010', 'employee', NULL, 'Julia', 'Roberts');      -- Recruiter (also cross-assigned to Eng hiring)

-- ============================================================================
-- 2. GROUP MEMBERSHIPS
-- ============================================================================
INSERT INTO group_memberships (department_id, employee_id) VALUES
-- Engineering
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002'),
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003'),
-- Sales
('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004'),
('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000005'),
('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000006'),
-- Finance
('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000007'),
('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000008'),
-- Human Resources
('10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000009'),
('10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000010');

-- ============================================================================
-- 3. CLIENTS (5 Clients)
-- ============================================================================
INSERT INTO clients (client_id, company_name, first_name, last_name) VALUES
('30000000-0000-0000-0000-000000000001', 'Acme Corp', 'Wile', 'Coyote'),
('30000000-0000-0000-0000-000000000002', 'Globex Corporation', 'Hank', 'Scorpio'),
('30000000-0000-0000-0000-000000000003', 'Initech', 'Bill', 'Lumbergh'),
('30000000-0000-0000-0000-000000000004', 'Umbrella Biotech', 'Albert', 'Wesker'),
('30000000-0000-0000-0000-000000000005', 'Stark Industries', 'Pepper', 'Potts');

-- ============================================================================
-- 4. ITEMS (14 Items: 7 Emails + 7 Files covering all RBAC scenarios)
-- ============================================================================
INSERT INTO items (id, item_type, title, access_scope) VALUES
-- SCENARIO A: Accessible by ALL (access_scope = 'all')
('40000000-0000-0000-0000-000000000001', 'email', '2026 Company Holiday & Remote Work Policy', 'all'),
('40000000-0000-0000-0000-000000000002', 'file',  'Employee_Handbook_2026.pdf', 'all'),

-- SCENARIO B: Accessible by ONLY ONE EMPLOYEE (restricted)
('40000000-0000-0000-0000-000000000003', 'file',  'Executive_Compensation_Review_2026.xlsx', 'restricted'), -- Only Ian Malcolm (HR)
('40000000-0000-0000-0000-000000000004', 'email', 'CONFIDENTIAL: Board Restructuring Notes', 'restricted'),   -- Only George Kim (CFO)

-- SCENARIO C: Accessible by MANY EMPLOYEES, NOT entire department (restricted)
('40000000-0000-0000-0000-000000000005', 'email', 'Project Phoenix: Secret Acquisition Kickoff', 'restricted'), -- Alice (Eng), Diana (Sales), George (Fin)
('40000000-0000-0000-0000-000000000006', 'file',  'Project_Phoenix_Valuation_Model.pdf', 'restricted'),      -- Attachment to email 05; same 3 employees

-- SCENARIO D: Accessible by ONE DEPARTMENT (restricted)
('40000000-0000-0000-0000-000000000007', 'email', 'Acme Corp API Integration Bug Report', 'restricted'),       -- Engineering Dept only
('40000000-0000-0000-0000-000000000008', 'file',  'Acme_API_Architecture_Spec_v2.md', 'restricted'),         -- Attachment to email 07; Engineering Dept only
('40000000-0000-0000-0000-000000000009', 'file',  'Q3_Enterprise_Sales_Playbook.pdf', 'restricted'),         -- Standalone file; Sales Dept only

-- SCENARIO E: Accessible by MULTIPLE DEPARTMENTS (restricted)
('40000000-0000-0000-0000-000000000010', 'email', 'Globex Corporation Enterprise Contract Renewal', 'restricted'), -- Sales + Finance
('40000000-0000-0000-0000-000000000011', 'file',  'Globex_MSA_Signed_2026.pdf', 'restricted'),                     -- Attachment to email 10; Sales + Finance
('40000000-0000-0000-0000-000000000012', 'email', 'Stark Industries Custom Cloud Deployment SOW', 'restricted'),    -- Engineering + Sales
('40000000-0000-0000-0000-000000000013', 'file',  'Stark_Cloud_Security_Audit.pdf', 'restricted'),                 -- Attachment to email 12; Engineering + Sales
('40000000-0000-0000-0000-000000000014', 'email', 'Initech Payroll Software Migration Update', 'restricted');      -- Finance + HR

-- ============================================================================
-- 5. ITEM ACCESS (Explicit ACLs for 'restricted' items)
-- ============================================================================
INSERT INTO item_access (item_id, principal_id) VALUES
-- Scenario B: Single Employee
('40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000009'), -- Ian Malcolm
('40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000007'), -- George Kim

-- Scenario C: Specific Cross-Functional Employees (Alice, Diana, George)
('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000001'),
('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000004'),
('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000007'),
('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000001'),
('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000004'),
('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000007'),

-- Scenario D: Single Department
('40000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000001'), -- Engineering
('40000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001'), -- Engineering
('40000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000002'), -- Sales

-- Scenario E: Multiple Departments
('40000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002'), -- Sales
('40000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000003'), -- Finance
('40000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000002'), -- Sales
('40000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000003'), -- Finance
('40000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001'), -- Engineering
('40000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002'), -- Sales
('40000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001'), -- Engineering
('40000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000002'), -- Sales
('40000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000003'), -- Finance
('40000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000004'); -- HR

-- ============================================================================
-- 6. ITEM CLIENTS (Linking Items to Clients)
-- ============================================================================
INSERT INTO item_clients (item_id, client_id) VALUES
('40000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000004'), -- Umbrella Biotech
('40000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000004'), -- Umbrella Biotech
('40000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000001'), -- Acme Corp
('40000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000001'), -- Acme Corp
('40000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000002'), -- Globex Corp
('40000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000002'), -- Globex Corp
('40000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000005'), -- Stark Industries
('40000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000005'), -- Stark Industries
('40000000-0000-0000-0000-000000000014', '30000000-0000-0000-0000-000000000003'); -- Initech

-- ============================================================================
-- 7. EMAILS (7 Emails)
-- ============================================================================
INSERT INTO emails (item_id, sender_email, to_addresses, cc_addresses, sent_received_at, direction, body_text) VALUES
(
    '40000000-0000-0000-0000-000000000001',
    'ian.malcolm@company.com',
    '["all-staff@company.com"]'::json,
    NULL,
    '2026-01-10 09:00:00',
    'outgoing',
    'Hi Team, Please review the updated 2026 Remote Work Policy. Employees may work remotely up to 3 days per week (Tuesday, Wednesday, Thursday). Office core hours are 10:00 AM to 4:00 PM CET. See attached handbook.'
),
(
    '40000000-0000-0000-0000-000000000004',
    'george.kim@company.com',
    '["george.kim@company.com"]'::json,
    NULL,
    '2026-03-15 18:45:00',
    'outgoing',
    'Personal memo for Q2 Board Meeting: We are considering consolidating the European regional offices into Zurich to save $1.2M annually in overhead.'
),
(
    '40000000-0000-0000-0000-000000000005',
    'george.kim@company.com',
    '["alice.chen@company.com", "diana.prince@company.com"]'::json,
    NULL,
    '2026-05-02 14:20:00',
    'outgoing',
    'Team, Project Phoenix is our confidential bid to acquire Umbrella Biotech''s data analytics division for $45M. Do not discuss this outside this thread. Attached is the valuation model.'
),
(
    '40000000-0000-0000-0000-000000000007',
    'wile.coyote@acmecorp.com',
    '["alice.chen@company.com", "bob.martinez@company.com"]'::json,
    '["charlie.davis@company.com"]'::json,
    '2026-06-18 11:12:00',
    'incoming',
    'Hello Engineering, We are hitting HTTP 429 rate-limit errors on the /v2/webhooks endpoint whenever payload bursts exceed 500 requests/sec. Please check the attached architecture spec.'
),
(
    '40000000-0000-0000-0000-000000000010',
    'hank.scorpio@globex.com',
    '["diana.prince@company.com"]'::json,
    '["george.kim@company.com", "hannah.abbott@company.com"]'::json,
    '2026-08-04 16:05:00',
    'incoming',
    'Diana, Globex Corporation approves the 3-year enterprise license renewal at $240,000/year with Net-30 payment terms. Signed MSA is attached.'
),
(
    '40000000-0000-0000-0000-000000000012',
    'pepper.potts@starkindustries.com',
    '["diana.prince@company.com", "alice.chen@company.com"]'::json,
    '["evan.wright@company.com"]'::json,
    '2026-09-22 10:30:00',
    'incoming',
    'Hi Diana and Alice, Before we sign the Statement of Work for the dedicated VPC deployment, our InfoSec team requires confirmation of SOC2 Type II compliance and AES-256 encryption at rest.'
),
(
    '40000000-0000-0000-0000-000000000014',
    'bill.lumbergh@initech.com',
    '["hannah.abbott@company.com", "ian.malcolm@company.com"]'::json,
    NULL,
    '2026-10-11 15:00:00',
    'incoming',
    'Yeah, hi. Just checking in on the Initech payroll API sync. We need the Q4 tax withholding tables updated by November 30th so Friday pay runs don''t fail.'
);

-- ============================================================================
-- 8. FILES (7 Files: 5 Email Attachments + 2 Standalone Files)
-- ============================================================================
INSERT INTO files (item_id, parent_email_item_id, mime_type, content_text) VALUES
(
    '40000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000001', -- Attachment to Email 01
    'application/pdf',
    'Employee Handbook 2026. Section 1: Annual PTO is 25 days for all full-time employees. Section 2: Wellness stipend is $1,000 per calendar year. Section 3: Standard travel reimbursement requires receipts for expenses over $25.'
),
(
    '40000000-0000-0000-0000-000000000003',
    NULL, -- Standalone File
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '2026 Executive Compensation Table: CEO Base $420,000 (Bonus 40%), CFO Base $360,000 (Bonus 35%), VP Sales Base $310,000 (Commission OTE $500,000).'
),
(
    '40000000-0000-0000-0000-000000000006',
    '40000000-0000-0000-0000-000000000005', -- Attachment to Email 05
    'application/pdf',
    'Project Phoenix Valuation Model: Target entity Umbrella Biotech Analytics Division. Trailing 12-month ARR: $8.5M. Proposed acquisition price: $45.0M (5.3x ARR multiple). Target closing date: December 15, 2026.'
),
(
    '40000000-0000-0000-0000-000000000008',
    '40000000-0000-0000-0000-000000000007', -- Attachment to Email 07
    'text/markdown',
    '# Acme Corp Webhook Architecture v2\nCurrent Redis token-bucket rate limiter allows 400 req/sec burst. To support Acme Corp''s 500 req/sec requirement, increase Redis worker concurrency from 8 to 16 and raise burst ceiling to 750 req/sec.'
),
(
    '40000000-0000-0000-0000-000000000009',
    NULL, -- Standalone File
    'application/pdf',
    'Q3 Enterprise Sales Playbook: Maximum discount without CFO approval is 15%. Multi-year contracts (3+ years) qualify for an additional 5% discount. Standard SLA uptime guarantee is 99.9%.'
),
(
    '40000000-0000-0000-0000-000000000011',
    '40000000-0000-0000-0000-000000000010', -- Attachment to Email 10
    'application/pdf',
    'Master Services Agreement - Globex Corporation. Term: 36 months starting September 1, 2026. Annual Contract Value (ACV): $240,000. Total Contract Value (TCV): $720,000. Early termination penalty: 50% of remaining balance.'
),
(
    '40000000-0000-0000-0000-000000000013',
    '40000000-0000-0000-0000-000000000012', -- Attachment to Email 12
    'application/pdf',
    'Stark Industries Security & Compliance Attestation: Infrastructure is hosted on AWS eu-central-1 (Frankfurt). All PostgreSQL databases use AES-256 encryption at rest and TLS 1.3 in transit. SOC2 Type II report issued April 2026.'
);

-- ============================================================================
-- 9. CONTENT CHUNKS (RAG Chunks with 1536-dim Dummy Vectors)
-- ============================================================================
-- Note: Uses a helper expression to generate valid 1536-dim pgvector values
-- so vector similarity queries (<=> or <->) run immediately without errors.

INSERT INTO content_chunks (item_id, chunk_index, content_text, embedding)
SELECT
    v.item_id,
    v.chunk_index,
    v.content_text,
    (
        SELECT ('[' || string_agg((( (i * v.seed) % 100 ) / 100.0)::text, ',') || ']')::vector
        FROM generate_series(1, 1536) AS i
    ) AS embedding
FROM (VALUES
    -- Item 01 (Email - All)
    ('40000000-0000-0000-0000-000000000001'::uuid, 0, '2026 Remote Work Policy: Employees may work remotely up to 3 days per week (Tuesday, Wednesday, Thursday). Office core hours are 10:00 AM to 4:00 PM CET.', 11),
    -- Item 02 (File - All)
    ('40000000-0000-0000-0000-000000000002'::uuid, 0, 'Employee Handbook 2026 Section 1 & 2: Annual PTO is 25 days for all full-time employees. Wellness stipend is $1,000 per calendar year.', 12),
    ('40000000-0000-0000-0000-000000000002'::uuid, 1, 'Employee Handbook 2026 Section 3: Standard travel reimbursement requires itemized receipts for any expense over $25.', 13),
    -- Item 03 (File - Single Employee: Ian Malcolm)
    ('40000000-0000-0000-0000-000000000003'::uuid, 0, '2026 Executive Compensation Table: CEO Base $420,000 (Bonus 40%), CFO Base $360,000 (Bonus 35%), VP Sales Base $310,000 (Commission OTE $500,000).', 21),
    -- Item 04 (Email - Single Employee: George Kim)
    ('40000000-0000-0000-0000-000000000004'::uuid, 0, 'Confidential Q2 Board Memo: Consolidating European regional offices into Zurich is projected to save $1.2M annually in real estate overhead.', 22),
    -- Item 05 (Email - Specific Employees: Alice, Diana, George)
    ('40000000-0000-0000-0000-000000000005'::uuid, 0, 'Project Phoenix Kickoff: Confidential bid to acquire Umbrella Biotech''s data analytics division for $45M. Restricted to Alice Chen, Diana Prince, and George Kim.', 31),
    -- Item 06 (File - Specific Employees: Alice, Diana, George)
    ('40000000-0000-0000-0000-000000000006'::uuid, 0, 'Project Phoenix Valuation Model: Umbrella Biotech Analytics Division trailing 12-month ARR is $8.5M. Proposed acquisition price is $45.0M (5.3x ARR multiple), closing December 15, 2026.', 32),
    -- Item 07 (Email - Single Dept: Engineering)
    ('40000000-0000-0000-0000-000000000007'::uuid, 0, 'Acme Corp Bug Report: Experiencing HTTP 429 rate-limit errors on /v2/webhooks when payload bursts exceed 500 requests/sec.', 41),
    -- Item 08 (File - Single Dept: Engineering)
    ('40000000-0000-0000-0000-000000000008'::uuid, 0, 'Acme Corp Webhook Architecture v2: Increase Redis worker concurrency from 8 to 16 and raise token-bucket burst ceiling from 400 to 750 req/sec.', 42),
    -- Item 09 (File - Single Dept: Sales)
    ('40000000-0000-0000-0000-000000000009'::uuid, 0, 'Q3 Enterprise Sales Playbook: Maximum discount without CFO approval is 15%. Multi-year contracts (3+ years) qualify for an additional 5% discount. Standard SLA is 99.9%.', 43),
    -- Item 10 (Email - Multi Dept: Sales + Finance)
    ('40000000-0000-0000-0000-000000000010'::uuid, 0, 'Globex Corporation Renewal: Approved 3-year enterprise license renewal at $240,000/year with Net-30 payment terms.', 51),
    -- Item 11 (File - Multi Dept: Sales + Finance)
    ('40000000-0000-0000-0000-000000000011'::uuid, 0, 'Globex Corporation MSA: 36-month term starting September 1, 2026. ACV is $240,000, TCV is $720,000. Early termination penalty is 50% of remaining contract balance.', 52),
    -- Item 12 (Email - Multi Dept: Engineering + Sales)
    ('40000000-0000-0000-0000-000000000012'::uuid, 0, 'Stark Industries Cloud SOW: InfoSec requires SOC2 Type II compliance and AES-256 encryption at rest before signing the dedicated VPC Statement of Work.', 53),
    -- Item 13 (File - Multi Dept: Engineering + Sales)
    ('40000000-0000-0000-0000-000000000013'::uuid, 0, 'Stark Industries Security Attestation: Hosted on AWS eu-central-1 (Frankfurt). PostgreSQL databases use AES-256 encryption at rest and TLS 1.3 in transit. SOC2 Type II issued April 2026.', 54),
    -- Item 14 (Email - Multi Dept: Finance + HR)
    ('40000000-0000-0000-0000-000000000014'::uuid, 0, 'Initech Payroll Migration: Q4 tax withholding tables must be updated by November 30, 2026 to prevent Friday payroll run failures.', 55)
) AS v(item_id, chunk_index, content_text, seed);

COMMIT;