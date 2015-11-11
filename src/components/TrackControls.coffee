
class @TrackControls extends E.Component
	render: ->
		# @TODO: a way to remove tracks
		# also maybe reordering tracks (I should probably give tracks IDs and not go by track indices)
		{muted, pinned, mute_track, unmute_track, pin_track, unpin_track, track_index} = @props
		E ".track-controls.linked",
			E "button.button.toggle.mute",
				class: ("active" if muted)
				onClick: =>
					if muted
						unmute_track track_index
					else
						mute_track track_index
				E "i.octicon.octicon-mute"
			E "button.button.toggle.pin",
				class: ("active" if pinned)
				onClick: =>
					if pinned
						unpin_track track_index
					else
						pin_track track_index
				E "i.octicon.octicon-pin"
