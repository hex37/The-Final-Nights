/datum/db/roleplay_management

/datum/db/roleplay_management/proc/DB_Query(sql, list/params)
	if (!SSdbcore) return null
	var/datum/db_query/Q = SSdbcore.NewQuery(sql, params)
	if (!Q) return null
	if (!Q.Execute())
		qdel(Q)
		return null
	return Q

/datum/db/roleplay_management/proc/DB_FetchOne(sql, list/params)
	var/datum/db_query/Q = DB_Query(sql, params)
	if (!Q) return null
	if (!Q.NextRow())
		qdel(Q)
		return null
	var/list/row = Q.item
	qdel(Q)
	return row

/datum/db/roleplay_management/proc/DB_FetchAll(sql, list/params)
	var/datum/db_query/Q = DB_Query(sql, params)
	if (!Q) return list()
	var/list/out = list()
	while (Q.NextRow())
		out += list(Q.item)
	qdel(Q)
	return out

/datum/db/roleplay_management/proc/DB_Exec(sql, list/params)
	var/datum/db_query/Q = DB_Query(sql, params)
	if (!Q) return list("ok"=FALSE, "rows"=0, "last_id"=null)
	var/rows = Q.affected
	var/last_id = Q.last_insert_id
	qdel(Q)
	return list("ok"=TRUE, "rows"=rows, "last_id"=last_id)
