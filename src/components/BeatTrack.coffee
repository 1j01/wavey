
class @BeatTrack extends E.Component
	render: ->
		{track, scale, editor} = @props
		E Track, {track, editor},
			E BeatMarkings, {scale}
