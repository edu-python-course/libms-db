-- noinspection SpellCheckingInspectionForFile
-- noinspection HttpUrlsUsageForFile

-- drop existing tables to avoid errors while re-creating them
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS borrow_request;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS revenue;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS contact;

-- label: ddl-publisher
CREATE TABLE publisher
(
    id      INTEGER PRIMARY KEY,
    name    VARCHAR(128) NOT NULL CHECK (LENGTH(name) > 0),
    website VARCHAR(255) UNIQUE,
    email   VARCHAR(255),
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

-- label: ddl-contact
CREATE TABLE contact
(
    id     SERIAL PRIMARY KEY,
    street VARCHAR(128) NOT NULL,
    postal VARCHAR(16)  NOT NULL,
    email  VARCHAR(255),
    phone  VARCHAR(32)
);

COMMENT ON TABLE contact IS 'members contacts';

ALTER TABLE contact
    OWNER TO libms;

-- label: ddl-member
CREATE TABLE member
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL CHECK (LENGTH(first_name) > 0),
    last_name  VARCHAR(64) NOT NULL CHECK (LENGTH(last_name) > 0),
    birthdate  DATE,
    registered DATE DEFAULT NOW(),
    contact_id INTEGER     NOT NULL UNIQUE REFERENCES contact
);

COMMENT ON TABLE member IS 'library registered members';
COMMENT ON COLUMN member.contact_id IS '1-to-1 relationship to contacts table';

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

-- label: dml-publisher
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (1, 'Zoonoodle', 'https://sfgate.com', 'bhaile0@blogtalkradio.com', '+55 (465) 224-8652');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (2, 'Brainlounge', 'http://php.net', 'bfindlow1@paginegialle.it', '+389 (482) 470-2463');
INSERT INTO publisher
VALUES (3, 'Tanoodle', 'http://dyndns.org', 'cfleisch2@scribd.com', '+7 (852) 867-5041');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (4, 'Skivee', 'https://google.co.uk', 'mwhyatt3@guardian.co.uk', '+86 (800) 978-5805');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (5, 'Yodel', 'https://oracle.com', 'iantonsen4@sitemeter.com', '+63 (914) 758-8375');
INSERT INTO publisher
VALUES (6, 'Realblab', 'https://google.ru', 'ccourage5@51.la', '+237 (970) 693-0352');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (7, 'Oozz', 'https://who.int', 'tpurser6@ebay.com', '+57 (962) 549-4249');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (8, 'Tazzy', 'https://histats.com', 'lveneur7@cnbc.com', '+30 (890) 683-2517');
INSERT INTO publisher
VALUES (9, 'Centizu', 'https://jalbum.net', 'sivic8@psu.edu', '+55 (797) 440-2972');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (10, 'Snaptags', 'http://amazonaws.com', 'sdemke9@squarespace.com', '+86 (350) 855-7198');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (11, 'Ozu', 'https://facebook.com', 'jgoodlipa@huffingtonpost.com', '+86 (403) 182-9940');
INSERT INTO publisher
VALUES (12, 'Yabox', 'https://last.fm', 'fleapb@princeton.edu', '+48 (663) 294-9203');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (13, 'Quinu', 'http://hostgator.com', 'crawetc@google.pl', '+57 (581) 268-9967');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (14, 'Vidoo', 'http://mtv.com', 'cmarad@biglobe.ne.jp', '+86 (215) 495-4455');
INSERT INTO publisher
VALUES (15, 'Twimm', 'http://mail.ru', 'bpethricke@amazon.co.jp', '+63 (463) 584-6914');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (16, 'Quaxo', 'http://comcast.net', 'rbaggarleyf@ezinearticles.com', '+86 (488) 765-0236');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (17, 'Gabcube', 'https://surveymonkey.com', 'trimmingtong@biglobe.ne.jp', '+86 (280) 939-2592');
INSERT INTO publisher
VALUES (18, 'Flipopia', 'http://dion.ne.jp', 'fmidsonh@cyberchimps.com', '+351 (187) 901-9626');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (19, 'Gigazoom', 'https://nasa.gov', 'gshilitoi@telegraph.co.uk', '+86 (943) 672-9935');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (20, 'Skiba', 'https://artisteer.com', 'cwinnisterj@google.ca', '+86 (484) 621-9312');
INSERT INTO publisher
VALUES (21, 'Twimm', 'http://webeden.co.uk', 'mshepherdsonk@dailymotion.com', '+33 (951) 159-6342');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (22, 'Kazu', 'https://dropbox.com', 'sgrowcockl@fda.gov', '+7 (121) 280-3696');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (23, 'Wordify', 'http://illinois.edu', 'agodbym@addthis.com', '+86 (129) 518-2464');
INSERT INTO publisher
VALUES (24, 'Mymm', 'http://howstuffworks.com', 'iweildishn@multiply.com', '+1 (605) 465-3850');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (25, 'Quinu', 'http://bbb.org', 'ehearnaho@timesonline.co.uk', '+46 (106) 273-3318');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (26, 'Shufflester', 'http://xrea.com', 'asortonp@liveinternet.ru', '+48 (584) 774-4181');
INSERT INTO publisher
VALUES (27, 'Rooxo', 'https://360.cn', 'brueggq@dedecms.com', '+86 (517) 418-4080');
INSERT INTO "publisher" ("id", "name", "website", "email", "phone")
VALUES (28, 'Skilith', 'http://aol.com', 'sswainstonr@eepurl.com', '+20 (339) 262-2182');
INSERT INTO publisher (id, name, website, email, phone)
VALUES (29, 'Twimm', 'https://wufoo.com', 'phaythornthwaites@bandcamp.com', '+86 (267) 914-8473');
INSERT INTO publisher
VALUES (30, 'Roodel', 'http://amazon.com', 'hkiliust@smh.com.au', '+216 (118) 215-3158');

-- label: dml-author
INSERT INTO author (first_name, last_name, country, birthdate)
VALUES ('Letta', 'Casbolt', 'Poland', '1947-04-18'),
       ('Robbyn', 'Attwoul', 'Poland', '1954-10-17'),
       ('Hesther', 'Kisby', 'Ukraine', '1941-07-21'),
       ('Gav', 'Jewett', 'Czech Republic', '1988-02-05'),
       ('Jorrie', 'Klehyn', 'United States', '1941-08-07'),
       ('Genevieve', 'Ollington', 'United States', '1921-08-27'),
       ('Carrissa', 'Arrandale', 'United Kingdom', '1982-08-20'),
       ('Josepha', 'Dominichelli', 'Poland', '1976-12-03'),
       ('Ario', 'Hepher', 'Ukraine', '2003-10-11'),
       ('Walker', 'Grolmann', 'Poland', '1964-02-17'),
       ('Bernhard', 'Domokos', 'Poland', '1905-05-17'),
       ('Monro', 'Shenfisch', 'Poland', '1902-10-11'),
       ('Daryl', 'Benettelli', 'United States', '1905-11-20'),
       ('Elysia', 'Scottrell', 'United States', '1994-03-31'),
       ('Tamma', 'Veazey', 'Czech Republic', '1968-10-06'),
       ('Meara', 'Keast', 'Poland', '1945-10-11'),
       ('Gipsy', 'Klawi', 'Poland', '1992-10-02'),
       ('Peyton', 'Alliston', 'Ukraine', '1928-09-19'),
       ('Harman', 'Learman', 'Ukraine', '1945-11-09'),
       ('Tessi', 'Geldeford', 'Poland', '1968-08-17'),
       ('Eugene', 'Dudson', 'United States', '1903-03-31'),
       ('Wendye', 'Rowbotham', 'Poland', '1932-12-16'),
       ('Grannie', 'Kidner', 'United States', '1940-02-21'),
       ('Godart', 'Van Driel', 'United Kingdom', '1980-01-02'),
       ('Meara', 'Meenehan', 'United States', '1994-12-13'),
       ('Nike', 'Pietruszka', 'Poland', '1978-11-25'),
       ('Karmen', 'Dowears', 'United States', '1944-06-02'),
       ('Nobie', 'Pringley', 'Ukraine', '2003-03-13'),
       ('Farrel', 'Jirsa', 'Netherlands', '1920-02-23'),
       ('Mile', 'Stooke', 'Czech Republic', '1970-03-05'),
       ('Ethelin', 'Blayney', 'United States', '1938-09-21'),
       ('Stefa', 'Cronk', 'Czech Republic', '1937-10-29'),
       ('Harris', 'Verring', 'Poland', '1944-12-13'),
       ('Tamarra', 'O''Lennane', 'United States', '1938-03-11'),
       ('Lauretta', 'Mardlin', 'United States', '1906-07-08'),
       ('Janith', 'Champney', 'Poland', '1938-08-06'),
       ('Beltran', 'Isakovitch', 'Poland', '1941-09-02'),
       ('Rowan', 'Whenman', 'United States', '1948-01-12'),
       ('Allyn', 'Snazle', 'Poland', '1909-07-22'),
       ('Brok', 'Juza', 'United States', '1991-04-23'),
       ('Tallulah', 'Boorn', 'Poland', '1918-06-27'),
       ('Janice', 'Minihan', 'Poland', '1984-07-07'),
       ('Chantal', 'Huckin', 'United States', '2002-03-27'),
       ('Alessandra', 'Ollie', 'Czech Republic', '1956-07-22'),
       ('Pace', 'Impy', 'United States', '1923-12-21'),
       ('Danette', 'Schwartz', 'Poland', '1957-06-19'),
       ('Bren', 'Broe', 'Germany', '1937-06-11'),
       ('Nevsa', 'Poytres', 'Poland', '1931-10-27'),
       ('Corette', 'Iffland', 'Netherlands', '1923-07-15'),
       ('Susanetta', 'Roan', 'Poland', '1940-07-25'),
       ('Gill', 'Iremonger', 'United States', '1957-07-14'),
       ('Carlene', 'Gemson', 'Poland', '1913-04-14'),
       ('Krishna', 'MacCague', 'Ukraine', '1940-08-05'),
       ('Cchaddie', 'Miliffe', 'United States', '1950-01-01'),
       ('Torrie', 'Picot', 'United States', '2004-04-24'),
       ('Ranique', 'Piatek', 'Poland', '1948-11-19'),
       ('Alessandra', 'Adger', 'Ukraine', '1997-04-07'),
       ('Nananne', 'Sebring', 'Czech Republic', '1910-03-08'),
       ('Demetre', 'Ducker', 'United States', '1980-05-14'),
       ('Candra', 'Kwietek', 'United States', '1928-07-12'),
       ('Gwendolen', 'Tibbotts', 'Poland', '1959-12-23'),
       ('Ardelle', 'Dessant', 'Netherlands', '1947-10-15'),
       ('Kimberlee', 'Seville', 'United Kingdom', '1956-02-25'),
       ('Christabella', 'McCloughlin', 'Poland', '1908-03-12'),
       ('Meryl', 'Please', 'Poland', '2003-06-13'),
       ('Rosana', 'Bolger', 'United States', '1906-09-29'),
       ('Nikaniki', 'Canas', 'United Kingdom', '1918-12-05'),
       ('Flynn', 'Grattan', 'United States', '1957-12-27'),
       ('Bancroft', 'Studdeard', 'Estonia', '1903-03-28'),
       ('Bondon', 'Copley', 'United States', '1990-08-07'),
       ('Sherlocke', 'Schultes', 'Estonia', '1963-04-03'),
       ('Rani', 'Barnshaw', 'Poland', '1999-10-31'),
       ('Gail', 'Ponde', 'United States', '1958-01-07'),
       ('Ynes', 'Pagden', 'United States', '1979-12-08'),
       ('Vernice', 'McRorie', 'Poland', '1955-07-30'),
       ('Adria', 'Maloney', 'Czech Republic', '1954-07-29'),
       ('Margery', 'Muris', 'Ukraine', '1975-08-22'),
       ('Hube', 'Eble', 'Ukraine', '1955-03-24'),
       ('Yolande', 'Scarman', 'Poland', '1934-10-04'),
       ('Virginia', 'Leel', 'United States', '1940-07-12'),
       ('Arther', 'Brunton', 'United States', '1997-10-25'),
       ('Lula', 'Kyneton', 'Ukraine', '1927-07-20'),
       ('Valli', 'Duchesne', 'United States', '1918-01-06'),
       ('Chandal', 'Ackrill', 'Poland', '1920-04-09'),
       ('Madelene', 'Ainslee', 'United States', '1951-06-19'),
       ('Steffi', 'Hulbert', 'United States', '1950-05-03'),
       ('Buiron', 'Veldman', 'Poland', '1969-10-27'),
       ('Carlen', 'Eate', 'Czech Republic', '1931-07-12'),
       ('Kerianne', 'Wernham', 'Poland', '1962-12-24'),
       ('Ulric', 'Cadwallader', 'Poland', '1900-10-12'),
       ('Birgitta', 'Whimper', 'Poland', '1984-07-01'),
       ('Cindra', 'Streak', 'United States', '1985-03-29'),
       ('Onofredo', 'McPhail', 'Netherlands', '1962-10-16'),
       ('Clyve', 'Boutton', 'Ukraine', '1966-02-02'),
       ('Noll', 'Aristide', 'Czech Republic', '1989-08-15'),
       ('Jasmine', 'Hallick', 'Netherlands', '1942-09-15'),
       ('Izaak', 'Pavek', 'Poland', '2003-11-21'),
       ('Janella', 'Lingard', 'Ukraine', '1920-07-15'),
       ('Nataniel', 'Shrimpling', 'Ukraine', '1977-06-26'),
       ('Felicio', 'Bilborough', 'Ukraine', '1961-04-10'),
       ('Arlen', 'Hatrey', 'Ukraine', '1981-06-14'),
       ('Skye', 'Boulter', 'Ukraine', '1993-05-29'),
       ('Kelley', 'Maunders', 'United States', '1943-02-23'),
       ('Demetria', 'Trowel', 'Ukraine', '1900-11-11'),
       ('Essa', 'Lloyds', 'United States', '1909-07-23'),
       ('Sheffie', 'Deerness', 'Poland', '1987-03-19'),
       ('Kissee', 'Book', 'Poland', '1907-10-03'),
       ('Sayers', 'Medendorp', 'Czech Republic', '1978-05-07'),
       ('Marie-ann', 'Niemiec', 'Netherlands', '1941-09-28'),
       ('Delcine', 'Everex', 'Czech Republic', '1902-05-10'),
       ('Gaby', 'Durant', 'Poland', '1901-10-22'),
       ('Cass', 'Heigl', 'Poland', '1924-06-05'),
       ('Nalani', 'Van Dale', 'United States', '1969-09-25'),
       ('Tedra', 'Cosley', 'Netherlands', '1983-03-30'),
       ('Myrtle', 'May', 'Czech Republic', '1966-03-07'),
       ('Mirella', 'Faustian', 'United States', '2004-10-14'),
       ('Ansell', 'McQuarter', 'Poland', '1946-08-12'),
       ('Cyb', 'Mercy', 'Estonia', '1978-10-30'),
       ('Kathi', 'Blaksley', 'Czech Republic', '1913-01-24'),
       ('Ellsworth', 'Ring', 'Poland', '1926-01-22'),
       ('Katheryn', 'Menendes', 'United States', '2004-08-23'),
       ('Bamby', 'Anderer', 'Poland', '1905-06-15'),
       ('Radcliffe', 'Buckler', 'Ukraine', '1998-06-29'),
       ('Red', 'Edmeads', 'Poland', '1956-06-22'),
       ('Rudd', 'Caudelier', 'United States', '1968-02-15'),
       ('Jesus', 'Ferreri', 'United States', '1908-02-22'),
       ('Darwin', 'Bigrigg', 'United States', '1998-10-11'),
       ('Teresa', 'Springall', 'United States', '1919-02-16'),
       ('Shannon', 'Wiley', 'Germany', '1925-07-13'),
       ('Larina', 'Storrie', 'Poland', '1937-11-09'),
       ('Giacopo', 'Nesey', 'United States', '1915-06-14'),
       ('Isador', 'Osment', 'Ukraine', '1924-02-24'),
       ('Hewitt', 'Fannin', 'Ukraine', '1940-11-08'),
       ('Sorcha', 'Mascall', 'Poland', '1964-01-20'),
       ('Aidan', 'Senner', 'Poland', '1959-03-26'),
       ('Pieter', 'Behne', 'Poland', '1921-04-11'),
       ('Rey', 'Smitham', 'Ukraine', '1933-04-25'),
       ('Lothaire', 'Harrower', 'Ukraine', '1997-06-30'),
       ('Roxanna', 'Izachik', 'Poland', '1948-12-09'),
       ('Dorthy', 'D''Oyly', 'Ukraine', '1961-02-21'),
       ('Rogers', 'Kacheler', 'Poland', '1980-10-04'),
       ('Gaspar', 'Bugdall', 'United States', '1951-02-14'),
       ('Homer', 'Stanmer', 'United States', '1920-06-24'),
       ('Edithe', 'Hamflett', 'United Kingdom', '1955-01-01'),
       ('Rollie', 'Reeken', 'Poland', '1949-11-17'),
       ('Dionisio', 'Nance', 'Ukraine', '1994-03-26'),
       ('Pierre', 'MacCaffrey', 'Czech Republic', '1915-05-02'),
       ('Lavinie', 'Jorgesen', 'Poland', '2002-01-22'),
       ('Dagny', 'Buckney', 'Czech Republic', '1918-03-26'),
       ('Montague', 'Duerden', 'Poland', '2003-11-09');

--label: dml-contact
INSERT INTO "contact" ("id", "street", "postal", "email", "phone")
VALUES (1, '715 Canary Center', '15191', NULL, NULL),
       (2, '25 Melby Way', '92564', 'pbartle1@com.com', NULL),
       (3, '0443 Lakewood Alley', '51517', 'scornejo2@tiny.cc', '+93 (545) 240-0237'),
       (4, '9 Chinook Park', '45637', NULL, '+86 (459) 616-7721'),
       (5, '9 Ridgeway Lane', '93582', 'mpain4@geocities.com', '+55 (643) 372-4868'),
       (6, '467 Gerald Street', '95776', NULL, '+86 (317) 789-9249'),
       (7, '55339 Ronald Regan Place', '03794', 'clyokhin6@smugmug.com', '+86 (508) 577-0882'),
       (8, '8986 Kensington Avenue', '18727', 'rscutter7@hugedomains.com', NULL),
       (9, '41 Mallard Terrace', '23386', 'mlightfoot8@answers.com', '+351 (294) 841-8217'),
       (10, '2419 Nobel Parkway', '26023', 'ksaintpierre9@biglobe.ne.jp', '+46 (967) 321-4393'),
       (11, '87144 Toban Crossing', '25990', 'adreossia@psu.edu', NULL),
       (12, '0 Washington Way', '39509', 'tgoterb@scientificamerican.com', NULL),
       (13, '91 Scott Place', '86943', NULL, NULL),
       (14, '8486 Corry Point', '83673', NULL, '+86 (292) 248-0100'),
       (15, '1374 Gina Street', '16756', 'fmanklowe@gov.uk', '+86 (441) 675-3035'),
       (16, '02 Kinsman Crossing', '13452', NULL, '+86 (314) 150-2092'),
       (17, '9634 Southridge Avenue', '64534', 'elissandreg@ow.ly', NULL),
       (18, '7 Moland Lane', '99833', 'jlathamh@g.co', '+81 (214) 517-5032'),
       (19, '8 Larry Hill', '07043', 'akeyseli@ft.com', '+351 (125) 364-4700'),
       (20, '04545 Harbort Point', '43474', NULL, '+48 (285) 799-8156'),
       (21, '516 Scott Way', '47026', 'ctrottonk@pagesperso-orange.fr', '+64 (503) 419-8214'),
       (22, '95367 Mayer Place', '09285', 'lnadinl@themeforest.net', '+48 (164) 197-9865'),
       (23, '089 Daystar Way', '07112', 'zbenfordm@e-recht24.de', NULL),
       (24, '011 Straubel Trail', '63148', 'kfidlern@wordpress.com', NULL),
       (25, '510 Hansons Trail', '40387', 'lshawleyo@exblog.jp', NULL),
       (26, '55 Corben Terrace', '66127', 'mcrownshawp@tripadvisor.com', '+994 (784) 871-8860'),
       (27, '90 Mcbride Court', '28202', 'lmiddlebrookq@irs.gov', NULL),
       (28, '3289 Farmco Hill', '92095', 'calenshevr@shutterfly.com', NULL),
       (29, '4817 Bashford Pass', '50742', 'nbaughams@gov.uk', '+64 (129) 553-7765'),
       (30, '111 Ruskin Trail', '23826', 'sbiagit@delicious.com', '+81 (755) 598-4136'),
       (31, '39 Knutson Plaza', '77594', 'jbettesonu@samsung.com', '+86 (936) 776-4913'),
       (32, '019 Stephen Alley', '27384', 'gknightv@dailymail.co.uk', '+57 (483) 227-7723'),
       (33, '8 Northwestern Terrace', '83358', 'ascotlandw@netlog.com', '+81 (124) 125-3997'),
       (34, '0874 Hallows Trail', '05678', 'jlakentonx@illinois.edu', '+62 (264) 175-0660'),
       (35, '02 Charing Cross Park', '20574', NULL, NULL),
       (36, '7607 Hovde Place', '88473', NULL, '+46 (814) 660-6339'),
       (37, '28825 Oak Point', '08216', NULL, NULL),
       (38, '5 Meadow Valley Court', '51982', 'dloiseau11@google.cn', '+7 (262) 802-0474'),
       (39, '03 David Plaza', '38215', 'mphizackerly12@zimbio.com', '+7 (187) 952-9905'),
       (40, '24273 Shopko Alley', '96050', 'mkemmet13@bandcamp.com', '+63 (478) 592-9486'),
       (41, '80 Maple Avenue', '35958', 'eallbon14@dagondesign.com', '+261 (455) 468-9408'),
       (42, '809 Drewry Avenue', '92357', 'jaindrais15@harvard.edu', '+63 (818) 912-7148'),
       (43, '38 David Alley', '33622', 'dbilverstone16@usgs.gov', '+54 (798) 158-3524'),
       (44, '85629 Coleman Road', '24810', 'jhoovart17@t.co', NULL),
       (45, '34616 Morrow Way', '98170', 'brheam18@blinklist.com', '+507 (341) 119-2722'),
       (46, '02 Daystar Alley', '12889', 'nskase19@hubpages.com', '+48 (365) 429-5418'),
       (47, '5233 Logan Plaza', '43235', 'jdennidge1a@multiply.com', '+62 (751) 575-4996'),
       (48, '04 Shoshone Alley', '50842', 'mjirasek1b@devhub.com', '+598 (511) 183-9939'),
       (49, '90195 Annamark Drive', '34798', 'bmarsland1c@timesonline.co.uk', '+62 (579) 307-9473'),
       (50, '8 Center Trail', '23836', 'sarangy1d@baidu.com', '+57 (655) 779-3033'),
       (51, '25 Pond Park', '26535', NULL, '+62 (791) 588-1980'),
       (52, '421 Trailsway Way', '38958', NULL, '+7 (290) 932-3488'),
       (53, '680 Fieldstone Pass', '29771', NULL, '+63 (708) 382-6185'),
       (54, '96 Cody Pass', '80879', 'chartfield1h@myspace.com', '+62 (243) 326-9840'),
       (55, '01127 Orin Court', '41218', 'rmatijevic1i@posterous.com', '+7 (864) 786-7205'),
       (56, '691 Pond Street', '91598', 'schazier1j@ehow.com', NULL),
       (57, '09 Mallory Center', '60448', 'seim1k@wsj.com', '+992 (421) 454-0387'),
       (58, '1 Novick Way', '31479', 'emaruszewski1l@wisc.edu', '+263 (869) 552-8639'),
       (59, '25 4th Circle', '09186', 'lsimeon1m@vinaora.com', '+81 (109) 805-7877'),
       (60, '8 Barnett Road', '35320', NULL, NULL),
       (61, '3 Orin Way', '68493', 'hspurdle1o@toplist.cz', '+691 (298) 482-8193'),
       (62, '70 Loeprich Drive', '76096', 'ghenzer1p@canalblog.com', '+86 (190) 556-7466'),
       (63, '1 North Avenue', '98295', 'vforster1q@xing.com', '+55 (369) 755-0342'),
       (64, '8 Farwell Avenue', '93833', 'sobispo1r@columbia.edu', '+86 (309) 549-5631'),
       (65, '3452 Namekagon Crossing', '43373', 'rleddy1s@reference.com', NULL),
       (66, '74965 Memorial Road', '74544', 'mnerheny1t@mozilla.com', '+7 (532) 258-4253'),
       (67, '0 Comanche Trail', '86306', 'kbernardoux1u@nature.com', '+216 (708) 826-1161'),
       (68, '13648 Dexter Hill', '13384', 'lrainforth1v@biglobe.ne.jp', '+86 (525) 584-0852'),
       (69, '7885 Menomonie Point', '16460', 'zcatteroll1w@gizmodo.com', NULL),
       (70, '51 Ridge Oak Circle', '30644', 'nmerredy1x@nsw.gov.au', NULL),
       (71, '4 Charing Cross Trail', '76590', 'mmeagh1y@ow.ly', '+255 (802) 619-6092'),
       (72, '4947 Steensland Street', '36474', NULL, '+55 (459) 527-0523'),
       (73, '6771 Columbus Place', '78051', 'klunney20@taobao.com', '+7 (273) 258-1881'),
       (74, '5 Homewood Terrace', '62165', NULL, '+970 (853) 375-1018'),
       (75, '16958 Jackson Junction', '18984', 'mcotesford22@archive.org', NULL),
       (76, '1471 Scofield Drive', '65764', 'cferrarotti23@photobucket.com', '+1 (406) 426-5188'),
       (77, '92 Rockefeller Point', '49511', 'kstannislawski24@indiatimes.com', NULL),
       (78, '972 Onsgard Lane', '73551', 'gwhate25@webeden.co.uk', NULL),
       (79, '0563 Shoshone Court', '92495', 'caudas26@bloomberg.com', '+389 (969) 109-2291'),
       (80, '97 Continental Hill', '67032', NULL, '+84 (146) 288-9090'),
       (81, '0 Starling Pass', '16180', 'ddefraine28@nyu.edu', '+7 (651) 867-1386'),
       (82, '47 Towne Place', '37731', 'esmeeth29@google.co.uk', NULL),
       (83, '22 New Castle Parkway', '95881', 'hgrunguer2a@canalblog.com', NULL),
       (84, '8317 Sullivan Junction', '44764', NULL, '+962 (146) 512-9588'),
       (85, '6609 Muir Road', '94413', 'efothergill2c@sbwire.com', '+353 (787) 705-6617'),
       (86, '4 Truax Center', '66001', 'jfeely2d@amazon.co.jp', '+52 (948) 376-9690'),
       (87, '9 Milwaukee Parkway', '92704', 'lilem2e@theglobeandmail.com', '+880 (505) 770-0581'),
       (88, '23 Delaware Road', '96731', 'awicklen2f@illinois.edu', '+86 (204) 705-9360'),
       (89, '3404 Hoepker Point', '01705', 'hkernes2g@exblog.jp', '+967 (373) 350-0665'),
       (90, '1221 Morningstar Park', '46551', 'sreddle2h@meetup.com', '+54 (910) 860-0899'),
       (91, '436 Buell Lane', '93158', 'eredfearn2i@bloglines.com', NULL),
       (92, '3621 Barby Court', '73965', 'mbraksper2j@harvard.edu', '+7 (316) 823-7909'),
       (93, '927 Steensland Junction', '30653', 'rteodori2k@creativecommons.org', '+86 (771) 489-6671'),
       (94, '32 Red Cloud Road', '74262', NULL, '+62 (949) 300-9748'),
       (95, '883 Oneill Court', '94805', NULL, '+63 (533) 327-2339'),
       (96, '342 Upham Way', '98940', 'hturbitt2n@slate.com', '+226 (236) 284-6433'),
       (97, '387 Caliangt Road', '37917', 'rdumbleton2o@mashable.com', NULL),
       (98, '3484 Porter Street', '81173', 'lstorah2p@csmonitor.com', '+62 (540) 321-0305'),
       (99, '97180 Homewood Alley', '91618', NULL, '+81 (942) 350-1693'),
       (100, '7 Jenifer Terrace', '80831', 'gelgram2r@intel.com', '+48 (649) 658-5412'),
       (101, '960 Northfield Alley', '00242', NULL, '+86 (767) 502-3327'),
       (102, '73523 Village Way', '35335', NULL, NULL),
       (103, '90516 Katie Drive', '81710', 'etrouncer2u@shutterfly.com', NULL),
       (104, '740 Brentwood Road', '91830', 'zcranch2v@people.com.cn', '+55 (795) 984-3289'),
       (105, '5 Lakeland Junction', '93457', 'battwater2w@craigslist.org', '+86 (667) 164-0903'),
       (106, '255 Warbler Pass', '71253', 'gskyppe2x@deliciousdays.com', '+1 (719) 962-8286'),
       (107, '78 Vera Terrace', '46799', NULL, '+62 (539) 257-1254'),
       (108, '0 Ridgeview Parkway', '27798', 'erodda2z@howstuffworks.com', NULL),
       (109, '7358 Golf Point', '69498', 'cdesseine30@barnesandnoble.com', '+48 (830) 599-9433'),
       (110, '0 Mifflin Parkway', '34366', NULL, NULL),
       (111, '9557 American Ash Avenue', '64517', 'rgordongiles32@nsw.gov.au', NULL),
       (112, '05911 David Trail', '48723', 'odickin33@devhub.com', '+55 (427) 225-7245'),
       (113, '06 Arizona Pass', '80753', 'cmedling34@flavors.me', NULL),
       (114, '29647 Moulton Center', '15525', 'etilly35@howstuffworks.com', '+86 (226) 890-9635'),
       (115, '90162 Sunfield Trail', '63442', 'dchitty36@netvibes.com', NULL),
       (116, '68600 Westport Parkway', '17235', 'xdark37@hhs.gov', NULL),
       (117, '1940 Sunfield Point', '32645', 'ascimone38@ebay.com', NULL),
       (118, '96799 Straubel Avenue', '03304', 'yclempton39@sina.com.cn', '+420 (242) 995-1586'),
       (119, '08 Farragut Court', '63314', 'ctindley3a@alexa.com', '+62 (996) 201-0309'),
       (120, '03 Eastwood Point', '41039', 'pmacgiany3b@blog.com', '+66 (212) 176-6189'),
       (121, '75559 Loeprich Road', '69968', 'vbeazleigh3c@acquirethisname.com', '+212 (892) 853-1179'),
       (122, '9 School Circle', '82786', NULL, '+86 (967) 537-0563'),
       (123, '1 Utah Alley', '43892', 'pmoreno3e@telegraph.co.uk', '+55 (288) 649-8191'),
       (124, '896 Mosinee Terrace', '30828', 'mmcallester3f@gov.uk', '+86 (880) 616-0873'),
       (125, '17 Helena Parkway', '51326', NULL, NULL),
       (126, '03 Mifflin Crossing', '10026', 'cscurfield3h@cargocollective.com', '+62 (652) 675-7056'),
       (127, '832 Trailsway Street', '50406', 'egregor3i@hp.com', NULL),
       (128, '34096 Lerdahl Point', '05347', 'mpettiford3j@vk.com', NULL),
       (129, '1 Anniversary Trail', '46548', 'ljosiah3k@ca.gov', '+55 (890) 211-4476'),
       (130, '782 Emmet Street', '04309', NULL, '+48 (549) 859-6609'),
       (131, '8773 Jackson Place', '30535', NULL, '+63 (169) 718-4955'),
       (132, '64220 Dawn Circle', '01909', 'bharder3n@com.com', '+86 (338) 221-6337'),
       (133, '0080 Holy Cross Hill', '04348', 'jclew3o@slideshare.net', '+7 (160) 842-5646'),
       (134, '980 Kenwood Court', '44236', NULL, '+86 (154) 284-5977'),
       (135, '83476 Raven Way', '42301', 'mchuney3q@va.gov', '+1 (571) 449-4028'),
       (136, '40 Kinsman Circle', '99580', 'wmcclurg3r@mysql.com', '+55 (418) 775-5177'),
       (137, '55940 Service Court', '31652', 'jgalle3s@apple.com', '+86 (531) 591-1638'),
       (138, '052 Lakewood Circle', '94087', 'aleyrroyd3t@hibu.com', '+55 (987) 142-1133'),
       (139, '743 Briar Crest Junction', '16605', 'chryncewicz3u@domainmarket.com', '+994 (229) 950-7092'),
       (140, '0 Algoma Circle', '38854', 'rnel3v@ocn.ne.jp', '+81 (877) 306-2671'),
       (141, '5774 Summer Ridge Avenue', '25831', NULL, NULL),
       (142, '37 Armistice Road', '41555', 'wlukesch3x@feedburner.com', NULL),
       (143, '0 Hovde Hill', '88187', NULL, NULL),
       (144, '54 Mallory Hill', '24851', NULL, '+86 (912) 959-1698'),
       (145, '720 Hudson Center', '39321', 'icacacie40@craigslist.org', NULL),
       (146, '1 Moulton Court', '13157', 'rjunkison41@pen.io', '+62 (478) 567-3806'),
       (147, '98132 Dayton Road', '57647', 'tradloff42@biglobe.ne.jp', '+62 (416) 432-5280'),
       (148, '4429 Jenna Place', '64946', 'wluckham43@github.io', '+58 (734) 443-8324'),
       (149, '2455 Helena Road', '05913', 'gseawell44@youku.com', '+63 (519) 909-6087'),
       (150, '26682 Beilfuss Crossing', '57834', 'opether45@posterous.com', NULL),
       (151, '90643 Knutson Place', '76093', 'nbelmont46@lulu.com', '+58 (515) 626-5559'),
       (152, '449 Village Plaza', '10067', 'jdawidowitz47@drupal.org', NULL),
       (153, '781 Sutteridge Circle', '87791', 'wblakebrough48@wordpress.com', '+86 (307) 853-6495'),
       (154, '1 Chinook Avenue', '17162', 'mosment49@google.co.uk', '+62 (786) 210-1657'),
       (155, '9 Melrose Park', '29831', 'avowles4a@reddit.com', '+7 (995) 441-6675'),
       (156, '4 Vera Street', '67199', 'nfirk4b@spiegel.de', '+501 (929) 206-1899'),
       (157, '74 Atwood Pass', '50224', NULL, '+86 (805) 281-7118'),
       (158, '78 Di Loreto Center', '77173', 'rduggary4d@twitpic.com', '+62 (325) 704-4326'),
       (159, '9266 1st Court', '85630', 'mfort4e@pagesperso-orange.fr', '+507 (946) 653-6277'),
       (160, '46 Vera Place', '32028', 'lfairham4f@booking.com', '+93 (563) 371-1941'),
       (161, '85 Del Mar Trail', '61645', 'lchristene4g@cmu.edu', '+7 (493) 411-6234'),
       (162, '4 Crescent Oaks Avenue', '49592', NULL, '+7 (830) 409-8815'),
       (163, '65 Green Way', '68225', NULL, '+7 (244) 253-3227'),
       (164, '61715 Russell Avenue', '58482', 'mhamlet4j@adobe.com', '+86 (395) 561-2283'),
       (165, '87 Lukken Alley', '57841', NULL, NULL),
       (166, '4203 Pennsylvania Lane', '68271', 'ddonn4l@irs.gov', '+86 (153) 316-6020'),
       (167, '5 Arapahoe Trail', '40843', 'rchipman4m@flickr.com', NULL),
       (168, '31455 Goodland Circle', '94926', 'gboys4n@yale.edu', '+7 (851) 538-0995'),
       (169, '8 Service Trail', '32267', NULL, '+62 (593) 344-8118'),
       (170, '731 Redwing Court', '62940', 'hchander4p@ca.gov', '+51 (250) 429-5491'),
       (171, '714 Dawn Junction', '37569', NULL, NULL),
       (172, '1209 Dahle Court', '22593', 'awoof4r@usgs.gov', NULL),
       (173, '5 Mesta Circle', '33172', NULL, NULL),
       (174, '0 International Center', '98453', 'sbayns4t@seattletimes.com', '+44 (555) 856-3020'),
       (175, '02 Columbus Crossing', '86158', 'erosbotham4u@usa.gov', '+86 (923) 392-3943'),
       (176, '3 Red Cloud Court', '90167', NULL, NULL),
       (177, '0 Quincy Circle', '10503', NULL, '+880 (914) 871-7114'),
       (178, '16 Cherokee Plaza', '62317', 'tkilfeder4x@studiopress.com', NULL),
       (179, '5 Springs Point', '01496', 'cpowles4y@furl.net', NULL),
       (180, '92322 Nobel Terrace', '01317', 'hphilipet4z@toplist.cz', '+381 (131) 156-5862'),
       (181, '711 Heath Road', '51810', 'jbrannon50@apple.com', '+52 (674) 105-9185'),
       (182, '35 Morrow Plaza', '88543', NULL, '+1 (213) 950-7875'),
       (183, '34144 Vera Alley', '30813', 'rburdon52@apple.com', '+48 (461) 293-9855'),
       (184, '33432 Twin Pines Parkway', '59073', 'ssorrie53@unesco.org', '+223 (634) 922-5947'),
       (185, '46 Farmco Lane', '21779', 'hbousquet54@apple.com', NULL),
       (186, '16 Hauk Alley', '25210', 'gwragge55@angelfire.com', NULL),
       (187, '73538 Old Shore Hill', '29144', 'keyckel56@weibo.com', '+7 (295) 812-0268'),
       (188, '000 David Center', '18475', 'lwalas57@ucoz.ru', '+62 (741) 656-8811'),
       (189, '07 Dixon Hill', '47790', 'gbroadbear58@1688.com', '+86 (130) 147-5968'),
       (190, '3615 Westend Way', '67601', NULL, '+47 (582) 617-5181'),
       (191, '73 Sundown Pass', '85951', 'adupree5a@businesswire.com', '+84 (277) 416-8349'),
       (192, '11 Dahle Terrace', '55058', NULL, '+34 (599) 327-5883'),
       (193, '05 Transport Street', '82370', 'wkillimister5c@a8.net', '+7 (937) 909-6299'),
       (194, '3 Pennsylvania Lane', '50681', 'mloiterton5d@army.mil', '+81 (642) 888-7384'),
       (195, '5 Reinke Road', '74754', 'vmayston5e@nsw.gov.au', '+1 (215) 349-3394'),
       (196, '1 Debra Trail', '88031', NULL, NULL),
       (197, '0 Kenwood Crossing', '97441', NULL, '+51 (788) 675-6590'),
       (198, '053 Thackeray Alley', '86792', NULL, NULL),
       (199, '4 Lighthouse Bay Crossing', '20196', 'ngrowy5i@diigo.com', '+351 (923) 485-2836'),
       (200, '029 Muir Circle', '80197', 'dmoquin5j@apache.org', '+94 (885) 453-4607'),
       (201, '170 Mendota Court', '43194', NULL, '+234 (400) 823-9464'),
       (202, '66292 Red Cloud Terrace', '92158', 'hreinbach5l@redcross.org', '+55 (408) 159-5545'),
       (203, '30 Almo Place', '01987', 'cdrover5m@51.la', '+86 (633) 974-8936'),
       (204, '698 Oneill Circle', '20415', 'tstanbrooke5n@si.edu', '+7 (568) 132-2355'),
       (205, '6166 Basil Road', '92637', 'ilademann5o@cafepress.com', '+86 (812) 757-2576'),
       (206, '71945 Anhalt Hill', '18380', 'aspeer5p@reddit.com', '+7 (896) 393-1550'),
       (207, '9 Killdeer Pass', '06501', 'meagles5q@sphinn.com', '+86 (166) 821-8687'),
       (208, '394 Oak Valley Court', '77588', 'ooak5r@state.tx.us', NULL),
       (209, '5699 Truax Street', '36139', 'kmacon5s@mashable.com', '+54 (358) 821-3576'),
       (210, '73 Talmadge Center', '77440', 'cfabler5t@addtoany.com', '+33 (903) 794-6234'),
       (211, '6 Arizona Center', '33519', 'dsamwayes5u@usgs.gov', '+48 (376) 953-0449'),
       (212, '31534 Union Park', '85826', NULL, '+86 (623) 633-0409'),
       (213, '91435 Talisman Lane', '68608', NULL, NULL),
       (214, '09004 Carberry Street', '57816', NULL, NULL),
       (215, '48936 Florence Street', '83304', 'rmccorry5y@webnode.com', '+48 (203) 934-8119'),
       (216, '937 Basil Lane', '50565', 'pashbee5z@princeton.edu', NULL),
       (217, '636 Mccormick Terrace', '23191', 'bdicky60@cdbaby.com', NULL),
       (218, '48 Vera Circle', '77500', 'rforesight61@shareasale.com', '+49 (201) 253-2694'),
       (219, '6004 American Court', '93152', 'jgantzer62@lulu.com', '+503 (787) 419-6857'),
       (220, '1806 Bultman Point', '40292', 'aramelet63@yolasite.com', NULL),
       (221, '213 Esker Alley', '16908', 'abrimblecombe64@dropbox.com', '+63 (528) 616-3270'),
       (222, '89 Moulton Parkway', '43325', NULL, '+7 (335) 427-1569'),
       (223, '95 3rd Avenue', '52139', 'harchbold66@google.fr', '+357 (215) 234-8730'),
       (224, '49272 Weeping Birch Crossing', '66635', 'kodennehy67@drupal.org', '+7 (867) 436-1337'),
       (225, '760 Oneill Park', '08415', NULL, NULL),
       (226, '096 Almo Hill', '60587', 'jcastagno69@webnode.com', NULL),
       (227, '9 Rusk Pass', '27711', NULL, NULL),
       (228, '844 Dwight Court', '92893', 'tstell6b@oakley.com', '+46 (190) 753-6601'),
       (229, '22992 Reindahl Plaza', '79209', NULL, '+57 (305) 649-4506'),
       (230, '058 Washington Terrace', '97645', 'mbusen6d@imgur.com', '+63 (234) 947-3006'),
       (231, '507 Union Park', '20461', 'hovenden6e@whitehouse.gov', '+63 (334) 239-8082'),
       (232, '8 Lighthouse Bay Parkway', '58035', 'fmargrie6f@amazon.de', '+7 (632) 259-2522'),
       (233, '7 Miller Avenue', '78893', NULL, '+351 (504) 703-8575'),
       (234, '0 Grim Pass', '05545', NULL, NULL),
       (235, '26 Springview Place', '07141', 'alofty6i@eventbrite.com', '+232 (210) 299-9773'),
       (236, '1 Michigan Trail', '75219', 'joneary6j@shinystat.com', '+63 (234) 195-9044'),
       (237, '3018 Clyde Gallagher Hill', '23749', 'ldanzelman6k@rambler.ru', '+359 (530) 889-3323'),
       (238, '38316 Barby Place', '79413', 'gmcgrady6l@studiopress.com', NULL),
       (239, '0 4th Parkway', '21154', 'dallgood6m@japanpost.jp', NULL),
       (240, '81504 Hudson Place', '52102', 'vknewstubb6n@webnode.com', NULL),
       (241, '31098 Arapahoe Parkway', '10419', NULL, '+62 (746) 769-9387'),
       (242, '5952 Rutledge Avenue', '35295', 'mshevell6p@time.com', NULL),
       (243, '4288 Crescent Oaks Circle', '82277', 'bdiable6q@prnewswire.com', '+46 (927) 269-3894'),
       (244, '55388 Cordelia Pass', '39649', NULL, '+356 (842) 689-6866'),
       (245, '2 Rusk Crossing', '38274', NULL, '+86 (977) 261-1017'),
       (246, '605 Golf View Court', '74914', NULL, '+33 (414) 504-9649'),
       (247, '7853 Messerschmidt Center', '38851', 'bvanderweedenburg6u@house.gov', '+7 (996) 459-8813'),
       (248, '641 Butternut Avenue', '37862', NULL, '+977 (332) 729-6510'),
       (249, '7 Briar Crest Plaza', '50677', NULL, '+62 (808) 335-7061'),
       (250, '1980 Rutledge Pass', '52282', 'mwynter6x@ameblo.jp', '+86 (452) 540-3023'),
       (251, '5481 Norway Maple Road', '37822', 'veyer6y@spotify.com', '+62 (732) 512-3460'),
       (252, '55941 Raven Place', '21225', 'mthistleton6z@angelfire.com', '+358 (481) 958-4133'),
       (253, '5 Hermina Terrace', '76192', NULL, '+992 (876) 118-0914'),
       (254, '97042 American Ash Way', '94178', 'ogoodricke71@digg.com', '+7 (354) 174-0307'),
       (255, '3152 Lakeland Court', '63213', 'lgoodreid72@aboutads.info', NULL),
       (256, '17 Lawn Road', '82921', NULL, '+86 (743) 913-0014'),
       (257, '63610 Evergreen Crossing', '27233', 'cgrishin74@amazon.de', '+234 (832) 752-6424'),
       (258, '12 Scott Road', '33631', 'efloch75@unc.edu', NULL),
       (259, '34 Cody Circle', '56726', 'mold76@friendfeed.com', '+63 (406) 858-3988'),
       (260, '331 Eastwood Alley', '78593', NULL, NULL),
       (261, '12545 Lakewood Gardens Pass', '50379', 'lhoyte78@samsung.com', '+62 (502) 774-8426'),
       (262, '7 Eagle Crest Drive', '93060', 'pdevon79@twitter.com', '+502 (344) 928-5509'),
       (263, '8 Jenifer Plaza', '17927', NULL, '+57 (933) 253-5961'),
       (264, '554 Mcguire Circle', '13849', 'dferrick7b@phoca.cz', '+7 (573) 190-8791'),
       (265, '675 Butternut Place', '35335', 'bbauld7c@loc.gov', '+86 (543) 441-4298'),
       (266, '48 Ludington Drive', '81049', 'wmatussevich7d@hexun.com', '+351 (740) 365-5953'),
       (267, '097 Union Avenue', '19781', 'kcaudwell7e@fotki.com', '+54 (318) 714-2703'),
       (268, '1038 Shelley Parkway', '56144', 'eclemendet7f@tinypic.com', '+30 (653) 944-7126'),
       (269, '9 Ludington Circle', '08478', 'gturl7g@networksolutions.com', NULL),
       (270, '577 Artisan Parkway', '18631', 'elozano7h@ustream.tv', '+86 (323) 126-7555'),
       (271, '9 Walton Hill', '31746', 'kwoliter7i@unblog.fr', '+55 (580) 441-4413'),
       (272, '7269 Vahlen Park', '61398', 'hearl7j@wsj.com', '+86 (283) 621-0760'),
       (273, '9130 Charing Cross Drive', '84784', 'wthorlby7k@google.cn', '+357 (700) 431-7608'),
       (274, '47 Magdeline Street', '09952', 'descale7l@npr.org', '+7 (533) 686-2924'),
       (275, '532 Elgar Drive', '63364', 'nowbrick7m@intel.com', '+1 (206) 103-7890'),
       (276, '1303 Sachs Parkway', '46070', 'amcinally7n@blinklist.com', '+63 (561) 891-3833'),
       (277, '49 Cherokee Place', '65189', 'csowden7o@uiuc.edu', '+86 (303) 588-9142'),
       (278, '0903 Nevada Drive', '68460', 'dlaban7p@si.edu', NULL),
       (279, '3 Mcbride Alley', '84351', 'gdrysdale7q@ocn.ne.jp', '+52 (358) 989-1808'),
       (280, '994 Mandrake Terrace', '83740', 'gchiswell7r@pcworld.com', '+62 (372) 423-0073'),
       (281, '298 Oneill Avenue', '56182', NULL, '+62 (234) 557-2302'),
       (282, '12585 Banding Point', '48693', 'bhollingsby7t@tripod.com', NULL),
       (283, '5051 Charing Cross Crossing', '73597', 'ahaddinton7u@nih.gov', '+86 (531) 281-5493'),
       (284, '069 Hudson Avenue', '97253', NULL, '+371 (707) 911-5757'),
       (285, '83934 Clarendon Plaza', '07636', 'slane7w@smugmug.com', '+31 (886) 466-7076'),
       (286, '26856 Clemons Plaza', '50887', NULL, '+371 (127) 225-6469'),
       (287, '1575 Roxbury Lane', '58366', NULL, '+86 (477) 989-8069'),
       (288, '57753 Pawling Park', '78487', 'dmaffia7z@china.com.cn', '+231 (502) 603-5710'),
       (289, '360 Dryden Park', '64475', 'joscanlon80@1688.com', NULL),
       (290, '9 Springs Hill', '84271', NULL, '+1 (704) 223-4493'),
       (291, '9309 Bartillon Road', '08705', 'mstickland82@domainmarket.com', '+86 (993) 484-6358'),
       (292, '25718 Vera Parkway', '33908', 'icartmer83@sciencedaily.com', '+48 (267) 545-2151'),
       (293, '13619 Roxbury Junction', '84023', NULL, '+48 (285) 763-5630'),
       (294, '719 Utah Center', '60969', 'ebarstow85@twitpic.com', '+62 (473) 860-5185'),
       (295, '75546 Algoma Lane', '28738', 'gmuncie86@prnewswire.com', '+33 (820) 723-6524'),
       (296, '97180 Badeau Center', '89826', 'nduligal87@reverbnation.com', NULL),
       (297, '429 Magdeline Lane', '65887', 'cmcindrew88@cornell.edu', NULL),
       (298, '6 Loftsgordon Plaza', '19456', 'mcrimp89@statcounter.com', '+86 (379) 293-9491'),
       (299, '093 Hazelcrest Crossing', '87911', 'abaltrushaitis8a@wikipedia.org', '+221 (389) 802-5696'),
       (300, '42 Thompson Trail', '58658', 'gshurmer8b@google.com.hk', NULL),
       (301, '47683 Farwell Circle', '50256', 'mbenkhe8c@hexun.com', NULL),
       (302, '3762 Briar Crest Hill', '87953', NULL, '+98 (287) 385-6549'),
       (303, '1476 Bobwhite Court', '19489', 'mstallibrass8e@geocities.com', '+382 (467) 944-8639'),
       (304, '347 Lerdahl Point', '63766', 'iceles8f@dedecms.com', '+420 (456) 340-8868'),
       (305, '08087 Oak Valley Road', '17102', 'mchaudron8g@soup.io', '+7 (785) 842-7696'),
       (306, '526 Fairfield Court', '23712', 'mtreleven8h@bing.com', '+86 (458) 979-3593'),
       (307, '2 Esker Way', '43820', 'nyakovlev8i@msn.com', '+62 (739) 569-4477'),
       (308, '1014 Bayside Terrace', '10870', NULL, '+86 (112) 906-7576'),
       (309, '34836 Harper Way', '46037', NULL, NULL),
       (310, '0 Kipling Hill', '96276', NULL, '+63 (433) 600-1901'),
       (311, '17 Towne Junction', '29613', 'byuryaev8m@nbcnews.com', '+420 (476) 717-0609'),
       (312, '35336 Basil Drive', '45993', NULL, '+33 (865) 736-0183'),
       (313, '775 Mallard Junction', '79989', 'csapena8o@washington.edu', '+46 (519) 853-9853'),
       (314, '1869 Macpherson Drive', '93462', NULL, '+57 (835) 387-4165'),
       (315, '4 Sunbrook Parkway', '50717', 'nbirkenhead8q@ehow.com', '+54 (828) 950-4427'),
       (316, '9775 Morningstar Parkway', '28534', 'schoppin8r@1688.com', '+351 (905) 628-8622'),
       (317, '762 Maple Trail', '43763', NULL, '+63 (765) 814-6317'),
       (318, '33 Summit Road', '19269', NULL, '+86 (197) 197-2415'),
       (319, '542 Carpenter Way', '19072', 'gmattisson8u@discovery.com', '+62 (271) 170-0254'),
       (320, '439 South Lane', '33250', 'dhillhouse8v@bloomberg.com', '+55 (930) 352-2807'),
       (321, '7 Logan Avenue', '60663', 'lcuming8w@canalblog.com', '+86 (936) 578-1331'),
       (322, '26 Artisan Point', '54885', 'gwigfield8x@dion.ne.jp', '+63 (715) 414-4202'),
       (323, '739 Utah Terrace', '41616', 'lsleet8y@wsj.com', '+55 (175) 803-9684'),
       (324, '89 Burrows Road', '57972', 'hquye8z@ehow.com', NULL),
       (325, '43 Bunting Drive', '50007', NULL, '+420 (982) 415-2872'),
       (326, '391 Truax Crossing', '16967', 'dleaves91@ebay.com', '+55 (114) 190-9823'),
       (327, '27448 Basil Pass', '36182', NULL, '+62 (743) 501-9943'),
       (328, '804 David Trail', '04506', 'acorner93@bluehost.com', '+86 (906) 342-7566'),
       (329, '56 Sachs Point', '17875', 'dsimoens94@va.gov', '+420 (830) 501-3072'),
       (330, '6 Banding Hill', '07187', 'mdrakers95@usnews.com', '+62 (328) 413-4527'),
       (331, '58379 Hanover Drive', '85736', 'ajann96@sphinn.com', '+351 (970) 673-9314'),
       (332, '85576 Dahle Hill', '42312', 'psibyllina97@themeforest.net', '+420 (268) 197-6047'),
       (333, '249 Pond Way', '38807', NULL, '+48 (492) 462-1284'),
       (334, '4033 Larry Way', '89933', NULL, '+62 (342) 953-9166'),
       (335, '06 Eastwood Lane', '94938', 'svannikov9a@craigslist.org', '+380 (497) 962-3554'),
       (336, '788 Goodland Hill', '74982', 'pmarcum9b@sohu.com', '+7 (203) 414-2153'),
       (337, '1 Homewood Crossing', '81574', 'cheino9c@hibu.com', NULL),
       (338, '08848 Heffernan Court', '68355', NULL, '+33 (315) 768-8652'),
       (339, '0682 Burrows Point', '58962', 'wfedoronko9e@digg.com', NULL),
       (340, '724 Pankratz Pass', '62427', 'lboost9f@sourceforge.net', NULL),
       (341, '6 Kinsman Drive', '67901', 'lscollick9g@army.mil', '+225 (755) 770-0030'),
       (342, '3 Summerview Circle', '58879', 'lcramphorn9h@intel.com', NULL),
       (343, '1308 Rowland Court', '69613', NULL, '+55 (346) 864-0531'),
       (344, '356 Eliot Trail', '76753', 'bbtham9j@nature.com', '+81 (173) 651-7047'),
       (345, '83413 Dixon Circle', '43768', 'smattys9k@w3.org', NULL);
-- update id sequence value
SELECT SETVAL('contact_id_seq', (SELECT MAX(id) FROM contact));

-- label: dml-member
-- require superuser access or `pg_read_server_files` role priveleges
COPY member FROM '/var/lib/postgresql/assets/member.csv' CSV HEADER;
-- update id sequence value
SELECT SETVAL('member_id_seq', (SELECT MAX(id) FROM member));

-- label: dml-book
-- require superuser access or `pg_read_server_files` role priveleges
COPY book (id, title, synopsis, isbn, publisher_id, publication_date, genre, language, page_count,
           keywords) FROM '/var/lib/postgresql/assets/book.csv' DELIMITER ',' CSV HEADER;
-- update id sequence value
SELECT SETVAL('book_id_seq', (SELECT MAX(id) FROM book));

-- label: dml-book_author
-- require superuser access or `pg_read_server_files` role priveleges
COPY book_author FROM '/var/lib/postgresql/assets/book_author.csv' DELIMITER ',' CSV;

-- label: dml-revenue
-- require superuser access or `pg_read_server_files` role priveleges
COPY revenue FROM '/var/lib/postgresql/assets/revenue.csv' DELIMITER ',' CSV HEADER;
-- update id sequence value
SELECT SETVAL('revenue_id_seq', (SELECT MAX(id) FROM revenue));

-- label: dml-borrow_request
-- require superuser access or `pg_read_server_files` role priveleges
COPY borrow_request FROM '/var/lib/postgresql/assets/borrow_request.csv' DELIMITER ',' CSV HEADER;

-- label: clean-up-book_author
-- temporary tables are dropped at the end of the session (when it is closed)
DROP TABLE IF EXISTS book_author_distinct;
CREATE TEMPORARY TABLE book_author_distinct AS
SELECT DISTINCT book_id, author_id
FROM book_author;

TRUNCATE TABLE book_author; -- remove all rows from the "book_author" table
ALTER TABLE book_author
    ADD CONSTRAINT book_author_unique UNIQUE (book_id, author_id);

INSERT INTO book_author
SELECT *
FROM book_author_distinct;
