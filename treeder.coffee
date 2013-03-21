@levels = new Meteor.Collection("levelss")
@levelHeight = 80
@nodeSize = 50

if Meteor.isClient
	Meteor.startup ->
		@levels.remove()
		@container = $('#node-container')
		@parse()

	Template.main.events "click #connect": (event) ->
		connectAll()

	Template.main.events "click #parse": ->
		@levels.remove()
		@parse()


	log2 = (val) ->
		return Math.ceil(Math.log(val) / Math.LN2)

	Template.main.height = ->
		Session.get 'height'

	Template.main.levels = ->
		@levels.find({})


	parse = ->
		# template data, if any, is available in 'this'
		testData = [ {'data': 2}, {'data': 1}, {'data': 5}, {'data': null}, {'data': null}, {'data': 3}, {'data': 6}, {'data': null}, {'data': null}, {'data':null}, {'data': null}, {'data': null}, {'data': 4}, {'data': null}, {'data': null}]
		treeJson = testData

		height = log2(treeJson.length + 1)

		Session.set 'height', height
		numOfNodesAtLevel = 1
		currentLevel = 1
		currentNode = 0
		containerWidth = (2 * height) * (@nodeSize) + @nodeSize
		level = []
		@container.width(containerWidth)
		_.each treeJson, (item) ->
			item.xAxis = (containerWidth / (numOfNodesAtLevel + 1)) * (currentNode + 1)
			if level['nodes'] is undefined || level['nodes'].length == 0
				level['nodes'] = []
			level['nodes'][currentNode] = item
			item.identification = "n"+currentNode + "l" + currentLevel
			parentNode = Math.floor(currentNode / 2)
			parentLevel = (currentLevel - 1)
			item.parent = "n"+parentNode + "l" + parentLevel
			currentNode++
			#at last node of the current level, set up new level
			if numOfNodesAtLevel is currentNode
				#change level distance from top
				level['boundaryTop'] = @levelHeight * currentLevel
				level['level'] = currentLevel
				#save level data
				@levels.insert(level)
				#clear
				level = []
				#change the number of items per level for the next level
				numOfNodesAtLevel = numOfNodesAtLevel * 2
				currentNode = 0
				currentLevel++

	connectAll = ->
		_.each $(".node"), (item) ->
			if $(item).data("parent") != 'n0l0'
				orig = $('.node[data-identification="'+$(item).data('identification')+'"]')
				parent = $('.node[data-identification="'+$(item).data('parent')+'"]')
				if parent != undefined
					connect(orig, parent, "blue", 1)


	getOffset = (el) -> # return element top, left, width, height
		myOff = el.offset()
		top: myOff.top
		left: myOff.left
		width: 50
		height: 50

	connect = (div1, div2, color, thickness) -> # draw a line connecting elements
		off1 = getOffset(div1)
		off2 = getOffset(div2)

		# bottom right
		x1 = off1.left + off1.width / 2
		y1 = off1.top

		# top right
		x2 = off2.left + off2.width / 2
		y2 = off2.top + off2.height

		# distance
		length = Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

		# center
		cx = ((x1 + x2) / 2) - (length / 2)
		cy = ((y1 + y2) / 2) - (thickness / 2)

		# angle
		angle = Math.atan2((y1 - y2), (x1 - x2)) * (180 / Math.PI)

		# make hr
		htmlLine = "<div style='padding:0px; margin:0px; height:" + thickness + "px; background-color:" + color + "; line-height:1px; position:absolute; left:" + cx + "px; top:" + cy + "px; width:" + length + "px; -moz-transform:rotate(" + angle + "deg); -webkit-transform:rotate(" + angle + "deg); -o-transform:rotate(" + angle + "deg); -ms-transform:rotate(" + angle + "deg); transform:rotate(" + angle + "deg);' />"


		document.body.innerHTML += htmlLine





if Meteor.isServer
	Meteor.startup ->
