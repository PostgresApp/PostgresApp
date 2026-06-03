-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION pljs UPDATE TO '1.0.1'" to load this file. \quit

CREATE OR REPLACE FUNCTION pljs_version()
 RETURNS TEXT
 AS 'MODULE_PATHNAME', 'pljs_version'
 LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION pljs_info() RETURNS JSON
 AS 'MODULE_PATHNAME', 'pljs_info'
 LANGUAGE C;

 REVOKE ALL ON FUNCTION pljs_info() FROM PUBLIC;
