
{E, Component} = require "../helpers.coffee"

module.exports =
class Track extends Component
	render: ->
		{track, editor} = @props
		{muted, pinned} = track
		E ".track",
			classes: {muted, pinned}
			className: @props.className ? "#{track.type}-track"
			data: trackId: track.id
			E ".track-content",
				@props.children
