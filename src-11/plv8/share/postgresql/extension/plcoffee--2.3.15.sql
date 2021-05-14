






CREATE FUNCTION plcoffee_call_handler() RETURNS language_handler
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plcoffee_inline_handler(internal) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plcoffee_call_validator(oid) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;

CREATE TRUSTED LANGUAGE plcoffee
 HANDLER plcoffee_call_handler

 INLINE plcoffee_inline_handler

 VALIDATOR plcoffee_call_validator;
