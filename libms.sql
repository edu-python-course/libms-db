-- drop existing tables to avoid errors while re-creating them
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS borrow_request;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS revenue;
DROP TABLE IF EXISTS member;

-- label: ddl-publisher
CREATE TABLE publisher
(
    id      INTEGER PRIMARY KEY,
    name    VARCHAR(128) NOT NULL CHECK (LENGTH(name) > 0),
    email   VARCHAR(255),
    street  VARCHAR(255),
    city    VARCHAR(255),
    state   VARCHAR(255),
    postal  VARCHAR(16),
    website VARCHAR(255) UNIQUE,
    phone   VARCHAR(32) UNIQUE
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
    birthdate  DATE CHECK (birthdate < NOW() - INTERVAL '10 years'),
    CHECK ( LENGTH(first_name) > 0 ),
    CHECK ( LENGTH(last_name) > 0 )
);

COMMENT ON TABLE author IS 'authors registered in the library db';
COMMENT ON COLUMN author.first_name IS 'non-zero length author''s first name';
COMMENT ON COLUMN author.last_name IS 'non-zero length author''s last name';
COMMENT ON COLUMN author.birthdate IS 'at least 10 years old';

ALTER TABLE author
    OWNER TO libms;

-- label: ddl-book
CREATE TABLE book
(
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    synopsis         TEXT,
    isbn             VARCHAR(16),
    publisher_id     INTEGER      NOT NULL REFERENCES publisher,
    publication_date DATE,
    language         VARCHAR(64),
    page_count       INTEGER,
    keywords         TEXT
);

COMMENT ON TABLE book IS 'available books';
COMMENT ON COLUMN book.title IS 'non-zero length book''s title';
COMMENT ON COLUMN book.keywords IS 'whitespace separated keywords';

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

COMMENT ON TYPE book_genre IS 'registered book genres enumeration';

ALTER TABLE book
    ADD COLUMN genre book_genre;

ALTER TABLE book
    OWNER TO libms;

-- label: ddl-book_author
CREATE TABLE book_author
(
    book_id   INTEGER REFERENCES book,
    author_id INTEGER REFERENCES author
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
    id        SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES member,
    date      DATE    NOT NULL DEFAULT NOW(),
    amount    INTEGER NOT NULL CHECK (amount > 0),
    UNIQUE (member_id, date)
);

COMMENT ON TABLE revenue IS 'revenue (incomes)';
COMMENT ON COLUMN revenue.member_id IS 'unique together with date, member ref';
COMMENT ON COLUMN revenue.date IS 'unique together with member_id, revenue date';

ALTER TABLE revenue
    OWNER TO libms;

-- label: ddl-borrow_request
CREATE TABLE borrow_request
(
    book_id       INTEGER NOT NULL REFERENCES book,
    member_id     INTEGER NOT NULL REFERENCES member,
    borrow_date   DATE    NOT NULL DEFAULT NOW(),
    due_date      DATE    NOT NULL DEFAULT NOW() + INTERVAL '2 weeks',
    complete_date DATE,
    PRIMARY KEY (book_id, member_id, borrow_date)
);

COMMENT ON TABLE borrow_request IS 'book borrow requests';
COMMENT ON COLUMN borrow_request.book_id IS 'book reference, composite pk';
COMMENT ON COLUMN borrow_request.member_id IS 'member reference, composite pk';
COMMENT ON COLUMN borrow_request.borrow_date IS 'composite pk';

ALTER TABLE borrow_request
    ADD CONSTRAINT
        check_complete_date CHECK (complete_date >= borrow_date);

ALTER TABLE borrow_request
    OWNER TO libms;
