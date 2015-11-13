
class @UnknownTrack extends E.Component
	render: ->
		{track, editor, track_id} = @props
		{muted, pinned} = track
		E ".track.unknown-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, editor, track_id}
			E ".track-content",
				"Unknown track type: #{JSON.stringify track.type}"
