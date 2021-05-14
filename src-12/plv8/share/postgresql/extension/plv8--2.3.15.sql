






CREATE FUNCTION plv8_call_handler() RETURNS language_handler
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plv8_inline_handler(internal) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;


CREATE FUNCTION plv8_call_validator(oid) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;

CREATE TRUSTED LANGUAGE plv8
 HANDLER plv8_call_handler

 INLINE plv8_inline_handler

 VALIDATOR plv8_call_validator;


CREATE DOMAIN plv8_int2array AS int2[];
CREATE DOMAIN plv8_int4array AS int4[];
CREATE DOMAIN plv8_float4array AS float4[];
CREATE DOMAIN plv8_float8array AS float8[];

CREATE OR REPLACE FUNCTION plv8_version ( )
RETURNS TEXT AS
$$
 return "2.3.15";
$$ LANGUAGE plv8;
