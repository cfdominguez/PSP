##########################################
if Meteor.isServer
	syssrv.deleteProject = (pid) ->
		# This removes the time information of this project from
		# The users complete data recolection.
		user = db.users.findOne({_id: Meteor.userId()}).profile
		planSummary = db.plan_summary.findOne({"summaryOwner": Meteor.userId(), "projectId": pid})
		amountDefects = db.defects.find({'projectId': pid}).count()

		if db.projects.findOne({_id: pid})?.completed
			# This takes The user general data and removes this projects
			# time recolected information.
			finalTime = _.filter user.summaryAmount, (time) ->
				planTime = _.findWhere planSummary.timeEstimated, {name: time.name}
				planInjected = _.findWhere planSummary.injectedEstimated, {name: time.name}
				planRemoved = _.findWhere planSummary.removedEstimated, {name: time.name}

				time.time -= planTime.time
				time.injected -= planInjected.injected
				time.removed -= planRemoved.removed
				return time

			data = {
				"profile.total.time": user.total.time - planSummary.total.totalTime
				"profile.total.injected": user.total.injected - amountDefects
				"profile.total.removed": user.total.removed - amountDefects
				"profile.summaryAmount": finalTime
			}
			db.users.update({_id: Meteor.userId()}, {$set: data})

		db.projects.remove({ _id: pid })
		db.defects.remove({ "projectId": pid })
		db.plan_summary.remove({ "projectId": pid })



	syssrv.createProject = (data) ->
		amountProjects = db.projects.find({"projectOwner": Meteor.userId()}).count()
		data.color = sys.selectColor(amountProjects)
		data.projectOwner =  Meteor.userId()

		projectId = db.projects.insert(data)
		syssrv.createPlanSummary(Meteor.userId(), projectId, data.levelPSP)


##########################################