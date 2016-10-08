
{E, Component} = require "../helpers.coffee"
Track = require "./Track.coffee"

module.exports =
class UnknownTrack extends Component
	render: ->
		{track, editor} = @props
		E Track, {track, editor, className: "unknown-track timeline-independent"},
			"Unknown track type: #{JSON.stringify track.type}"
