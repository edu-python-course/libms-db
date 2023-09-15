/**
  Initialize maintenance role and a library database
 */

-- create database maintenance role
CREATE ROLE libms WITH ENCRYPTED PASSWORD 'password' LOGIN;
COMMENT ON ROLE libms IS 'library database owner and maintenance role';

-- create library database
CREATE DATABASE libms OWNER libms;
COMMENT ON DATABASE libms IS 'library database';
