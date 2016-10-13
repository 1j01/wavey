
{E, Component} = require "../helpers.coffee"

module.exports =
class MIDINotes extends Component
	
	render: ->
		{notes, scale, style} = @props
		
		length = 0
		for note in notes
			length = Math.max(length, note.t + note.length)
		width = (length ? 0) * scale
		height = 80 # = .track-content {height} (TODO: DRY these magic numbers)
		n_notes_vertically = 40
		middle_midi_note = 60 # middle C
		
		E "svg.midi-notes", {
			style
			width, height
			data: {length}
			xmlns: "http://www.w3.org/svg/2000"
			viewBox: "0 0 #{width} #{height}"
		},
			if width
				key = 0
				for note in notes
					key += 1
					E "rect.note", {
						key
						x: note.t * scale
						y: (1 / 2 + (middle_midi_note - note.note) / n_notes_vertically) * height
						width: note.length * scale - 1
						height: height/n_notes_vertically
					}
	
	shouldComponentUpdate: (last_props)->
		@props.data isnt last_props.data or
		@props.length isnt last_props.length or
		@props.scale isnt last_props.scale
