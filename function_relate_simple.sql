CREATE OR REPLACE FUNCTION relate_simple(geom1 geometry, geom2 geometry) RETURNS text AS $$
DECLARE r text;
BEGIN
    r = st_relate(geom1, geom2);
    r = translate(r, '012', 'TTT');
    RETURN r;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;
