
class @TrackControls extends E.Component
	render: ->
		# @TODO a way to reorder tracks (I should probably give tracks IDs and not go by track indices)
		{muted, pinned, mute_track, unmute_track, pin_track, unpin_track, remove_track, track_index} = @props
		E ".track-controls",
			E "button.button.remove",
				title: "Remove track"
				onClick: =>
					remove_track track_index
				E "i.octicon.octicon-x"
			E ".linked",
				E "button.button.toggle.mute",
					class: ("active" if muted)
					title: if muted then "Unmute track" else "Mute track"
					onClick: =>
						if muted
							unmute_track track_index
						else
							mute_track track_index
					E "i.octicon.octicon-mute"
				E "button.button.toggle.pin",
					class: ("active" if pinned)
					title: if pinned then "Unpin track from the top" else "Pin track to the top"
					onClick: =>
						if pinned
							unpin_track track_index
						else
							pin_track track_index
					E "i.octicon.octicon-pin"
