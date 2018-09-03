-- Language needs to be loaded into the database before creating this function with plpythonu
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
