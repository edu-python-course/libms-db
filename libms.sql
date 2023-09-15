/**
  Library Management System
  =========================
 */

-- clean up existing database
-- the order tables are dropped matters (avoid CASCADE)
DROP TABLE IF EXISTS borrow_request;
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;

-- create tables

-- label: author ddl
-- todo: provide documentation on table
/**
  Authors
  -------
 */
CREATE TABLE author
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    summary TEXT,
    born    DATE CHECK (born <= CURRENT_DATE - INTERVAL '10 years')
);
ALTER TABLE author
    OWNER TO libms;

COMMENT ON TABLE author IS 'registered authors';
COMMENT ON COLUMN author.id IS 'pkey - unique author identifier';
COMMENT ON COLUMN author.born IS 'cannot be younger than 10 years';

-- label: publisher ddl
-- todo: provide documentation on table
/**
  Publishers
  ----------
 */
CREATE TABLE publisher
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    country VARCHAR(64)
);
ALTER TABLE publisher
    OWNER TO libms;

COMMENT ON TABLE publisher IS 'registered publishers';

-- label: customer ddl
-- todo: provide documentation on table
/**
  Customers
  ---------
 */
CREATE TABLE customer
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL CHECK (LENGTH(first_name) > 0),
    last_name  VARCHAR(64) NOT NULL CHECK (LENGTH(last_name) > 0)
);
ALTER TABLE customer
    OWNER TO libms;

COMMENT ON TABLE customer IS 'regular library customers';
COMMENT ON COLUMN customer.first_name IS 'cannot be an empty string';
COMMENT ON COLUMN customer.last_name IS 'cannot be an empty string';

-- label: book ddl
-- todo: provide documentation on table
/**
  Books
  -----
 */
CREATE TABLE book
(
    id        SERIAL PRIMARY KEY,
    title     VARCHAR(255) NOT NULL CHECK (LENGTH(title) > 0),
    isbn      VARCHAR(32)  NOT NULL,
    summary   TEXT,
    published INTEGER,
    publisher INTEGER      NOT NULL REFERENCES publisher,
    borrower  INTEGER REFERENCES customer
);
ALTER TABLE book
    OWNER TO libms;

COMMENT ON TABLE book IS 'available books';

-- label: book_author ddl
-- todo: provide documentation on table
/**
  Books authors relationship
  --------------------------
 */
CREATE TABLE book_author
(
    book_id   INTEGER NOT NULL REFERENCES book,
    author_id INTEGER NOT NULL REFERENCES author,
    UNIQUE (book_id, author_id)
);
ALTER TABLE book_author
    OWNER TO libms;

COMMENT ON TABLE book_author IS 'books-authors relationships table';
COMMENT ON COLUMN book_author.book_id IS 'unique together with author_id';
COMMENT ON COLUMN book_author.author_id IS 'unique together with book_id';

-- label: borrow_request ddl
-- todo: provide documentation on table
/**
  Customers borrow requests
  -------------------------
 */
CREATE TABLE borrow_request
(
    customer_id INTEGER NOT NULL REFERENCES customer (id),
    book_id     INTEGER NOT NULL REFERENCES book (id),
    approved    BOOLEAN,
    borrow      DATE    NOT NULL,
    due         DATE    NOT NULL DEFAULT CURRENT_DATE + INTERVAL '2 weeks',
    complete    DATE    NOT NULL,
    CONSTRAINT complete_date_check
        CHECK (CURRENT_DATE >= complete AND complete >= borrow)
);
ALTER TABLE borrow_request
    OWNER TO libms;

COMMENT ON TABLE borrow_request IS 'borrow requests from customers';
COMMENT ON COLUMN borrow_request.complete IS 'between borrow date and current date';
COMMENT ON COLUMN borrow_request.approved IS 'null means the request was not reviewed';
