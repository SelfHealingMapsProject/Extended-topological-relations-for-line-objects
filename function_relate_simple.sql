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




SELECT replace(replace(replace('F101F1012', '1', 'T'), '2', 'T'), '0', 'T');
SELECT translate('F101F1012', '012', 'TTT');

SELECT relate_simple(a.geom, b.geom) FROM victoria_ways a, victoria_ways b WHERE NOT st_disjoint(a.geom, b.geom) LIMIT 10;