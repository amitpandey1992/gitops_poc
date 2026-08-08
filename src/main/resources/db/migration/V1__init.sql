-- TaskFlow Pro — Initial Schema
-- Flyway Migration V1

-- Team Members table
CREATE TABLE IF NOT EXISTS team_members (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    role        VARCHAR(50)  NOT NULL DEFAULT 'DEVELOPER',
    avatar_url  VARCHAR(255),
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id           BIGSERIAL PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    status       VARCHAR(20)  NOT NULL DEFAULT 'TODO',
    priority     VARCHAR(20)  NOT NULL DEFAULT 'MEDIUM',
    assignee_id  BIGINT       REFERENCES team_members(id) ON DELETE SET NULL,
    due_date     DATE,
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_status   CHECK (status IN ('TODO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE')),
    CONSTRAINT chk_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

-- Indexes for performance
CREATE INDEX idx_tasks_status     ON tasks(status);
CREATE INDEX idx_tasks_assignee   ON tasks(assignee_id);
CREATE INDEX idx_tasks_priority   ON tasks(priority);

-- Seed Data — Demo Team
INSERT INTO team_members (name, email, role) VALUES
    ('Amit Pandey',   'amit.pandey@company.com',   'TECH_LEAD'),
    ('Priya Sharma',  'priya.sharma@company.com',  'DEVELOPER'),
    ('Raj Kumar',     'raj.kumar@company.com',     'DEVELOPER'),
    ('Sneha Singh',   'sneha.singh@company.com',   'QA_ENGINEER'),
    ('Vikram Nair',   'vikram.nair@company.com',   'DEVOPS_ENGINEER');

-- Seed Data — Demo Tasks
INSERT INTO tasks (title, description, status, priority, assignee_id, due_date) VALUES
    ('Setup GKE Cluster',          'Provision GKE Autopilot cluster with Terraform',        'DONE',        'HIGH',     1, NOW() - INTERVAL '5 days'),
    ('Configure Workload Identity', 'Setup WIF for keyless GitHub Actions auth',             'DONE',        'HIGH',     5, NOW() - INTERVAL '3 days'),
    ('Build TaskFlow Java App',    'Spring Boot 3 app with Thymeleaf UI',                   'IN_PROGRESS', 'HIGH',     2, NOW() + INTERVAL '2 days'),
    ('Write Helm Charts',          'Package application for Kubernetes deployment',          'IN_PROGRESS', 'MEDIUM',   5, NOW() + INTERVAL '3 days'),
    ('Install ArgoCD',             'GitOps controller setup on GKE cluster',                'TODO',        'HIGH',     5, NOW() + INTERVAL '4 days'),
    ('Configure CI Pipeline',      'GitHub Actions with Jib build and Artifactory push',    'TODO',        'MEDIUM',   3, NOW() + INTERVAL '5 days'),
    ('Setup Monitoring',           'Connect Prometheus metrics to Grafana dashboard',       'TODO',        'LOW',      4, NOW() + INTERVAL '7 days'),
    ('End-to-End GitOps Test',     'Push code → auto deploy via ArgoCD → verify',          'TODO',        'CRITICAL', 1, NOW() + INTERVAL '10 days');
