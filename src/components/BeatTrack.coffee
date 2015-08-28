
class @BeatTrack extends E.Component
	render: ->
		E ".track.beat-track",
			E TrackControls, muted: yes, pinned: yes
			E ".track-content",
				E BeatMarkings
