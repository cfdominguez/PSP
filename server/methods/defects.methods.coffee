##########################################
Meteor.methods
	create_defect: (uid, pid, date, Defect, time) ->
		if date?
			date = new Date()

		db.defects.insert({
			"defectOwner": uid
			"projectId": pid
			"createdAt": date
			"typeDefect": Defect.typeDefect
			"injected": Defect.injected
			"removed": Defect.removed
			"fixCount": Defect.fixCount
			"description": Defect.description
			"time": time
			"parentId": Defect.parentId
		})

	update_defect: (did, uid, pid, date, Defect, time) ->

		defect = db.defects.findOne({_id: did}).time
		time = defect + time

		if date?
			date = new Date()

		db.defects.update({_id: did}, {$set: {
			"defectOwner": uid
			"projectId": pid
			"date": date
			"typeDefect": Defect.typeDefect
			"injected": Defect.injected
			"removed": Defect.removed
			"fixCount": Defect.fixCount
			"description": Defect.description
			"lastModified": new Date()
			"time": time
			"parentId": Defect.parentId
		}})

##########################################