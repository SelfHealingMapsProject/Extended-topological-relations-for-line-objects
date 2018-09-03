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

-- when changing return type, first drop the function
DROP FUNCTION isnumeric(text);

SELECT '1.2333333333333333333333333333333333333333333333'::real;
SELECT 'numeric'::varchar(7);
SELECT isnumeric('2');

SELECT replace(replace(replace('F101F1012', '1', 'T'), '2', 'T'), '0', 'T');
SELECT translate('F101F1012', '012', 'TTT');

SELECT relate_simple(a.geom, b.geom) FROM victoria_ways a, victoria_ways b WHERE NOT st_disjoint(a.geom, b.geom) LIMIT 10;


SELECT regexp_split_to_array('TFT','');


DO
$$
BEGIN
 FOR i IN 1..10 LOOP
       RAISE NOTICE '%', i; -- i will take on the values 1,2,3,4,5,6,7,8,9,10 within the loop
 END LOOP;
END
$$

DO
$$
DECLARE 
	rsa text[];
	rea text[];
	t text;
	row text;
BEGIN
	rsa = regexp_split_to_array('SFF', '');
	rea = regexp_split_to_array('FFE', '');
	RAISE NOTICE '%', rsa;
	RAISE NOTICE '%', rea;
	row = '';
	FOR i IN 1..3 LOOP
		t = rsa[i] || rea[i];
		CASE
			WHEN t LIKE 'FF' THEN t = 'F';
			WHEN t LIKE '%F%' THEN t = REPLACE(t,'F','');
			ELSE t = 'B';
		END CASE;
		row = row || t;
		RAISE NOTICE '%', row;
	END LOOP;
END
$$

select ('i'||'t') like 'it';

SELECT overlay('TFTFFFTFT' placing 'BBB' from 4 for 3);