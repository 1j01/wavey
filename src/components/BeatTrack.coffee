
{E, Component} = require "../helpers.coffee"
Track = require "./Track.coffee"
BeatMarkings = require "./BeatMarkings.coffee"

module.exports =
class BeatTrack extends Component
	render: ->
		{track, scale, editor, document_width} = @props
		E Track, {track, editor},
			E BeatMarkings, {scale, document_width}
