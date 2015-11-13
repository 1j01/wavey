
class @Track extends E.Component
	render: ->
		{track, editor} = @props
		{muted, pinned} = track
		E ".track",
			classes: {muted, pinned}
			className: @props.className ? "#{track.type}-track"
			E TrackControls, {muted, pinned, track, editor}
			E ".track-content",
				@props.children
