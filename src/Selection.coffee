
class @Selection
	constructor: (@a, @b = @a, @track_a, @track_b = @track_a)->
	start: -> Math.min(@a, @b)
	end: -> Math.max(@a, @b)
	length: -> @end() - @start()
	containsTime: (time)-> @start() <= time <= @end()
	startTrackIndex: -> Math.min(@track_a, @track_b)
	endTrackIndex: -> Math.max(@track_a, @track_b)
	containsTrackIndex: (track_index)-> @startTrackIndex() <= track_index <= @endTrackIndex()
	@drag: (selection, {to, toTrackIndex})->
		new Selection selection.a, Math.max(0, to), selection.track_a, Math.max(0, toTrackIndex)
	@fromJSON: (selection)->
		new Selection selection.a, selection.b, selection.track_a, selection.track_b
