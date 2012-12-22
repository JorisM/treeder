if Meteor.isClient
	Template.hello.greeting = ->
		"Welcome to treeder."

	Template.hello.events "click input": ->
		# template data, if any, is available in 'this'
		console.log "You pressed the buftton"  if typeof console isnt "undefined"

	arr = [1,2,3,6,5];
	_.each arr, (item) ->
		console.log item







if Meteor.isServer
	Meteor.startup ->
