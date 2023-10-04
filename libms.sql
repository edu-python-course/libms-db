-- drop existing tables to avoid errors while re-creating them
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS revenue;
DROP TABLE IF EXISTS borrow_request;

-- label: ddl-publisher
CREATE TABLE publisher
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(128) NOT NULL CHECK (LENGTH(name) > 0),
    email   VARCHAR(255),
    street  VARCHAR(255),
    city    VARCHAR(255),
    state   VARCHAR(255),
    postal  VARCHAR(16),
    website VARCHAR(255),
    phone   VARCHAR(32)
);

COMMENT ON TABLE publisher IS 'publisher registered within a library db';
COMMENT ON COLUMN publisher.name IS 'non-zero length publisher name';

ALTER TABLE publisher
    OWNER TO libms;

-- label: ddl-author
CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    country    VARCHAR(255),
    CHECK ( LENGTH(first_name) > 0 ),
    CHECK ( LENGTH(last_name) > 0 )
);

COMMENT ON TABLE author IS '';
COMMENT ON COLUMN author.first_name IS 'non-zero length author''s first name';
COMMENT ON COLUMN author.last_name IS 'non-zero length author''s last name';

ALTER TABLE author
    OWNER TO libms;

-- label: ddl-book
CREATE TABLE book
(
    id SERIAL PRIMARY KEY
);

ALTER TABLE book
    OWNER TO libms;

-- label: ddl-book_author
CREATE TABLE book_author
(
    id SERIAL PRIMARY KEY
);

ALTER TABLE book_author
    OWNER TO libms;

-- label: ddl-member
CREATE TABLE member
(
    id SERIAL PRIMARY KEY
);

ALTER TABLE member
    OWNER TO libms;

-- label: ddl-revenue
CREATE TABLE revenue
(
    id SERIAL PRIMARY KEY
);

ALTER TABLE revenue
    OWNER TO libms;

-- label: ddl-borrow_request
CREATE TABLE borrow_request
(
    id SERIAL PRIMARY KEY
);

ALTER TABLE borrow_request
    OWNER TO libms;
