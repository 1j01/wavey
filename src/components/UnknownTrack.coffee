
class @UnknownTrack extends E.Component
	render: ->
		{track, editor, track} = @props
		{muted, pinned} = track
		E ".track.unknown-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, editor, track}
			E ".track-content",
				"Unknown track type: #{JSON.stringify track.type}"
