
{E, Component} = require "../helpers.coffee"

module.exports =
class BeatMarkings extends Component
	render: ->
		{scale, document_width} = @props
		bpm = 240 # one measure per second
		bps = bpm / 60
		E ".beat-markings", style: position: "relative",
			for x in [0..document_width/scale*bps]
				E ".beat-marking",
					class: ("sub" if x % 4 > 0)
					key: x
					style: position: "absolute", left: "#{x*scale/bps}px"
	
	shouldComponentUpdate: (last_props)->
		@props.document_width isnt last_props.document_width or
		@props.scale isnt last_props.scale
