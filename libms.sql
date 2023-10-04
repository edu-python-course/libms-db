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
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (1, 'Layo', 'cnijs0@artisteer.com', '9 Luster Parkway', 'Hualongyan', '', '', 'https://dion.ne.jp',
        '+86 (966) 806-7681');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (2, 'Brainlounge', 'mbrawn1@shinystat.com', '5 Lukken Court', 'Al Azraq ash Shamālī', '', '',
        'https://webeden.co.uk', '+962 (810) 419-2320');
INSERT INTO publisher
VALUES (3, 'Jabbertype', 'lfabb2@accuweather.com', '66398 Dunning Pass', 'Tabant', '', '', 'http://blogger.com',
        '+212 (214) 970-4217');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (4, 'Fivebridge', 'nkoomar3@unc.edu', '56 Mcguire Trail', 'Madīnat ‘Īsá', '', '', 'http://statcounter.com',
        '+973 (553) 423-1278');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (5, 'Topdrive', 'jreynard4@netvibes.com', '40 Waxwing Point', 'Palatine', 'Illinois', '60078',
        'https://arizona.edu', '+1 (847) 804-2999');
INSERT INTO publisher
VALUES (6, 'Zoombox', 'ehatwell5@spotify.com', '0152 Novick Street', 'Pasirtundun', '', '', 'https://nasa.gov',
        '+62 (482) 932-6778');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (7, 'Plajo', 'ctogher6@noaa.gov', '40 Brickson Park Junction', 'Shaykh al Ḩadīd', '', '',
        'https://fastcompany.com', '+963 (868) 543-5746');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (8, 'Brainverse', 'laudley7@noaa.gov', '6416 Nova Point', 'Linfen', '', '', 'https://google.ca',
        '+86 (867) 511-6706');
INSERT INTO publisher
VALUES (9, 'Centidel', 'rkarpov8@blogs.com', '3573 Morning Pass', 'Khulm', '', '', 'http://de.vu',
        '+93 (256) 850-7753');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (10, 'Kanoodle', 'dmixer9@vimeo.com', '08282 Schlimgen Hill', 'Trosa', 'Södermanland', '619 35',
        'https://wsj.com', '+46 (387) 621-8396');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (11, 'Aivee', 'dheimesa@geocities.com', '0 Crowley Park', 'Carcarañá', '', '2138', 'http://simplemachines.org',
        '+54 (370) 785-5748');
INSERT INTO publisher
VALUES (12, 'Einti', 'afisbeyb@icio.us', '8849 Loomis Hill', 'Binubusan', '', '2818', 'http://mapquest.com',
        '+63 (953) 325-4118');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (13, 'Devpoint', 'ptretterc@marketwatch.com', '545 Loomis Crossing', 'Dongtang', '', '',
        'https://squarespace.com', '+86 (676) 760-6783');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (14, 'Kazio', 'sjurekd@geocities.com', '7 Coolidge Place', 'Jiuxian', '', '', 'http://com.com',
        '+86 (493) 734-5363');
INSERT INTO publisher
VALUES (15, 'Eamia', 'cbaudine@paypal.com', '5 Main Crossing', 'Langkaplancar', '', '', 'https://yellowpages.com',
        '+62 (674) 648-4811');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (16, 'Rhyloo', 'nalyukinf@dyndns.org', '7668 Schlimgen Junction', 'El Asintal', '', '11009',
        'https://zimbio.com', '+502 (839) 536-9325');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (17, 'Blognation', 'hlorraineg@shop-pro.jp', '909 Transport Avenue', 'Bukama', '', '', 'http://live.com',
        '+242 (393) 918-9107');
INSERT INTO publisher
VALUES (18, 'Dynabox', 'nhabbeshawh@state.gov', '40747 Havey Lane', 'Dikwa', '', '', 'http://wordpress.org',
        '+234 (277) 342-2220');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (19, 'Devpulse', 'kbowmeri@umn.edu', '6 Sullivan Parkway', 'Tekstil’shchiki', '', '678126',
        'https://squarespace.com', '+7 (643) 462-4546');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (20, 'Jayo', 'mliebj@ow.ly', '8 Raven Drive', 'San José de Colinas', '', '', 'https://howstuffworks.com',
        '+504 (367) 980-6835');
INSERT INTO publisher
VALUES (21, 'Jaloo', 'fdilkesk@chicagotribune.com', '5 Susan Terrace', 'Bauta', '', '', 'https://exblog.jp',
        '+53 (549) 466-0516');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (22, 'Yoveo', 'bkleinmintzl@icio.us', '7 Lillian Pass', 'Wolowona', '', '', 'https://e-recht24.de',
        '+62 (731) 854-4777');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (23, 'Livetube', 'mdespenserm@ucoz.ru', '5 Towne Lane', 'Capilla del Monte', '', '5184',
        'https://acquirethisname.com', '+54 (249) 669-6400');
INSERT INTO publisher
VALUES (24, 'Janyx', 'mklaussenn@youtu.be', '964 Memorial Alley', 'Nsukka', '', '', 'https://reddit.com',
        '+234 (486) 318-5944');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (25, 'Talane', 'blanneno@bloglines.com', '8083 Pepper Wood Way', 'Opatów', '', '42-152',
        'http://delicious.com', '+48 (460) 148-6473');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (26, 'Cogidoo', 'ptottonp@zimbio.com', '0567 Ryan Drive', 'Petrijevci', '', '31208', 'https://imageshack.us',
        '+385 (453) 607-5839');
INSERT INTO publisher
VALUES (27, 'Skyble', 'mklaessonq@flavors.me', '31 Brentwood Road', 'Phùng', '', '', 'http://bravesites.com',
        '+84 (913) 107-0837');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (28, 'Topicstorm', 'dmusprattr@moonfruit.com', '59144 Arrowood Terrace', 'A’ershan', '', '',
        'http://virginia.edu', '+86 (643) 124-7956');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (29, 'Feednation', 'jbirchetts@blogspot.com', '042 Maple Junction', 'Sokoto', '', '', 'http://zdnet.com',
        '+234 (659) 448-9867');
INSERT INTO publisher
VALUES (30, 'Tagtune', 'dpateyt@woothemes.com', '7745 Porter Parkway', 'Zbarazh', '', '', 'https://fotki.com',
        '+380 (397) 328-4492');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (31, 'Minyx', 'vmcanultyu@vinaora.com', '67 Spohn Crossing', 'Germiston', '', '1497', 'http://mediafire.com',
        '+27 (305) 597-1936');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (32, 'Rhyzio', 'hruprechtv@phoca.cz', '2 Carey Trail', 'Bailianhe', '', '', 'https://hc360.com',
        '+86 (434) 130-7718');
INSERT INTO publisher
VALUES (33, 'Roodel', 'gkapelhoffw@tuttocitta.it', '155 8th Point', 'Yinjiacheng', '', '', 'https://mayoclinic.com',
        '+86 (733) 536-6144');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (34, 'Layo', 'btallowinx@dedecms.com', '49709 Monument Center', 'Tầm Vu', '', '', 'https://unblog.fr',
        '+84 (831) 663-3523');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (35, 'Kayveo', 'ryeelesy@noaa.gov', '63936 Old Gate Center', 'Lisičani', '', '6539', 'https://engadget.com',
        '+389 (216) 970-7248');
INSERT INTO publisher
VALUES (36, 'Vitz', 'ggilphillanz@washington.edu', '95510 Jenifer Crossing', 'Lisovi Sorochyntsi', '', '',
        'https://cnet.com', '+380 (501) 392-7600');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (37, 'Dabtype', 'bdeane10@upenn.edu', '624 Jana Terrace', 'Zhongcheng', '', '', 'https://newyorker.com',
        '+86 (104) 381-3156');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (38, 'Thoughtbeat', 'dmenhci11@ask.com', '4607 Old Shore Alley', 'Ārān Bīdgol', '', '', 'https://1und1.de',
        '+98 (854) 144-6861');
INSERT INTO publisher
VALUES (39, 'Cogidoo', 'dsambedge12@nih.gov', '77833 Logan Circle', 'Sumberpitu', '', '', 'https://bravesites.com',
        '+62 (431) 788-8222');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (40, 'Trudoo', 'sbroggelli13@tmall.com', '3785 Arizona Trail', 'Zubin Potok', '', '', 'http://apple.com',
        '+383 (586) 254-8326');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (41, 'Skyba', 'fpattemore14@sphinn.com', '6 Bultman Hill', 'Kihangara', '', '', 'http://umich.edu',
        '+255 (424) 146-5932');
INSERT INTO publisher
VALUES (42, 'Jaxspan', 'ggiggs15@about.me', '9 Browning Terrace', 'Phra Pradaeng', '', '10130',
        'https://ycombinator.com', '+66 (925) 842-7551');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (43, 'Divape', 'kdufton16@51.la', '8 Bay Park', 'Kota Kinabalu', 'Sabah', '88817', 'https://ed.gov',
        '+60 (900) 327-1281');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (44, 'Bluejam', 'dtadlow17@sina.com.cn', '3923 Leroy Drive', 'Planovskoye', '', '361222',
        'http://buzzfeed.com', '+7 (927) 397-6779');
INSERT INTO publisher
VALUES (45, 'Devpulse', 'pllop18@yahoo.co.jp', '55 4th Trail', 'Riverton', '', '9847', 'http://4shared.com',
        '+64 (795) 522-2122');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (46, 'Mybuzz', 'gnorwell19@nifty.com', '745 Lerdahl Plaza', 'Vårby', 'Stockholm', '143 42',
        'https://hugedomains.com', '+46 (292) 401-2153');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (47, 'Shufflester', 'fblouet1a@tiny.cc', '796 Vidon Lane', 'Sofifi', '', '', 'https://cisco.com',
        '+62 (635) 679-3764');
INSERT INTO publisher
VALUES (48, 'Skibox', 'dfarquar1b@unesco.org', '1526 Trailsway Avenue', 'Sumber Tengah', '', '', 'https://yahoo.com',
        '+62 (464) 341-2169');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (49, 'Lajo', 'rcamps1c@mapy.cz', '86869 Mockingbird Lane', 'Xiadu', '', '', 'https://google.fr',
        '+86 (277) 203-6872');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (50, 'Gevee', 'babernethy1d@cloudflare.com', '81831 Vidon Road', 'Phù Cát', '', '', 'http://mapy.cz',
        '+84 (754) 464-9091');
INSERT INTO publisher
VALUES (51, 'Camido', 'mhanscom1e@sina.com.cn', '7 Northview Parkway', 'Al Fandaqūmīyah', '', '', 'https://sohu.com',
        '+970 (603) 787-2088');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (52, 'Dynazzy', 'msalling1f@aboutads.info', '273 Bonner Way', 'Al ‘Azīzīyah', '', '', 'http://t.co',
        '+218 (407) 937-2721');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (53, 'Zoomdog', 'jcapon1g@ebay.co.uk', '518 Arrowood Point', 'Aveleda', 'Porto', '4575-393',
        'https://baidu.com', '+351 (139) 668-8097');
INSERT INTO publisher
VALUES (54, 'Dabtype', 'dbaccas1h@buzzfeed.com', '00 Grayhawk Parkway', 'Duqiao', '', '', 'http://cloudflare.com',
        '+86 (991) 273-0023');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (55, 'Zoombeat', 'sellcome1i@wix.com', '327 Harper Plaza', 'Hendala', '', '11830', 'http://barnesandnoble.com',
        '+94 (962) 303-7692');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (56, 'Mita', 'alott1j@nytimes.com', '1 Farmco Road', 'Ambulong', '', '5615', 'http://odnoklassniki.ru',
        '+63 (700) 430-6539');
INSERT INTO publisher
VALUES (57, 'Babbleset', 'pmacbrearty1k@bizjournals.com', '89 Hagan Lane', 'Talisayan', '', '9012', 'https://hud.gov',
        '+63 (382) 511-9777');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (58, 'Brainverse', 'crhucroft1l@illinois.edu', '606 Shelley Terrace', 'Sezemice', '', '533 04',
        'https://amazon.com', '+420 (143) 146-8409');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (59, 'Twinte', 'ryurkevich1m@wikimedia.org', '11242 Ridgeview Terrace', 'Am Djarass', '', '',
        'http://vimeo.com', '+235 (937) 168-7090');
INSERT INTO publisher
VALUES (60, 'Pixoboo', 'drelfe1n@pinterest.com', '27095 1st Hill', 'Coquitlam', 'British Columbia', 'V3B',
        'http://bbb.org', '+1 (408) 118-2412');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (61, 'Rhybox', 'cchesswas1o@360.cn', '49 Dahle Street', 'Timmins', 'Ontario', 'P4P', 'http://dell.com',
        '+1 (177) 739-7245');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (62, 'Yozio', 'krussi1p@typepad.com', '4211 Green Ridge Terrace', 'Sangali', '', '1154', 'https://soup.io',
        '+63 (982) 402-2588');
INSERT INTO publisher
VALUES (63, 'Viva', 'rcarbin1q@sakura.ne.jp', '43623 Bunker Hill Drive', 'Cabiguan', '', '1144',
        'http://scientificamerican.com', '+63 (187) 833-4477');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (64, 'Babbleopia', 'adavidowsky1r@patch.com', '805 Dryden Trail', 'Georgīevka', '', '', 'http://google.com.au',
        '+7 (857) 575-2877');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (65, 'Quinu', 'rblaxill1s@google.ru', '7 Cherokee Lane', 'Jianfeng', '', '', 'http://woothemes.com',
        '+86 (999) 840-0857');
INSERT INTO publisher
VALUES (66, 'Npath', 'ebabalola1t@microsoft.com', '26271 Bobwhite Way', 'Kalkal Barat', '', '', 'https://pcworld.com',
        '+62 (196) 408-6753');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (67, 'Eidel', 'bweavill1u@cpanel.net', '0 Esker Road', 'Raposeira', 'Viseu', '5100-419',
        'http://clickbank.net', '+351 (630) 294-8947');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (68, 'Brightbean', 'bmarflitt1v@g.co', '23 Barnett Drive', 'Zhangzhu', '', '', 'http://apple.com',
        '+86 (199) 471-4247');
INSERT INTO publisher
VALUES (69, 'Youbridge', 'aosinin1w@irs.gov', '7990 Evergreen Junction', 'Nirji', '', '', 'https://ustream.tv',
        '+86 (368) 754-5878');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (70, 'Quire', 'ajahnisch1x@lycos.com', '90324 Eagle Crest Terrace', 'Saint-Laurent-du-Var',
        'Provence-Alpes-Côte d''Azur', '06721 CEDEX', 'http://forbes.com', '+33 (350) 294-4715');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (71, 'Thoughtbridge', 'nwoofinden1y@wired.com', '05 Continental Circle', 'Vermelha', 'Lisboa', '2550-523',
        'https://w3.org', '+351 (865) 886-8518');
INSERT INTO publisher
VALUES (72, 'Eimbee', 'bspurdon1z@businessinsider.com', '7 Brickson Park Avenue', 'Jintun', '', '', 'http://phoca.cz',
        '+86 (469) 267-2846');
INSERT INTO "publisher" ("id", "name", "email", "street", "city", "state", "postal", "website", "phone")
VALUES (73, 'Riffwire', 'fiwaszkiewicz20@oakley.com', '61391 Miller Pass', 'Charlottesville', 'Virginia', '22908',
        'https://cloudflare.com', '+1 (434) 643-0567');
INSERT INTO publisher (id, name, email, street, city, state, postal, website, phone)
VALUES (74, 'Voomm', 'ehoulison21@cnbc.com', '1726 Luster Road', 'Fufang', '', '', 'http://so-net.ne.jp',
        '+86 (653) 888-4573');
INSERT INTO publisher
VALUES (75, 'Gigabox', 'bsuerz22@archive.org', '37319 Lukken Trail', 'Bungu', '', '', 'http://hubpages.com',
        '+255 (642) 172-8416');


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

-- label: dml-member
INSERT INTO member(first_name, last_name, birthdate, registered, email, phone)
VALUES ('Inigo', 'McGilmartin', NULL, '2022-11-12', 'imcgilmartin0@ycombinator.com', '+30 (663) 346-2223'),
       ('Anissa', 'Denisevich', '1999-11-23', '2014-12-21', 'adenisevich1@over-blog.com', '+506 (689) 259-2579'),
       ('Betteann', 'Chasmer', '1990-12-26', '2022-03-15', 'bchasmer2@cpanel.net', '+355 (773) 387-6915'),
       ('Abbey', 'Shrive', '2003-03-23', '2021-09-11', 'ashrive3@constantcontact.com', '+86 (286) 232-7032'),
       ('Ainslee', 'Seavers', NULL, '2019-09-11', NULL, '+86 (579) 305-0260'),
       ('Tedda', 'Gleeton', '1972-07-26', '2014-06-06', 'tgleeton5@squidoo.com', '+359 (354) 838-9333'),
       ('Maybelle', 'Elston', '1971-02-13', '2019-02-15', 'melston6@sogou.com', '+62 (130) 112-7927'),
       ('Nev', 'Iwanowski', NULL, '2018-08-15', 'niwanowski7@ebay.co.uk', '+81 (946) 427-7881'),
       ('Corilla', 'Jerisch', '2002-04-18', '2023-03-30', 'cjerisch8@topsy.com', '+62 (629) 829-6722'),
       ('Bent', 'Wright', '2003-02-06', '2017-05-23', NULL, '+58 (672) 413-6137'),
       ('Adella', 'Schellig', '2008-11-08', '2022-03-10', 'aschelliga@scientificamerican.com', '+351 (240) 376-6455'),
       ('Kelsy', 'McGragh', '1976-11-28', '2016-08-15', 'kmcgraghb@twitter.com', '+1 (714) 492-2489'),
       ('Mollee', 'Pietruszka', NULL, '2021-08-01', 'mpietruszkac@home.pl', '+1 (619) 731-6568'),
       ('Raynard', 'Futter', '1999-12-16', '2018-09-19', 'rfutterd@vistaprint.com', '+66 (508) 291-0822'),
       ('Harlen', 'Berth', NULL, '2013-12-21', 'hberthe@etsy.com', '+86 (453) 302-1389'),
       ('Binnie', 'Penhalurick', '1974-08-18', '2018-10-05', 'bpenhalurickf@zimbio.com', '+62 (886) 203-6451'),
       ('Inna', 'McClory', '1982-09-22', '2020-10-03', 'imccloryg@1688.com', '+62 (409) 969-0246'),
       ('Blake', 'Richings', '1977-03-18', '2022-10-24', NULL, '+86 (878) 897-6487'),
       ('Ester', 'Shakesby', '1977-08-10', '2022-05-28', 'eshakesbyi@studiopress.com', '+355 (451) 590-6753'),
       ('Gwenora', 'Heater', '1969-04-14', '2018-06-15', 'gheaterj@msn.com', '+86 (259) 285-0816'),
       ('Debby', 'Seman', '1968-03-02', '2021-09-03', 'dsemank@blogspot.com', '+976 (420) 584-7938'),
       ('Earl', 'Depka', '1963-11-02', '2018-12-07', 'edepkal@myspace.com', '+593 (867) 839-0586'),
       ('Aeriell', 'Espadero', NULL, '2018-03-07', 'aespaderom@mashable.com', '+58 (416) 371-0853'),
       ('Freddy', 'Sweeny', '2006-06-28', '2023-05-13', NULL, '+86 (714) 905-3880'),
       ('Pauly', 'Calver', '2013-07-03', '2021-09-04', 'pcalvero@spotify.com', '+55 (752) 735-7482'),
       ('Stephana', 'Robilliard', NULL, '2015-10-12', 'srobilliardp@woothemes.com', '+46 (105) 163-7602'),
       ('Cynthy', 'Drivers', '1990-09-20', '2013-12-15', NULL, '+351 (420) 496-8115'),
       ('Raye', 'Merriment', '2006-10-29', '2022-06-27', 'rmerrimentr@posterous.com', '+55 (718) 546-8509'),
       ('Norbie', 'Dudden', '2014-12-19', '2016-03-11', 'nduddens@oakley.com', '+234 (982) 364-2725'),
       ('Tanya', 'Yakuntsov', '1962-03-22', '2015-01-25', 'tyakuntsovt@stumbleupon.com', '+66 (967) 394-1658'),
       ('Tessie', 'Teanby', '1966-08-17', '2015-03-28', NULL, '+850 (845) 265-2159'),
       ('Rosette', 'Gabbot', '1975-04-28', '2014-04-04', 'rgabbotv@hubpages.com', '+46 (377) 485-4567'),
       ('Barrie', 'Tamlett', NULL, '2015-05-11', 'btamlettw@google.co.uk', '+63 (688) 789-4185'),
       ('Georgeanne', 'Cardew', '1966-11-16', '2021-08-25', NULL, '+1 (517) 313-6060'),
       ('Guido', 'Fearnyhough', '2001-08-10', '2022-03-22', NULL, '+225 (105) 173-4031'),
       ('Mathe', 'Dumingos', '1969-02-04', '2015-11-15', NULL, '+7 (292) 639-7909'),
       ('Abramo', 'Goggin', NULL, '2013-12-17', 'agoggin10@webmd.com', '+48 (599) 745-1615'),
       ('Flossie', 'Ethelstone', '2009-02-26', '2017-05-23', NULL, '+7 (567) 908-6560'),
       ('Luca', 'Labet', '1977-09-08', '2017-02-01', 'llabet12@indiegogo.com', '+351 (711) 250-1163'),
       ('Jana', 'Yerborn', '1974-06-18', '2015-06-01', 'jyerborn13@washington.edu', '+47 (113) 285-5767'),
       ('Zared', 'Vedikhov', '2003-06-02', '2017-11-10', NULL, '+260 (250) 389-9501'),
       ('Luca', 'Jones', '1963-07-05', '2014-05-10', NULL, '+386 (735) 649-2547'),
       ('Annemarie', 'Salazar', NULL, '2018-06-27', 'asalazar16@myspace.com', '+385 (994) 825-0365'),
       ('Tallou', 'Easlea', '1959-01-22', '2019-08-27', 'teaslea17@over-blog.com', '+62 (476) 674-0024'),
       ('Ramsey', 'Gifford', NULL, '2018-12-16', 'rgifford18@naver.com', '+48 (550) 706-1186'),
       ('Quillan', 'Spottswood', '1993-05-22', '2018-03-16', 'qspottswood19@g.co', '+385 (146) 427-4789'),
       ('Lissa', 'Vedekhov', '1992-10-19', '2023-01-27', NULL, '+48 (200) 497-2138'),
       ('Gilburt', 'Penney', NULL, '2014-01-10', 'gpenney1b@list-manage.com', '+237 (101) 429-1372'),
       ('Petronille', 'Morfell', '1991-12-26', '2018-09-17', NULL, '+86 (273) 869-3061'),
       ('Dunc', 'Milesop', NULL, '2015-12-10', 'dmilesop1d@imdb.com', '+27 (352) 638-8329'),
       ('Keslie', 'Honsch', '1961-09-12', '2018-10-11', 'khonsch1e@freewebs.com', '+55 (633) 727-8568'),
       ('Milty', 'Whittle', '1990-03-02', '2021-01-17', NULL, '+27 (337) 113-2725'),
       ('Hobie', 'Piniur', '2008-06-04', '2017-09-24', NULL, '+86 (427) 389-4954'),
       ('Ronny', 'Borham', '1980-12-28', '2022-04-30', 'rborham1h@behance.net', '+86 (951) 117-8164'),
       ('Tallulah', 'Franssen', '1959-05-05', '2021-09-09', NULL, '+234 (936) 351-7125'),
       ('Cinda', 'Gunbie', '1997-09-23', '2020-10-16', 'cgunbie1j@constantcontact.com', '+7 (577) 740-2350'),
       ('Hill', 'Riatt', NULL, '2021-04-15', 'hriatt1k@europa.eu', '+351 (583) 309-2810'),
       ('Dominic', 'Tutin', '1975-12-24', '2017-09-06', 'dtutin1l@jigsy.com', '+970 (647) 767-8735'),
       ('Finn', 'Follos', '2014-08-25', '2015-01-30', 'ffollos1m@squarespace.com', '+7 (250) 422-8228'),
       ('Chucho', 'Berrycloth', '1959-12-16', '2022-05-02', NULL, '+86 (782) 899-4342'),
       ('Adelind', 'Bloyes', NULL, '2019-11-18', 'abloyes1o@nytimes.com', '+1 (764) 672-6472'),
       ('Flossie', 'Mac Geaney', '1983-06-20', '2019-01-17', 'fmacgeaney1p@ycombinator.com', '+55 (568) 243-4228'),
       ('Zolly', 'Sparsholt', '1972-05-27', '2016-02-19', 'zsparsholt1q@wix.com', '+86 (387) 184-3019'),
       ('Clarey', 'Dodshon', '1978-03-10', '2021-05-11', 'cdodshon1r@skype.com', '+62 (366) 128-0145'),
       ('Padget', 'Fanthome', '1980-12-25', '2023-08-27', NULL, '+374 (225) 293-3123'),
       ('Benny', 'Leavens', '2000-03-22', '2014-06-06', NULL, '+1 (615) 627-4124'),
       ('Kilian', 'Riehm', '1964-11-18', '2015-08-17', 'kriehm1u@nydailynews.com', '+353 (885) 106-2178'),
       ('Marv', 'Steinson', '1989-12-13', '2018-07-29', 'msteinson1v@wp.com', '+380 (784) 237-9475'),
       ('Garreth', 'Rodgman', '1992-12-12', '2017-02-02', 'grodgman1w@so-net.ne.jp', '+63 (314) 348-2344'),
       ('Fredericka', 'Dey', '2013-05-01', '2016-01-03', 'fdey1x@tinyurl.com', '+82 (948) 475-7613'),
       ('Tania', 'Bagnold', '2001-06-04', '2017-06-18', 'tbagnold1y@shareasale.com', '+52 (816) 405-2760'),
       ('Glenine', 'Harron', '1968-11-05', '2019-03-23', 'gharron1z@alibaba.com', '+66 (732) 180-4034'),
       ('Aimee', 'Chester', '1988-07-27', '2023-06-27', 'achester20@xinhuanet.com', '+48 (600) 495-6324'),
       ('Ursa', 'Breache', NULL, '2023-09-13', 'ubreache21@ebay.co.uk', '+46 (190) 510-0742'),
       ('Franciska', 'Haddock', NULL, '2017-12-06', NULL, '+220 (939) 205-5136'),
       ('Germain', 'Commin', '1971-05-22', '2020-07-06', 'gcommin23@networkadvertising.org', '+256 (366) 523-0394'),
       ('Beck', 'Lehmann', '1991-08-22', '2014-03-05', 'blehmann24@wikispaces.com', '+351 (164) 420-4729'),
       ('Vernen', 'Damper', '2015-02-25', '2016-11-30', 'vdamper25@hexun.com', '+55 (682) 968-8170'),
       ('Elane', 'Scyone', '1970-06-27', '2023-07-05', NULL, '+30 (102) 613-3818'),
       ('Jamey', 'Ravenscroft', '1966-03-03', '2023-01-11', 'jravenscroft27@accuweather.com', '+7 (250) 410-3412'),
       ('Charmaine', 'Linton', '1983-10-22', '2015-08-14', 'clinton28@sourceforge.net', '+383 (539) 561-8680'),
       ('Dulcia', 'Tethcote', '2007-03-18', '2015-12-11', 'dtethcote29@cisco.com', '+234 (255) 878-8827'),
       ('Arman', 'Filkov', '1969-06-18', '2017-04-27', NULL, '+62 (267) 119-1952'),
       ('Andonis', 'Jammet', '1973-03-09', '2018-09-28', NULL, '+963 (265) 414-1702'),
       ('Jarrad', 'O''Hengerty', '2007-08-11', '2019-11-06', 'johengerty2c@ask.com', '+7 (595) 601-9188'),
       ('Zaneta', 'Cruise', '1998-10-19', '2016-05-13', 'zcruise2d@admin.ch', '+380 (368) 792-3662'),
       ('Sutherland', 'Sazio', '2007-02-16', '2023-07-05', 'ssazio2e@shinystat.com', '+62 (995) 437-5370'),
       ('Thom', 'Arnecke', NULL, '2019-10-20', 'tarnecke2f@senate.gov', '+34 (107) 386-2393'),
       ('Archaimbaud', 'Neissen', '1993-11-19', '2019-04-09', 'aneissen2g@mtv.com', '+82 (779) 614-0849'),
       ('Jeni', 'Loxly', '1970-10-13', '2020-07-17', 'jloxly2h@cornell.edu', '+507 (451) 473-2216'),
       ('Shanon', 'Coey', '2003-04-11', '2023-08-10', 'scoey2i@fema.gov', '+62 (178) 163-1749'),
       ('Bendix', 'Hearnah', '1968-01-09', '2016-06-24', 'bhearnah2j@altervista.org', '+30 (335) 449-0233'),
       ('Katharina', 'Matisse', NULL, '2016-02-07', 'kmatisse2k@ihg.com', '+86 (871) 958-4631'),
       ('Carr', 'Manus', '2013-12-29', '2016-02-16', 'cmanus2l@addthis.com', '+1 (608) 116-6511'),
       ('Archambault', 'O''Mohun', '1997-04-25', '2020-10-21', 'aomohun2m@goodreads.com', '+7 (411) 260-9685'),
       ('Filmer', 'Wilcocks', '1993-09-22', '2022-04-22', NULL, '+1 (683) 244-8836'),
       ('Gannie', 'Burchall', '1975-07-04', '2016-03-30', 'gburchall2o@macromedia.com', '+48 (603) 547-5778'),
       ('Barnabas', 'Borgnet', '2000-03-24', '2021-11-24', NULL, '+7 (615) 110-9096'),
       ('Elisabet', 'Cristou', '1982-09-19', '2020-08-11', 'ecristou2q@state.tx.us', '+1 (374) 921-0772'),
       ('Annie', 'Miller', '2004-09-04', '2016-09-29', 'amiller2r@bbc.co.uk', '+63 (510) 790-2373'),
       ('Joell', 'Reuter', '1984-12-24', '2016-08-24', 'jreuter2s@irs.gov', '+86 (505) 177-3425'),
       ('Doralynn', 'Thinn', '2001-04-21', '2022-02-05', 'dthinn2t@uol.com.br', '+48 (885) 239-7118'),
       ('Beth', 'Careswell', '1974-06-17', '2014-08-20', 'bcareswell2u@buzzfeed.com', '+1 (831) 862-1574'),
       ('Lenee', 'Sebert', '2012-01-06', '2022-12-29', 'lsebert2v@cbc.ca', '+86 (406) 849-1693'),
       ('Angelia', 'McLellan', NULL, '2016-08-11', 'amclellan2w@123-reg.co.uk', '+212 (203) 802-0570'),
       ('Broderick', 'Dorgan', NULL, '2022-08-01', 'bdorgan2x@last.fm', '+62 (465) 406-0419'),
       ('Sinclair', 'McLaren', '1994-02-11', '2023-06-04', 'smclaren2y@skype.com', '+351 (964) 599-8832'),
       ('Northrup', 'Shorte', '2015-01-31', '2022-07-29', NULL, '+62 (279) 716-5227'),
       ('Rosabelle', 'Farthin', '1981-08-11', '2019-12-22', 'rfarthin30@biblegateway.com', '+86 (401) 599-5400'),
       ('Brock', 'Marusyak', '1959-02-19', '2016-05-01', 'bmarusyak31@nasa.gov', '+62 (147) 405-6166'),
       ('Austin', 'Filippozzi', '1978-01-18', '2022-03-24', 'afilippozzi32@altervista.org', '+86 (793) 302-5459'),
       ('Wenona', 'Symson', '1994-09-14', '2017-06-26', NULL, '+94 (318) 962-2997'),
       ('Betty', 'Blackett', NULL, '2015-04-27', NULL, '+351 (222) 552-6391'),
       ('Toiboid', 'Galway', '2005-04-22', '2019-07-12', 'tgalway35@linkedin.com', '+226 (430) 267-5866'),
       ('Sonnie', 'Cragell', '1984-09-07', '2018-01-31', 'scragell36@huffingtonpost.com', '+62 (861) 362-4627'),
       ('Laura', 'Boddymead', '2013-07-19', '2014-07-09', 'lboddymead37@slideshare.net', '+254 (375) 243-9989'),
       ('Fraser', 'Mushet', '1992-10-13', '2021-10-26', 'fmushet38@google.es', '+593 (923) 776-6742'),
       ('Kessia', 'Trevance', '1971-07-19', '2017-07-04', NULL, '+86 (963) 775-8682'),
       ('Scott', 'Bennit', '1971-01-30', '2018-03-17', 'sbennit3a@spiegel.de', '+967 (307) 918-6744'),
       ('Anett', 'Hayter', '1991-01-04', '2016-11-17', 'ahayter3b@oakley.com', '+86 (386) 487-0044'),
       ('Mandy', 'Bleything', '1988-10-30', '2021-06-03', NULL, '+48 (853) 473-4363'),
       ('Delly', 'Bims', NULL, '2014-10-08', 'dbims3d@diigo.com', '+62 (126) 107-6893'),
       ('Ines', 'Marrows', '1993-05-08', '2023-08-05', 'imarrows3e@dot.gov', '+46 (108) 806-2091'),
       ('Mahmoud', 'O''Dulchonta', '2013-02-21', '2019-08-10', 'modulchonta3f@google.nl', '+1 (925) 468-9058'),
       ('Lorene', 'Conti', '1963-06-23', '2014-12-05', 'lconti3g@arstechnica.com', '+963 (977) 224-8266'),
       ('Shaw', 'Leupoldt', '1961-08-04', '2020-01-31', 'sleupoldt3h@netvibes.com', '+57 (140) 537-8900'),
       ('Genevieve', 'Maher', '1965-05-10', '2020-07-21', NULL, '+62 (327) 584-4656'),
       ('Loise', 'Loftin', '2008-04-25', '2022-02-20', 'lloftin3j@linkedin.com', '+1 (805) 326-3732'),
       ('Dianne', 'Pollington', '2005-08-31', '2021-03-19', NULL, '+7 (529) 245-3963'),
       ('Randie', 'Kenninghan', '1986-02-01', '2015-03-12', NULL, '+62 (420) 520-3384'),
       ('Sari', 'Kiddey', NULL, '2023-07-16', 'skiddey3m@joomla.org', '+84 (437) 996-8756'),
       ('Joelie', 'Fullicks', '2006-08-27', '2016-07-31', NULL, '+62 (854) 150-7873'),
       ('Jamima', 'Royste', '1974-05-03', '2020-06-18', 'jroyste3o@typepad.com', '+51 (866) 171-4122'),
       ('Fulvia', 'Hann', '1981-05-01', '2016-04-28', 'fhann3p@sakura.ne.jp', '+7 (554) 230-6024'),
       ('Susanna', 'Birchill', NULL, '2014-04-02', 'sbirchill3q@theguardian.com', '+86 (842) 575-1776'),
       ('Willard', 'McCanny', '2000-11-15', '2018-06-23', 'wmccanny3r@narod.ru', '+86 (434) 229-5558'),
       ('Rafferty', 'Knaggs', '1962-03-11', '2015-06-17', 'rknaggs3s@w3.org', '+54 (259) 269-4755'),
       ('Linnell', 'Wolfart', NULL, '2023-04-17', NULL, '+86 (376) 464-0590'),
       ('Lanny', 'Lambard', NULL, '2022-11-15', 'llambard3u@yale.edu', '+62 (250) 609-3787'),
       ('Melisa', 'Torbard', '1987-02-23', '2020-04-11', 'mtorbard3v@army.mil', '+351 (759) 992-5002'),
       ('Tome', 'Kobsch', '1989-08-07', '2018-09-09', 'tkobsch3w@lycos.com', '+33 (431) 109-6191'),
       ('Mandy', 'Kehir', '1980-09-19', '2018-02-25', 'mkehir3x@earthlink.net', '+48 (782) 767-3215'),
       ('Myra', 'De Cristoforo', '2006-05-05', '2023-08-25', 'mdecristoforo3y@imgur.com', '+1 (780) 740-2549'),
       ('Andrew', 'Chaloner', '1994-12-30', '2016-01-29', 'achaloner3z@scribd.com', '+48 (928) 573-5765'),
       ('Hester', 'Scammell', '1987-07-13', '2017-11-17', 'hscammell40@ted.com', '+86 (898) 371-1397'),
       ('Dionne', 'Tomley', '2010-07-10', '2020-01-15', 'dtomley41@census.gov', '+33 (501) 591-1347'),
       ('Ellery', 'Asee', '1963-05-05', '2017-04-07', 'easee42@fc2.com', '+63 (232) 521-2717'),
       ('Codie', 'Allibon', NULL, '2017-08-05', 'callibon43@geocities.com', '+62 (960) 449-4783'),
       ('Vin', 'Jagels', '1999-06-23', '2019-03-05', 'vjagels44@biblegateway.com', '+352 (350) 729-4068'),
       ('Jaimie', 'Cranage', '1962-03-28', '2015-07-17', 'jcranage45@loc.gov', '+86 (842) 733-7292'),
       ('Seward', 'Chiese', NULL, '2023-08-29', 'schiese46@free.fr', '+86 (956) 327-5293'),
       ('Kelcie', 'Firle', '2004-12-10', '2015-12-10', 'kfirle47@ed.gov', '+63 (235) 319-3853'),
       ('Cecilia', 'Trynor', '2015-06-15', '2022-11-02', NULL, '+7 (381) 484-2281'),
       ('Berthe', 'Bard', '2002-07-28', '2015-12-04', 'bbard49@mail.ru', '+351 (933) 248-7219'),
       ('Steffie', 'Van der Son', NULL, '2017-06-18', 'svanderson4a@alibaba.com', '+54 (328) 607-9048'),
       ('Sileas', 'Yeandel', '1971-12-07', '2018-04-28', NULL, '+7 (839) 575-3772'),
       ('Clemmy', 'Ryde', '1984-12-10', '2017-04-24', 'cryde4c@taobao.com', '+62 (942) 681-2141'),
       ('Bordy', 'Pedrazzi', '1998-05-01', '2016-03-25', 'bpedrazzi4d@tinypic.com', '+55 (388) 603-1272'),
       ('Aeriell', 'Ygou', '2007-12-12', '2020-11-28', 'aygou4e@jimdo.com', '+60 (260) 647-5519'),
       ('Ashlan', 'Elsom', '1997-09-09', '2016-07-23', NULL, '+46 (299) 371-1361'),
       ('Wilbur', 'Parfett', '1962-04-21', '2018-06-20', 'wparfett4g@instagram.com', '+60 (359) 756-9323'),
       ('Angel', 'Tommaseo', '2011-01-19', '2016-09-06', NULL, '+420 (372) 988-8480'),
       ('Lynnea', 'O''Dea', '1986-07-31', '2015-12-03', 'lodea4i@lycos.com', '+55 (906) 673-6924'),
       ('Francklin', 'Peddersen', '2010-08-09', '2023-03-09', 'fpeddersen4j@icio.us', '+374 (295) 414-2793'),
       ('Granny', 'Braddick', NULL, '2022-06-01', NULL, '+33 (216) 383-6070'),
       ('Alanson', 'Challiss', '1964-11-28', '2023-09-13', 'achalliss4l@engadget.com', '+62 (827) 333-0390'),
       ('Jacob', 'D''Elias', '1986-12-14', '2023-02-22', 'jdelias4m@squidoo.com', '+358 (424) 781-5267'),
       ('Guinevere', 'Wissby', '1962-05-07', '2018-12-15', 'gwissby4n@google.it', '+55 (815) 646-1271'),
       ('Alana', 'Dranfield', '2008-07-04', '2015-08-31', NULL, '+63 (613) 777-1465'),
       ('Dorry', 'Snowling', '2015-08-04', '2018-12-29', 'dsnowling4p@odnoklassniki.ru', '+86 (743) 922-7406'),
       ('Dollie', 'Tolussi', '1971-09-09', '2018-07-18', NULL, '+33 (944) 819-1177'),
       ('Sophronia', 'Gouldstone', NULL, '2023-05-08', NULL, '+996 (234) 998-0978'),
       ('Elbertine', 'Gentil', '2014-04-05', '2021-01-13', 'egentil4s@typepad.com', '+86 (222) 827-9875'),
       ('Kip', 'Malt', '1963-02-21', '2015-05-10', 'kmalt4t@usatoday.com', '+353 (394) 785-2227'),
       ('Aeriell', 'Tompkin', '2011-08-03', '2016-04-02', 'atompkin4u@yellowbook.com', '+86 (719) 113-4704'),
       ('Evangelia', 'Kernermann', '1971-12-07', '2020-04-23', 'ekernermann4v@seesaa.net', '+62 (980) 593-5032'),
       ('Nanci', 'Heigold', '1964-06-26', '2015-02-05', NULL, '+55 (845) 802-9120'),
       ('Don', 'Fullun', '1965-12-23', '2014-04-03', 'dfullun4x@phoca.cz', '+86 (531) 332-2756'),
       ('Tanny', 'Brunskill', '1988-04-02', '2017-01-16', NULL, '+62 (967) 629-2761'),
       ('Bat', 'Markham', '1971-01-31', '2020-06-01', NULL, '+55 (364) 429-8270'),
       ('Phillida', 'Corbally', '1977-02-17', '2021-06-02', 'pcorbally50@t-online.de', '+86 (135) 414-1184'),
       ('Jania', 'Cianni', '2007-07-01', '2017-08-21', NULL, '+62 (683) 252-8333'),
       ('Lars', 'York', '2014-09-06', '2014-01-05', 'lyork52@house.gov', '+507 (129) 777-4721'),
       ('Viv', 'Scolding', '1994-08-30', '2023-09-16', 'vscolding53@cnn.com', '+86 (844) 261-3642'),
       ('Mel', 'McCartan', '1968-08-03', '2019-08-17', 'mmccartan54@ted.com', '+84 (281) 313-7747'),
       ('Alicia', 'Balog', '1969-09-10', '2021-09-17', 'abalog55@wp.com', '+62 (755) 913-2956'),
       ('Jami', 'Biggam', '2013-10-07', '2019-09-18', 'jbiggam56@nih.gov', '+963 (675) 559-9260'),
       ('Anabella', 'Comelini', '1979-10-25', '2020-01-17', NULL, '+994 (262) 272-7703'),
       ('Lindi', 'Puttergill', '1963-06-11', '2020-01-09', 'lputtergill58@washingtonpost.com', '+86 (983) 176-0916'),
       ('Dolph', 'Lawtie', '1963-03-11', '2020-02-08', NULL, '+373 (448) 537-6326'),
       ('Trish', 'Wedgbrow', '1985-11-11', '2015-04-26', 'twedgbrow5a@nasa.gov', '+86 (974) 285-7642'),
       ('Lucille', 'Airdrie', '1975-01-17', '2022-01-19', 'lairdrie5b@seesaa.net', '+86 (588) 354-9204'),
       ('Carie', 'McMearty', '1963-11-02', '2017-08-09', NULL, '+380 (986) 505-0113'),
       ('Tabina', 'Bullers', '1979-02-16', '2014-03-27', 'tbullers5d@bbb.org', '+63 (643) 150-8074'),
       ('Wynne', 'Mundell', NULL, '2017-01-23', 'wmundell5e@google.cn', '+351 (730) 754-3234'),
       ('Herold', 'Vigours', '1988-05-07', '2020-01-18', 'hvigours5f@netlog.com', '+66 (435) 958-3891'),
       ('Aaren', 'McNeilly', '1959-05-17', '2016-09-17', 'amcneilly5g@tuttocitta.it', '+237 (218) 393-7860'),
       ('Bernadette', 'Endrizzi', '1968-09-28', '2019-12-19', 'bendrizzi5h@themeforest.net', '+355 (531) 656-8134'),
       ('Ruthe', 'Franceschino', '1977-09-14', '2017-12-26', 'rfranceschino5i@epa.gov', '+970 (631) 727-3023'),
       ('Ernesta', 'Hambly', NULL, '2022-12-18', NULL, '+57 (253) 457-9026'),
       ('Jed', 'Luty', '1964-04-26', '2018-05-18', 'jluty5k@latimes.com', '+994 (446) 972-9074'),
       ('Madlin', 'Offner', '1963-05-23', '2021-09-09', 'moffner5l@wikipedia.org', '+7 (126) 747-6064'),
       ('Paolo', 'Heasly', NULL, '2022-12-30', NULL, '+81 (224) 779-2935'),
       ('Gae', 'Swindley', '1982-01-18', '2020-05-28', 'gswindley5n@unesco.org', '+46 (184) 997-1707'),
       ('Patty', 'Cradock', '2010-08-05', '2018-09-09', NULL, '+7 (550) 717-2414'),
       ('Glyn', 'Coxhead', '1959-11-30', '2021-05-01', 'gcoxhead5p@netscape.com', '+967 (907) 898-7512'),
       ('Rosabelle', 'Paprotny', '1995-01-09', '2022-02-06', NULL, '+62 (766) 147-5296'),
       ('Queenie', 'Beardshall', '1959-09-02', '2016-10-30', 'qbeardshall5r@thetimes.co.uk', '+46 (841) 858-5661'),
       ('Eula', 'Bringloe', NULL, '2021-03-05', 'ebringloe5s@geocities.jp', '+1 (323) 888-9968'),
       ('Lanny', 'Huerta', '2003-05-15', '2018-09-02', NULL, '+66 (618) 814-1001'),
       ('Nataline', 'Foukx', '1964-10-15', '2019-11-09', 'nfoukx5u@t.co', '+92 (578) 136-8801'),
       ('Sherill', 'Falkner', '1989-06-24', '2018-10-14', NULL, '+46 (437) 114-3735'),
       ('Vonnie', 'Ledamun', '2005-11-03', '2017-04-03', 'vledamun5w@npr.org', '+86 (874) 575-9520'),
       ('Dulcine', 'Dumblton', '1967-12-19', '2022-11-17', NULL, '+358 (871) 987-8030'),
       ('Ignazio', 'Veare', '2003-01-12', '2019-04-03', 'iveare5y@bravesites.com', '+7 (257) 899-9081'),
       ('Rochelle', 'Dimont', '2009-07-13', '2023-02-20', NULL, '+55 (820) 721-3459'),
       ('Sayer', 'Farans', NULL, '2023-09-09', 'sfarans60@yelp.com', '+502 (234) 763-2631'),
       ('Bonnibelle', 'Loadwick', '2012-12-30', '2021-04-12', NULL, '+86 (444) 995-0295'),
       ('Octavius', 'Speek', '1991-11-25', '2022-02-14', 'ospeek62@hexun.com', '+48 (695) 162-6463'),
       ('Ronni', 'Pettus', '1972-09-23', '2020-06-02', 'rpettus63@geocities.jp', '+351 (243) 878-2977'),
       ('Mace', 'Worman', '1998-12-24', '2017-02-13', 'mworman64@loc.gov', '+62 (943) 824-1828'),
       ('Klara', 'Ogg', '2015-09-04', '2016-12-30', 'kogg65@virginia.edu', '+7 (297) 175-1091'),
       ('Avie', 'Coils', '1993-02-19', '2022-11-03', 'acoils66@livejournal.com', '+86 (985) 432-8027'),
       ('Caz', 'Walworth', '2011-04-24', '2016-06-26', 'cwalworth67@google.com', '+62 (598) 609-7801'),
       ('Lesley', 'Walbrun', '1974-03-21', '2019-12-30', 'lwalbrun68@theguardian.com', '+86 (480) 197-7875'),
       ('Barrett', 'Carlson', '1969-06-14', '2014-06-05', 'bcarlson69@nytimes.com', '+64 (512) 171-3005'),
       ('Dorie', 'Woolens', '1981-10-31', '2022-12-14', 'dwoolens6a@1688.com', '+420 (604) 736-7446'),
       ('Vite', 'Piatti', NULL, '2019-10-29', 'vpiatti6b@about.me', '+7 (316) 996-2609'),
       ('Patrizia', 'Jeromson', '1959-03-18', '2020-04-14', 'pjeromson6c@csmonitor.com', '+1 (513) 629-6021'),
       ('Sargent', 'Hapgood', '1980-03-04', '2018-02-10', 'shapgood6d@tinyurl.com', '+7 (141) 741-2077'),
       ('Eugene', 'Cornish', '1977-06-07', '2019-09-03', 'ecornish6e@ehow.com', '+63 (534) 922-9507'),
       ('Millard', 'Ditch', '2000-10-15', '2017-02-13', NULL, '+86 (368) 340-1969'),
       ('Aldo', 'Hulme', '1988-09-28', '2023-05-14', 'ahulme6g@networksolutions.com', '+48 (965) 697-5777'),
       ('Fidole', 'Dugall', '1995-03-04', '2018-01-20', 'fdugall6h@discuz.net', '+380 (673) 168-3198'),
       ('Maye', 'Gear', '2014-03-04', '2017-04-23', 'mgear6i@arizona.edu', '+7 (818) 638-1434'),
       ('Kean', 'Stronough', '1962-02-23', '2016-06-05', 'kstronough6j@sun.com', '+55 (906) 988-1612'),
       ('Aloise', 'Mushrow', '2009-08-26', '2020-02-16', 'amushrow6k@ed.gov', '+63 (282) 825-8396'),
       ('Jamie', 'Jaggs', NULL, '2016-09-21', 'jjaggs6l@sakura.ne.jp', '+56 (462) 150-9218'),
       ('Jermaine', 'Ballefant', '2009-02-19', '2023-04-17', 'jballefant6m@reference.com', '+86 (841) 646-7971'),
       ('Walton', 'Lambrook', '1987-08-15', '2019-01-27', 'wlambrook6n@lycos.com', '+263 (443) 512-8505'),
       ('Alysa', 'O''Feeny', '1974-01-21', '2020-12-18', 'aofeeny6o@about.com', '+963 (469) 219-9390'),
       ('Mic', 'Chattaway', NULL, '2013-11-30', NULL, '+62 (787) 852-1982'),
       ('Bernadene', 'Dunlop', '2007-01-03', '2014-07-29', 'bdunlop6q@trellian.com', '+63 (572) 762-4068'),
       ('Teri', 'Hadye', '1998-06-07', '2014-11-10', 'thadye6r@newsvine.com', '+382 (363) 466-6193'),
       ('Corrianne', 'Brundale', '1969-10-08', '2015-09-30', NULL, '+62 (757) 138-5168'),
       ('Oralia', 'Ourry', '2000-11-10', '2018-11-19', 'oourry6t@phoca.cz', '+850 (502) 613-4215'),
       ('Erna', 'Dunnion', '1968-03-27', '2019-01-20', 'edunnion6u@phoca.cz', '+351 (304) 900-6745'),
       ('Marlo', 'Tweed', '1995-07-26', '2014-09-27', 'mtweed6v@shinystat.com', '+86 (601) 983-5578'),
       ('Simeon', 'Dagg', '1982-07-06', '2019-11-22', 'sdagg6w@mayoclinic.com', '+84 (704) 516-9725'),
       ('Amos', 'Tatlow', '2007-04-02', '2022-08-02', 'atatlow6x@sina.com.cn', '+51 (742) 588-2973'),
       ('Israel', 'Rosell', '1965-10-20', '2023-04-23', NULL, '+420 (948) 490-9657'),
       ('William', 'Matyushkin', '1988-03-02', '2018-11-13', 'wmatyushkin6z@theguardian.com', '+51 (322) 405-2911'),
       ('Ivett', 'Sprason', '1999-03-05', '2022-01-10', 'isprason70@liveinternet.ru', '+7 (402) 316-0033'),
       ('Everett', 'Shoebrook', '2006-08-11', '2014-08-04', 'eshoebrook71@de.vu', '+86 (964) 288-7171'),
       ('Talya', 'Puve', '1975-12-01', '2022-07-06', NULL, '+51 (957) 413-0481'),
       ('Danny', 'Davydychev', '1961-07-27', '2014-01-08', 'ddavydychev73@google.cn', '+94 (164) 521-7669'),
       ('Nickolaus', 'MacMenamy', '1995-10-15', '2014-07-21', 'nmacmenamy74@feedburner.com', '+86 (678) 281-1084'),
       ('Benedicto', 'Fosher', '2001-03-12', '2014-09-08', NULL, '+358 (987) 153-7532'),
       ('Robbi', 'Cummings', NULL, '2020-03-28', 'rcummings76@independent.co.uk', '+49 (685) 786-3717'),
       ('Sileas', 'Melby', NULL, '2015-08-28', 'smelby77@jalbum.net', '+86 (446) 655-3470'),
       ('Peterus', 'Truin', '1971-05-22', '2022-02-26', NULL, '+33 (327) 805-1273'),
       ('Bianca', 'Krelle', '1989-03-22', '2022-09-26', 'bkrelle79@pcworld.com', '+52 (133) 639-2106'),
       ('Heather', 'Pincked', NULL, '2019-10-23', NULL, '+86 (261) 473-3990'),
       ('Paola', 'Siemons', NULL, '2016-10-06', 'psiemons7b@printfriendly.com', '+86 (934) 175-5952'),
       ('Marya', 'Neiland', '2013-01-30', '2023-05-23', NULL, '+66 (998) 709-2547'),
       ('Anselma', 'Bonifant', '2012-11-15', '2023-05-16', NULL, '+55 (436) 924-4731'),
       ('Natalie', 'Bowles', '1989-11-16', '2016-10-07', NULL, '+55 (930) 101-9498'),
       ('Marina', 'Keeney', '1972-04-23', '2021-12-26', 'mkeeney7f@economist.com', '+372 (361) 425-7922'),
       ('Kikelia', 'Gammie', '2003-07-08', '2019-08-07', NULL, '+355 (840) 912-6307'),
       ('Tandi', 'Flores', NULL, '2020-04-02', 'tflores7h@infoseek.co.jp', '+374 (157) 165-5913'),
       ('Saundra', 'Hanlin', '1965-12-07', '2019-11-23', 'shanlin7i@yahoo.co.jp', '+1 (839) 368-0852'),
       ('Esmaria', 'Spriggs', '1991-08-31', '2014-01-26', 'espriggs7j@smugmug.com', '+86 (154) 279-2788'),
       ('Rahel', 'Simmers', '1965-02-15', '2022-10-24', 'rsimmers7k@spiegel.de', '+63 (372) 730-1853'),
       ('Tabbatha', 'Huison', NULL, '2021-03-03', 'thuison7l@gnu.org', '+995 (351) 919-5990'),
       ('Alexis', 'Fairweather', '1980-11-20', '2023-04-28', 'afairweather7m@over-blog.com', '+234 (646) 294-8894'),
       ('Tucky', 'Tredgold', NULL, '2019-01-06', 'ttredgold7n@g.co', '+351 (787) 962-2584'),
       ('Nona', 'Barrat', '1975-08-23', '2015-07-27', NULL, '+374 (665) 429-1425'),
       ('Peirce', 'Oldnall', '1986-04-22', '2019-09-03', 'poldnall7p@ed.gov', '+62 (595) 782-2419'),
       ('Kora', 'Sherewood', '1991-01-14', '2015-12-01', 'ksherewood7q@admin.ch', '+48 (109) 614-2509'),
       ('Bing', 'Garett', '1986-11-06', '2022-11-15', NULL, '+58 (572) 262-7750'),
       ('Spike', 'McDougle', NULL, '2016-08-28', NULL, '+380 (414) 175-9961'),
       ('Katrina', 'Danilchenko', NULL, '2017-06-18', 'kdanilchenko7t@answers.com', '+7 (313) 123-8343'),
       ('Melitta', 'Benedidick', '1973-12-22', '2019-04-15', 'mbenedidick7u@rambler.ru', '+55 (555) 793-4585'),
       ('Adolpho', 'Volker', '1986-06-06', '2019-12-20', 'avolker7v@hugedomains.com', '+351 (395) 633-2015'),
       ('Felecia', 'Hankins', NULL, '2020-05-18', NULL, '+351 (466) 880-8046'),
       ('Gerrard', 'Mosten', NULL, '2017-10-14', 'gmosten7x@ucsd.edu', '+86 (863) 236-5502'),
       ('Wildon', 'Deary', '2009-06-17', '2022-01-31', 'wdeary7y@theguardian.com', '+375 (101) 456-7448'),
       ('Wendeline', 'Ollington', '1976-09-28', '2018-06-18', NULL, '+27 (702) 229-6418'),
       ('Wilfred', 'de Najera', '2009-06-01', '2022-09-26', 'wdenajera80@drupal.org', '+55 (581) 492-4220'),
       ('Tobias', 'Thrasher', '2004-10-22', '2016-02-01', NULL, '+261 (986) 697-9851'),
       ('Ramon', 'Iltchev', '1987-07-12', '2015-01-22', 'riltchev82@google.ru', '+387 (378) 873-3693'),
       ('Patton', 'Amerighi', '2006-12-19', '2020-04-29', NULL, '+261 (418) 166-1324'),
       ('Laurie', 'Broad', '1977-04-21', '2015-08-28', NULL, '+7 (476) 234-9720'),
       ('Valeda', 'Shafto', '1996-06-09', '2014-09-12', 'vshafto85@yahoo.co.jp', '+86 (878) 166-4119'),
       ('Orelie', 'Jolliffe', '1979-11-14', '2023-06-14', 'ojolliffe86@fema.gov', '+86 (775) 732-3530'),
       ('Horton', 'Calbaithe', NULL, '2021-03-07', NULL, '+58 (676) 651-8723'),
       ('Lyman', 'Accomb', NULL, '2016-03-03', NULL, '+51 (184) 651-7407'),
       ('Gibbie', 'Bloor', '1970-05-22', '2023-02-09', 'gbloor89@oaic.gov.au', '+63 (720) 628-9525'),
       ('Clerkclaude', 'Getten', '1966-08-11', '2017-07-07', 'cgetten8a@gravatar.com', '+63 (437) 311-9629'),
       ('Emilio', 'Vasyutochkin', NULL, '2014-02-12', 'evasyutochkin8b@apple.com', '+86 (925) 481-2112'),
       ('Alice', 'Emmott', '1982-05-10', '2020-04-07', 'aemmott8c@tuttocitta.it', '+51 (178) 584-8684'),
       ('Bone', 'Shute', '1969-05-12', '2016-12-15', 'bshute8d@google.fr', '+86 (588) 477-6130'),
       ('Jimmie', 'Lonergan', '1993-04-28', '2022-02-07', 'jlonergan8e@163.com', '+57 (832) 120-8820'),
       ('Isador', 'Meah', '2008-11-13', '2020-11-30', 'imeah8f@google.fr', '+86 (866) 962-7818'),
       ('Finn', 'Paal', '1995-10-05', '2023-06-16', NULL, '+33 (270) 931-1926'),
       ('Hadlee', 'Suffield', '1973-10-19', '2018-05-19', 'hsuffield8h@discuz.net', '+62 (277) 856-5533'),
       ('Bob', 'Farlambe', '2004-01-03', '2014-03-25', 'bfarlambe8i@chron.com', '+998 (982) 827-9604'),
       ('Noam', 'Loverock', '1995-12-14', '2023-03-09', 'nloverock8j@nymag.com', '+351 (338) 273-0636'),
       ('Barclay', 'Goodred', '1982-10-08', '2017-11-23', NULL, '+86 (592) 908-1589'),
       ('Allister', 'Manuello', '2011-01-18', '2019-12-21', NULL, '+1 (569) 415-0047'),
       ('Ilario', 'Spall', '2001-09-20', '2017-05-12', 'ispall8m@weather.com', '+54 (278) 562-2094'),
       ('Amabelle', 'Jamrowicz', '1997-08-21', '2020-04-26', 'ajamrowicz8n@wsj.com', '+380 (640) 761-0287'),
       ('Kimmy', 'Booy', '1962-11-11', '2015-03-02', 'kbooy8o@fotki.com', '+86 (927) 858-1399'),
       ('Christy', 'Bouette', '1997-08-23', '2023-05-23', 'cbouette8p@furl.net', '+351 (390) 654-6864'),
       ('Swen', 'Jacobowicz', NULL, '2020-09-24', 'sjacobowicz8q@berkeley.edu', '+66 (906) 205-5836'),
       ('Maisie', 'Johns', '1983-02-05', '2019-08-15', NULL, '+48 (393) 577-6741'),
       ('Torrence', 'Beedie', NULL, '2014-09-05', NULL, '+30 (335) 910-9066'),
       ('Kendrick', 'Plummer', '1998-08-18', '2021-01-15', NULL, '+63 (222) 870-0308'),
       ('Daron', 'Byrne', '1998-07-20', '2021-01-29', NULL, '+256 (188) 664-1802'),
       ('Tessie', 'Laird', NULL, '2016-10-29', 'tlaird8v@artisteer.com', '+351 (101) 189-8485'),
       ('Dolli', 'Noweak', '1965-06-29', '2018-08-16', NULL, '+880 (706) 648-3116'),
       ('Etienne', 'Kleinhaut', '1989-06-01', '2020-07-17', 'ekleinhaut8x@admin.ch', '+966 (420) 812-5828'),
       ('Latisha', 'Uphill', '2002-11-17', '2022-06-29', 'luphill8y@merriam-webster.com', '+55 (315) 408-7774'),
       ('Bard', 'Lempel', '1988-01-23', '2021-02-07', 'blempel8z@paypal.com', '+7 (416) 250-8699'),
       ('Adda', 'Hanhart', NULL, '2021-09-22', NULL, '+976 (781) 785-4627'),
       ('Milly', 'Gagg', '1976-09-28', '2015-06-11', NULL, '+963 (602) 531-2459'),
       ('Caprice', 'Mordacai', '1959-01-26', '2015-12-06', 'cmordacai92@youku.com', '+86 (522) 628-8585'),
       ('Alla', 'Chatell', '1968-03-11', '2017-10-06', 'achatell93@ebay.co.uk', '+1 (518) 538-3203'),
       ('Silvano', 'Crockley', '2000-10-22', '2017-03-23', NULL, '+1 (405) 823-8001'),
       ('Thatcher', 'Cochet', '1992-06-07', '2014-08-18', 'tcochet95@epa.gov', '+63 (556) 197-8353'),
       ('Zeke', 'Twelvetrees', '2013-10-30', '2014-12-07', 'ztwelvetrees96@biblegateway.com', '+86 (738) 519-7126'),
       ('Joline', 'Bosdet', NULL, '2014-09-26', 'jbosdet97@spotify.com', '+39 (611) 954-7052'),
       ('Tami', 'Hutfield', '1979-12-22', '2014-08-31', 'thutfield98@free.fr', '+351 (240) 283-5274'),
       ('Pren', 'Kennally', NULL, '2023-07-14', NULL, '+47 (292) 601-3470'),
       ('Gerhardt', 'Bezarra', NULL, '2019-03-24', 'gbezarra9a@prweb.com', '+48 (359) 197-1365'),
       ('Stearn', 'Tomasian', '1977-04-21', '2016-03-26', 'stomasian9b@sina.com.cn', '+55 (793) 560-9263'),
       ('Mahalia', 'Osler', '1975-01-01', '2016-04-08', 'mosler9c@networkadvertising.org', '+593 (231) 644-0703'),
       ('Odelle', 'Smieton', '2003-05-29', '2017-07-07', 'osmieton9d@flickr.com', '+81 (800) 486-3304'),
       ('Pattie', 'Duffin', '1994-01-18', '2014-09-06', 'pduffin9e@g.co', '+92 (289) 720-2687'),
       ('Berne', 'Davidow', '1966-02-03', '2017-09-12', 'bdavidow9f@washington.edu', '+86 (612) 201-9964'),
       ('Dennis', 'Whitton', '1987-05-30', '2016-09-04', 'dwhitton9g@newsvine.com', '+86 (943) 471-6254'),
       ('Celene', 'Esposita', '1978-08-19', '2019-01-17', NULL, '+84 (418) 820-0955'),
       ('Yuma', 'Welden', NULL, '2016-12-01', NULL, '+1 (214) 252-7281'),
       ('Lindi', 'Narducci', '1971-03-25', '2018-10-05', 'lnarducci9j@pagesperso-orange.fr', '+509 (956) 772-4384'),
       ('Agatha', 'Neal', '1976-10-20', '2016-08-17', 'aneal9k@mozilla.com', '+30 (899) 440-5155');
