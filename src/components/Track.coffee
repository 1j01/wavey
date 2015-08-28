
class @Track extends E.Component
	render: ->
		E ".track",
			E TrackControls, muted: @props.muted, pinned: @props.pinned
			E ".track-content",
				@props.children
