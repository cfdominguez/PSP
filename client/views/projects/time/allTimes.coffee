##########################################
Template.timeTemplate.helpers
	projectStages:() ->
		pid = FlowRouter.getParam("id")
		planSummary = db.plan_summary.findOne({"projectId": pid, "summaryOwner": Meteor.userId()})

		if planSummary
			return planSummary.timeEstimated

##########################################
Template.timesBar.onCreated () ->
	@projectStages = new ReactiveVar([])
	@timeStatus = new ReactiveVar(false)
	@timeStarted = new ReactiveVar(0)


Template.timesBar.helpers
	dropdownStages:() ->
		pid = FlowRouter.getParam("id")
		planSummary = db.plan_summary.findOne({"projectId": pid, "summaryOwner": Meteor.userId()})
		if planSummary
			ProjectStages = _.filter planSummary.timeEstimated, (stage) ->
				if !stage.finished
					stage
			Template.instance().projectStages.set(ProjectStages)

		return Template.instance().projectStages.get()

	timeStatus:() ->
		return Template.instance().timeStatus.get()

	currentStage: () ->
		return _.first Template.instance().projectStages.get()

	EmptyStage: () ->
		Stages = Template.instance().projectStages.get()
		return Stages.length == 0

	# timeFormat: (time) ->
	# 	return sys.displayTime(time)


Template.timesBar.events
	'click .fa-play': (e,t) ->
		t.timeStarted.set(new Date())
		t.timeStatus.set(true)

	'click .fa-pause': (e,t) ->
		TimeStarted = t.timeStarted.get()
		Stages = t.projectStages.get()

		unless TimeStarted == 0
			totalTime = new Date() - TimeStarted
			stage = _.first Stages
			stage.time = parseInt(totalTime)

			Meteor.call "update_time_stage", FlowRouter.getParam("id"), stage, (err) ->
				if err
					sys.flashError()
					console.log "Error updating project phase"
					console.warn(error)
				else
					t.timeStarted.set(0)
					t.timeStatus.set(false)


	'click .time-submit': (e,t) ->
		TimeStarted = Template.instance().timeStarted.get()
		Stages = Template.instance().projectStages.get()
		if TimeStarted != 0
			totalTime = new Date() - TimeStarted
		else
			totalTime = 0

		stage = _.first Stages
		stage.time = parseInt(totalTime)
		Meteor.call "update_time_stage", FlowRouter.getParam("id"), stage, true, (error) ->
			if error
				sys.flashError()
				console.log "Error submitting phase time inside project"
				console.warn(error)
			else
				#Probar cambiar _.first Stages por stage (esta definido 8 lineas arriba)
				t.projectStages.set( _.without Stages, _.first Stages)
				t.timeStarted.set(0)
				t.timeStatus.set(false)

##########################################