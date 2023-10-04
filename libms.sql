-- drop existing tables to avoid errors while re-creating them
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS borrow_request;
DROP TABLE IF EXISTS revenue;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS revenue;

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
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255)                 NOT NULL,
    synopsis         TEXT,
    isbn             VARCHAR(16),
    publisher_id     INTEGER REFERENCES publisher NOT NULL,
    publication_date DATE DEFAULT NOW(),
    language         VARCHAR(16),
    page_count       INTEGER,
    keywords         TEXT
);

COMMENT ON TABLE book IS 'available books';
COMMENT ON COLUMN book.title IS 'non-zero length book''s title';
COMMENT ON COLUMN book.keywords IS 'comma separated keywords';

ALTER TABLE book
    ADD CONSTRAINT check_title_length CHECK (LENGTH(title) > 0);

DROP TYPE IF EXISTS book_genre;
CREATE TYPE book_genre AS ENUM (
    'Adventure',
    'Biography',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Historical Fiction',
    'Horror',
    'Mystery',
    'Poetry',
    'Romance',
    'Science Fiction',
    'Self-Help',
    'Thriller',
    'Young Adult'
    );

ALTER TABLE book
    ADD COLUMN genre book_genre;

ALTER TABLE book
    OWNER TO libms;

-- label: ddl-book_author
CREATE TABLE book_author
(
    book_id   INTEGER REFERENCES book,
    author_id INTEGER REFERENCES author,
    UNIQUE (book_id, author_id)
);

COMMENT ON TABLE book_author IS 'books-to-authors relationship';
COMMENT ON COLUMN book_author.book_id IS 'unique together with author_id';
COMMENT ON COLUMN book_author.author_id IS 'unique together with book_id';

ALTER TABLE book_author
    OWNER TO libms;

-- label: ddl-member
CREATE TABLE member
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL CHECK (LENGTH(first_name) > 0),
    last_name  VARCHAR(64) NOT NULL CHECK (LENGTH(last_name) > 0),
    birthdate  DATE,
    registered DATE DEFAULT NOW(),
    email      VARCHAR(255),
    phone      VARCHAR(32)
);

COMMENT ON TABLE member IS 'library registered members';

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
