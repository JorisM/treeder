@tree = new Meteor.Collection("tree")
@trees = new Meteor.Collection("trees")
@levels = new Meteor.Collection("levels")
@level = {}
@levelHeight = 80
@nodeHeight = 50
@nodeSpacing = 0
@correction = 0

if Meteor.isClient
	Meteor.startup ->
		@levels.remove({})
		@container = $('#node-container')
		this.parse()


	log2 = (val) ->
		return Math.ceil(Math.log(val) / Math.LN2)

	Template.main.height = ->
		Session.get 'height'

	Template.main.levels = ->
		@levels.find({})

	Template.node.isNull = (data) ->
		data == "null"


	parse = ->
		# template data, if any, is available in 'this'
		array = [ {'data': 2}, {'data': 1}, {'data': 5}, {'data': null}, {'data': null}, {'data': 3}, {'data': 6}, {'data': null}, {'data': null}, {'data':null}, {'data': null}, {'data': null}, {'data': 4}, {'data': null}, {'data': null}]

		height = log2(array.length + 1)

		Session.set 'height', height
		maxNodesLevel = 1
		levelCounter = 1
		currentPerLevel = 0
		@level.nodes = []
		@container.width(0)
		#if the container is too small, make it bigger
		if (@container.width() - ((2 * height)) * (@nodeHeight + @nodeSpacing)) < 0
			@container.width((2 * height) * (@nodeHeight + @nodeSpacing))
			console.log 'needed to resize'
			console.log((2 * height) * (@nodeHeight))

		_.each array, (item) ->
			if maxNodesLevel >= currentPerLevel
				if maxNodesLevel is 1
					item.xAxis = @container.width() / 2 / 2
				else
					spacePerNode = @container.width() / maxNodesLevel
					item.xAxis = currentPerLevel * spacePerNode
				@level.nodes.push(item)
				currentPerLevel++
				if maxNodesLevel is currentPerLevel
					#whats the level number
					@level.level = levelCounter
					#bubble container width
					@level.boundaryLeft = ((@container.width() - ((2 * currentPerLevel) - 1) * (@nodeHeight + @nodeSpacing)))
					console.log @level.boundaryLeft
					#if it's an odd level, shift it a little bit to the left
					@level.marginLeft = ((levelCounter * 2) * @nodeHeight) + @correction
					@level.boundaryTop = @levelHeight * levelCounter
					#insert new level into level array
					@levels.insert(@level)
					#removing all items per level so the next level can be filled up
					@level = {}
					@level.nodes = []
					#change the number of items per level for the next level
					maxNodesLevel = maxNodesLevel * 2
					currentPerLevel = 0
					levelCounter++

					@correction = @correction + @nodeHeight

		console.log @levels

	Template.main.events "click input": ->
		@levels.remove({})
		this.parse()



if Meteor.isServer
	Meteor.startup ->
