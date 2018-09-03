CREATE OR REPLACE FUNCTION relate_line(geom1 geometry, geom2 geometry) RETURNS text AS $$
DECLARE 
	r text;
	rs text;
	re text;
	rb text;
	t text;
	row text;
	rsa text[];
	rea text[];

	sp geometry;
	ep geometry;
BEGIN
	sp = st_startpoint(geom1);
	ep = st_endpoint(geom1);
	rs = relate_simple(sp, geom2);
	rs = left(rs, 3);
	rs = translate(rs, 'T', 'S');
	re = relate_simple(ep, geom2);
	re = left(re, 3);
	re = translate(re, 'T', 'E');

	rsa = regexp_split_to_array(rs, '');
	rea = regexp_split_to_array(re, '');

	row = '';

	FOR i IN 1..3 LOOP
		t = rsa[i] || rea[i];

		CASE
			WHEN t LIKE 'FF' THEN t = 'F';
			WHEN t LIKE '%F%' THEN t = REPLACE(t,'F','');
			ELSE t = 'B';
		END CASE;

		row = row || t;
	END LOOP;

    r = relate_simple(geom1, geom2);
    r = overlay(r placing row from 4 for 3);
    RETURN r;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;
