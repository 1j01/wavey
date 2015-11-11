
class @BeatTrack extends E.Component
	render: ->
		{mute_track, unmute_track, pin_track, unpin_track, track_index} = @props
		[muted, pinned] = [on, on]
		# @TODO: allow unmuting the beat track (making it a metronome)
		# and unpinning it
		E ".track.beat-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, mute_track, unmute_track, pin_track, unpin_track, track_index}
			E ".track-content",
				E BeatMarkings
