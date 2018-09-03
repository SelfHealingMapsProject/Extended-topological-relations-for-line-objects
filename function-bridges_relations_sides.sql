-- I have to load language into the database before I can create this function with plpythonu
-- create language plpythonu;

CREATE OR REPLACE FUNCTION bridge_relations_sides(relations text[]) RETURNS text[] AS $$
from string import maketrans
result = []
for relation in relations:
    if 'S' in relation and 'E' in relation:
        reverse = relation.translate(maketrans('SE', 'ES'))
        if reverse in relations:        
            result.append(relation.translate(maketrans('ES', 'TT')) + '-both')
            relations.pop(relations.index(reverse))
        else:
            result.append(relation.translate(maketrans('ES', 'TT')) + '-single')
    else:
        result.append(relation)
return result
$$
STRICT
LANGUAGE plpythonu IMMUTABLE;


-- fixing the same relation occuring twice if it's a relation for the both sides
SELECT bridge_id, array_agg(distinct relation_gtype) as relations, bridge_relations_sides(array_agg(distinct relation_gtype)) FROM bridges_topo_line_relate WHERE bridge_id=4080216 GROUP BY bridge_id ORDER BY bridge_id ASC;

--  bridge_id |                            relations                             |                           bridge_relations_sides                           
-- -----------+------------------------------------------------------------------+----------------------------------------------------------------------------
--    4080216 | {FFTFESTTT-linestring,FFTFSETTT-linestring,TFTFFBTTT-linestring} | {FFTFTTTTT-linestring-both,FFTFTTTTT-linestring-both,TFTFFBTTT-linestring}

-- Possible solution may be to count the steps in for loop and blacklist the index of a reverse relation when it's found; and afterwards skip it when doing further steps in the for loop.

-- getting the lenght of an array
select array_length(array[1,2,3,4,5],1);

-- There are no functions with wich I can make sure that there are no duplicate relations after counting sides. Present this problem to supervisors in the progress meeting and continue using DBSCAN with just regular DE-9IM relations.


-- WORKING WITH PYTHON SCRIPTING HERE
------------------------------------------------------------------------
-- I'm going to try and find myself an example where the most 'both' relations occur so that I can test my python script on it before I integrate it here

-- There's no table where I have calculated them and saved them in a new table. I have probably only created these 'both' relations when I needed to build them for the experiments on frequent itemsets in Orange.




-- OLD FUNCTION WRITTEN IN PQPLSQL
-- CREATE OR REPLACE FUNCTION bridge_relations_sides(relations text[]) RETURNS text[] AS $$
-- DECLARE
-- 	relation text;
-- 	reverse text;
-- 	both text;
-- 	result text[];

-- BEGIN
-- 	RAISE NOTICE 'STARTING WITH RELATIONS %', relations;
-- 	FOREACH relation IN ARRAY relations
-- 	LOOP
-- 		RAISE NOTICE 'STARTING TO PROCESS %', relation;
-- 		IF relation LIKE '%S%' AND relation LIKE '%E%'
-- 			THEN
-- 				RAISE NOTICE 'RELATION % CONTAINS "E" & "S"', relation;
-- 				reverse = translate(relation, 'ES', 'SE');
-- 				IF reverse = ANY(relations)
-- 					THEN
-- 						RAISE NOTICE 'REVERSE RELATION % FOUND, COUNT AS "BOTH" SIDES', reverse;
-- 						-- relations = array_remove(relations, reverse);
-- 						result = array_append(result, (translate(relation, 'ES', 'TT') || '-both'));
-- 					ELSE
-- 						RAISE NOTICE 'REVERSE RELATION NOT FOUND, COUNT AS "SINGLE" SIDES';
-- 						result = array_append(result, (translate(relation, 'ES', 'TT') || '-single'));
-- 				END IF;
-- 			ELSE
-- 				result = array_append(result, relation);
-- 		END IF;
-- 	END LOOP;

-- 	RETURN result;

-- END;
-- $$
-- STRICT
-- LANGUAGE plpgsql IMMUTABLE;
