
class @TrackControls extends E.Component
	constructor: ->
		@state =
			muted: null
			pinned: null
	render: ->
		muted = @state.muted ? @props.muted
		pinned = @state.pinned ? @props.pinned
		E ".track-controls.linked",
			E "button.button.toggle.mute",
				class: ("active" if muted)
				onClick: => @setState muted: not muted
				E "i.octicon.octicon-mute"
			E "button.button.toggle.pin",
				class: ("active" if pinned)
				onClick: => @setState pinned: not pinned
				E "i.octicon.octicon-pin"
