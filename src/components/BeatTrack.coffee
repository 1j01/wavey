
class @BeatTrack extends E.Component
	render: ->
		{track, editor, track_id} = @props
		{muted, pinned} = track
		E ".track.beat-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, editor, track_id}
			E ".track-content",
				E BeatMarkings
