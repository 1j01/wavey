
class @Selection
	constructor: (@a, @b = @a, @track_a, @track_b = @track_a)->
	start: -> Math.min(@a, @b)
	end: -> Math.max(@a, @b)
	startTrackIndex: -> Math.min(@track_a, @track_b)
	endTrackIndex: -> Math.max(@track_a, @track_b)
	containsTrack: (track_index)-> @startTrackIndex() <= track_index <= @endTrackIndex()
	@drag: (selection, {to, toTrackIndex})->
		new Selection selection.a, Math.max(0, to), selection.track_a, Math.max(0, toTrackIndex)
