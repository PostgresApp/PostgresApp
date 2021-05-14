






CREATE FUNCTION plls_call_handler() RETURNS language_handler
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plls_inline_handler(internal) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plls_call_validator(oid) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;

CREATE TRUSTED LANGUAGE plls
 HANDLER plls_call_handler

 INLINE plls_inline_handler

 VALIDATOR plls_call_validator;
