
class @UnknownTrack extends E.Component
	render: ->
		{track, editor} = @props
		E Track, {track, editor, className: "unknown-track"},
			"Unknown track type: #{JSON.stringify track.type}"
