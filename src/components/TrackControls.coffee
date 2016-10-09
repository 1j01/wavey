
{E, Component} = require "../helpers.coffee"

module.exports =
class TrackControls extends Component
	render: ->
		# @TODO a way to reorder tracks
		{track, editor} = @props
		{muted, pinned} = track
		{mute_track, unmute_track, pin_track, unpin_track, remove_track} = editor
		E ".track-controls",
			E "button.button.remove",
				title: "Remove track"
				onClick: =>
					remove_track track.id
				E "i.octicon.octicon-x"
			E ".linked",
				E "button.button.mute",
					aria: pressed: muted
					title: if muted then "Unmute track" else "Mute track"
					onClick: =>
						if muted
							unmute_track track.id
						else
							mute_track track.id
					E "i.octicon.octicon-mute"
				E "button.button.pin",
					aria: pressed: pinned
					title: if pinned then "Unpin track from the top" else "Pin track to the top"
					onClick: =>
						if pinned
							unpin_track track.id
						else
							pin_track track.id
					E "i.octicon.octicon-pin"
	
	shouldComponentUpdate: (next_props, next_state)->
		next_props.track.id isnt @props.track.id or
		next_props.track.muted isnt @props.track.muted or
		next_props.track.pinned isnt @props.track.pinned
