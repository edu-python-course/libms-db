/**
  Library Management System
  =========================
 */

-- clean up existing database
-- the order tables are dropped matters (avoid CASCADE)
DROP TABLE IF EXISTS borrow_request;
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS revenue;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;

-- create tables

-- label: author ddl
/**
  Authors
  -------

  The "author" table is designed to store detailed information about
  authors known to the Library Management System (`libms`).

  This table is referenced by other tables in the system that need to
  associate content or transactions with a specific author.

 */
CREATE TABLE author
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    summary TEXT,
    born    DATE CHECK (born <= CURRENT_DATE - INTERVAL '10 years')
);
ALTER TABLE author
    OWNER TO libms; -- change table owner to "libms" user

COMMENT ON TABLE author
    IS 'registered authors';
COMMENT ON COLUMN author.id
    IS 'pkey - unique author identifier';
COMMENT ON COLUMN author.born
    IS 'cannot be younger than 10 years';

-- label: publisher ddl
/**
  Publishers
  ----------

  The "publisher" table is designed to store detailed information about
  publishers known to the Library Management System (`libms`).

  This table is referenced by other tables in the system that need to
  associate books or content with a specific publisher.

 */
CREATE TABLE publisher
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    country VARCHAR(64)
);
ALTER TABLE publisher
    OWNER TO libms;

COMMENT ON TABLE publisher
    IS 'registered publishers';

-- label: member ddl
/**
  Members
  -------

  The "member" table captures essential information about each
  member registered with the Library Management System (`libms`).

  The member table plays a central role in many transactions within
  the library system. It's crucial for associating borrow requests,
  revenue details, and potentially any customer-specific preferences
  or activities in the future.

 */
CREATE TABLE member
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL CHECK (LENGTH(first_name) > 0),
    last_name  VARCHAR(64) NOT NULL CHECK (LENGTH(last_name) > 0)
);
ALTER TABLE member
    OWNER TO libms;

COMMENT ON TABLE member
    IS 'regular library members';
COMMENT ON COLUMN member.first_name
    IS 'cannot be an empty string';
COMMENT ON COLUMN member.last_name
    IS 'cannot be an empty string';

-- label: revenue ddl
/**
  Revenue
  -------

  The "revenue" table tracks the financial transactions related to
  the Library Management System (`libms`), including any fees,
  membership charges, or other payments made by customers.

  The revenue table is pivotal for the library's financial management.
  It allows for tracking of income from customers and can be cross-referenced
  with other tables to ascertain specific transaction details or
  to generate financial reports.

 */
CREATE TABLE revenue
(
    id        SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES member,
    amount    INTEGER NOT NULL CHECK (amount > 0),
    date      DATE DEFAULT NOW()::DATE
);
ALTER TABLE revenue
    OWNER TO libms;

COMMENT ON TABLE revenue
    IS 'library revenue from the customers';
COMMENT ON COLUMN revenue.amount
    IS 'income amount in coins';
COMMENT ON COLUMN revenue.date
    IS 'payment day, defaults to the current date';

-- label: book ddl
/**
  Book
  ----

  The "book" table catalogs the collection of books available within
  the Library Management System (`libms`). It encompasses detailed
  information about each book, ensuring easy referencing and management
  of the library's assets.

  Librarians can use the "book" table to check the availability of a particular
  book, update book details, or add new books to the collection. Additionally,
  by referencing the `borrower` column, they can quickly determine which books
  are currently on loan and to whom.

 */
CREATE TABLE book
(
    id        SERIAL PRIMARY KEY,
    title     VARCHAR(255) NOT NULL CHECK (LENGTH(title) > 0),
    isbn      VARCHAR(32)  NOT NULL,
    summary   TEXT,
    published INTEGER,
    publisher INTEGER      NOT NULL REFERENCES publisher,
    borrower INTEGER REFERENCES member
);
ALTER TABLE book
    OWNER TO libms;

COMMENT ON TABLE book
    IS 'available books';
COMMENT ON COLUMN book.isbn
    IS 'international standard book number';
COMMENT ON COLUMN book.borrower
    IS 'indicates current borrower, if applicable';
COMMENT ON COLUMN book.published
    IS 'publication year';

-- label: book_author ddl
/**
  Book-Author Relationship
  ------------------------

  The "book_author" table establishes a many-to-many relationship between books
  and authors within the Library Management System (`libms`). This relationship
  allows for the representation of books written by multiple authors and
  authors who have written multiple books.

  The combination of `book_id` and `author_id` must be unique, ensuring that
  each pairing of book and author is represented only once in the table.

  The "book_author" table can be queried to retrieve all authors of a specific
  book or all books written by a particular author. This relationship is
  fundamental in scenarios where detailed bibliographic information is needed,
  such as in book catalogs or author bibliographies.

 */
CREATE TABLE book_author
(
    book_id   INTEGER NOT NULL REFERENCES book,
    author_id INTEGER NOT NULL REFERENCES author,
    UNIQUE (book_id, author_id)
);
ALTER TABLE book_author
    OWNER TO libms;

COMMENT ON TABLE book_author
    IS 'books-authors relationships table';
COMMENT ON COLUMN book_author.book_id
    IS 'unique together with author_id';
COMMENT ON COLUMN book_author.author_id
    IS 'unique together with book_id';

-- label: borrow_request ddl
/**
  Borrow Requests
  ---------------

  Table Purpose:
  The "borrow_request" table tracks requests made by library customers
  to borrow specific books. Each entry in this table represents an individual
  request, whether it's approved or still pending.

  `complete_date_check` constraint ensures that the complete date is always
  between the borrow date and the current date.

  Library staff can query the "borrow_request" table to manage and track borrow
  requests, understand borrowing patterns, and ensure timely returns.
  It also serves as a log for the borrowing history of each customer, allowing
  for potential insights into customer preferences and behavior.

 */
CREATE TABLE borrow_request
(
    member_id INTEGER NOT NULL REFERENCES member (id),
    book_id   INTEGER NOT NULL REFERENCES book (id),
    approved  BOOLEAN,
    borrow    DATE    NOT NULL,
    due       DATE    NOT NULL DEFAULT CURRENT_DATE + INTERVAL '2 weeks',
    complete  DATE    NOT NULL,
    CONSTRAINT complete_date_check
        CHECK (CURRENT_DATE >= complete AND complete >= borrow)
);
ALTER TABLE borrow_request
    OWNER TO libms;

COMMENT ON TABLE borrow_request
    IS 'borrow requests from customers';
COMMENT ON COLUMN borrow_request.complete
    IS 'between borrow date and current date';
COMMENT ON COLUMN borrow_request.approved
    IS 'null means the request was not reviewed';
