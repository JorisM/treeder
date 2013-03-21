@tree = new Meteor.Collection("tree")
@trees = new Meteor.Collection("trees")
@levels = new Meteor.Collection("levels")
@level = {}
@levelHeight = 80
@nodeSize = 50
@nodeSpacing = 50
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
		@containerWidth = (2 * height) * @nodeSize
		@container.width(@containerWidth)

		_.each array, (item) ->
			if maxNodesLevel >= currentPerLevel
				if maxNodesLevel is 1
					item.xAxis = @containerWidth / 2
				else
					item.xAxis = (currentPerLevel * nodeSize) + (currentPerLevel * @nodeSpacing)
				@level.nodes.push(item)
				currentPerLevel++
				if maxNodesLevel is currentPerLevel
					#whats the level number
					@level.level = levelCounter
					#bubble container width
					if maxNodesLevel is 1
						@level.marginLeft = @containerWidth / 2
					else
						@level.marginLeft = @containerWidth - ((maxNodesLevel * @nodeSize) / 2)
					@level.boundaryTop = @levelHeight * levelCounter
					#insert new level into level array
					@levels.insert(@level)
					#clear
					@level = {}
					@level.nodes = []
					#change the number of items per level for the next level
					maxNodesLevel = maxNodesLevel * 2
					currentPerLevel = 0
					@nodeSpacing = @nodeSpacing / 2
					levelCounter++
		console.log 'tree: ', @levels

	Template.main.events "click input": ->
		@levels.remove({})
		this.parse()



if Meteor.isServer
	Meteor.startup ->
