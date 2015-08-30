
class @Selection
	constructor: (@a, @b = @a)->
	start: -> Math.min(@a, @b)
	end: -> Math.max(@a, @b)
	@drag: (selection, {to})->
		new Selection selection.a, Math.max(0, to)
