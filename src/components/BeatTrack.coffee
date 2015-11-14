
class @BeatTrack extends E.Component
	render: ->
		{track, editor} = @props
		E Track, {track, editor},
			E BeatMarkings
