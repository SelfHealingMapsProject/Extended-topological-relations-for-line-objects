# Extended topological relations for line objects

This repository contains SQL functions which enable the extended topological relations for line objects to be computed. These relations extend on the 9 Intersection Model (9IM) in order to show if the relations of the line object with other objects are symmetrical (i.e. present on both sides) or not.

## Examples

All the examples below show how the functions for the extended topological relations work on a simple scenario with bridge that crosses a river and is connected to roads on both sides.

![example scenario of a bridge](https://github.com/SelfHealingMapsProject/Extended-topological-relations-for-line-objects/blob/master/example_bridge.png "example scenario of a bridge")

### Function [`relate_simple`][relate_simple_link]

Function `relate_simple` transforms the result of the PostGIS function [`ST_Relate`](https://postgis.net/docs/ST_Relate.html) from the Dimensionally Extended 9 Intersection Model (DE-9IM) into the 9IM.

```sql
SELECT relate_simple(st_geomfromtext('LINESTRING(3 2, 5 2)'), geom), object_class
FROM (VALUES 
		(st_geomfromtext('LINESTRING(0 2, 3 2)'), 'road1'),
		(st_geomfromtext('LINESTRING(5 2, 7 4)'), 'road2'),
		(st_geomfromtext('LINESTRING(5 2, 7 0)'), 'road3'),
		(st_geomfromtext('LINESTRING(4 4, 4 0)'), 'river')
	) AS v (geom, object_class);
```
 relate_simple | object_class 
:-------------:|:------------:
 FFTFTTTTT     | road1
 FFTFTTTTT     | road2
 FFTFTTTTT     | road3
 TFTFFTTTT     | river

### Function [`relate_line`][relate_line_link]

Function ['relate_line'][relate_line_link] looks at the topological relations that a given line object has with other objects, and determines if they are related to its start point, to its end point, or both.

```sql
SELECT relate_line(st_geomfromtext('LINESTRING(3 2, 5 2)'), geom), object_class
FROM (VALUES 
		(st_geomfromtext('LINESTRING(0 2, 3 2)'), 'road1'),
		(st_geomfromtext('LINESTRING(5 2, 7 4)'), 'road2'),
		(st_geomfromtext('LINESTRING(5 2, 7 0)'), 'road3'),
		(st_geomfromtext('LINESTRING(4 4, 4 0)'), 'river')
	) AS v (geom, object_class);
```
 relate_line | object_class 
:-------------:|:------------:
 FFTFSETTT   | road1
 FFTFESTTT   | road2
 FFTFESTTT   | road3
 TFTFFBTTT   | river

### Function [`bridge_relations_sides`][bridge_relations_sides_link]

Function [`bridge_relations_sides`][bridge_relations_sides_link] then determines if the relations are present on the both sides of the given line object or not. If the relation is present on both sides, it gets the appendix 'both', and if it is present only on one side of the given line object it gets the appendix 'single'.

The first SQL example shows how the topological relations of a single line object need to be arranged for input in the `bridge_relations_sides` function.

```sql
SELECT array_agg(relate_line(st_geomfromtext('LINESTRING(3 2, 5 2)'), geom))
FROM (VALUES 
		(st_geomfromtext('LINESTRING(0 2, 3 2)'), 'road1'),
		(st_geomfromtext('LINESTRING(5 2, 7 4)'), 'road2'),
		(st_geomfromtext('LINESTRING(5 2, 7 0)'), 'road3'),
		(st_geomfromtext('LINESTRING(4 4, 4 0)'), 'river')
	) AS v (geom, object_class);
```
|                 array_agg                 |
|:-----------------------------------------:|
| {FFTFSETTT,FFTFESTTT,FFTFESTTT,TFTFFBTTT} |

```sql
WITH rels AS (SELECT array_agg(relate_line(st_geomfromtext('LINESTRING(3 2, 5 2)'), geom)) AS relations
FROM (VALUES 
		(st_geomfromtext('LINESTRING(0 2, 3 2)'), 'road1'),
		(st_geomfromtext('LINESTRING(5 2, 7 4)'), 'road2'),
		(st_geomfromtext('LINESTRING(5 2, 7 0)'), 'road3'),
		(st_geomfromtext('LINESTRING(4 4, 4 0)'), 'river')
		) AS v (geom, object_class))
SELECT bridge_relations_sides(relations) FROM rels;
```
|           bridge_relations_sides            |
|:-------------------------------------------:|
| {FFTFTTTTT-both,FFTFTTTTT-single,TFTFFBTTT} |

[relate_simple_link]: https://github.com/SelfHealingMapsProject/Extended-topological-relations-for-line-objects/blob/master/function_relate_simple.sql
[relate_line_link]: https://github.com/SelfHealingMapsProject/Extended-topological-relations-for-line-objects/blob/master/function_relate_line.sql
[bridge_relations_sides_link]: https://github.com/SelfHealingMapsProject/Extended-topological-relations-for-line-objects/blob/master/function-bridges_relations_sides.sql
