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
    id SERIAL PRIMARY KEY
);

ALTER TABLE publisher
    OWNER TO libms;

-- label: ddl-author
CREATE TABLE author
(
    id SERIAL PRIMARY KEY
);

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
