
# @TODO: DRY up these classes (revist having a Track component?)
class @BeatTrack extends E.Component
	render: ->
		{track, editor} = @props
		{muted, pinned} = track
		E ".track.beat-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, editor, track}
			E ".track-content",
				E BeatMarkings
