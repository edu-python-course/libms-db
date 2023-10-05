/**
  Initialize maintenance role and a library database
 */

-- create database maintenance role
CREATE ROLE libms WITH ENCRYPTED PASSWORD 'password' LOGIN;
COMMENT ON ROLE libms IS 'library database owner and maintenance role';

-- grant server files access
GRANT pg_read_server_files TO libms;

-- create library database
CREATE DATABASE libms OWNER libms;
COMMENT ON DATABASE libms IS 'library database';
