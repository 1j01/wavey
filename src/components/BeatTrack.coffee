
class @BeatTrack extends E.Component
	render: ->
		{editor, track_index} = @props
		[muted, pinned] = [on, on]
		# @TODO: allow unmuting the beat track (making it a metronome)
		# and unpinning it
		E ".track.beat-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, editor, track_index}
			E ".track-content",
				E BeatMarkings
