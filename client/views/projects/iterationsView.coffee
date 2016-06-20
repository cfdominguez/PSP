##########################################
Template.iterationsViewTemplate.onCreated () ->
	Meteor.subscribe "allProjects"


Template.iterationsViewTemplate.helpers
	selectedProject: () ->
		return db.projects.findOne({_id: FlowRouter.getParam("fid")})

	projectIterations: () ->
		return db.projects.find({parentId: FlowRouter.getParam("fid")}).fetch()


Template.iterationsViewTemplate.events
	'click .submenu-create': (e,t) ->
		data = {
			title: "Nueva iteración"
			description: "Descripción de esta nueva iteración"
			levelPSP: "PSP 0"
			parentId: FlowRouter.getParam("fid")
		}

		Meteor.call "create_project", data, (error, result) ->
			if error
				console.log "Error creating a new project iteration"
			else
				Meteor.call "create_plan_summary", Meteor.userId(), result, data.levelPSP, (error) ->
					if error
						console.log "Error creating new projects iteration Plan Summary"
					else
						console.log "Plan summary of iteration created successfully!"

	'click .submenu-go-back': (e,t) ->
		FlowRouter.go("/")

##########################################
Template.projectIterationBox.events
	'click .project-delete': (e,t) ->
		Meteor.call "delete_project", @_id, (error) ->
			if error
				console.log "Error deleting a iteration of a project"
			else
				#sys.flashSuccess()

##########################################