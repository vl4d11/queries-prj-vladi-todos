
select object_name(t.parent_object_id) tabla, col_name(tt.object_id, tt.column_id) campo
from sys.key_constraints t cross apply sys.index_columns tt
where t.type = 'uq'
and t.unique_index_id = tt.index_id
and t.parent_object_id = tt.object_id
and t.parent_object_id = object_id('RH50_DesigEvaluados_CAB')
order by tt.key_ordinal
