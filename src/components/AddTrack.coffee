
{E} = require "../helpers.coffee"

module.exports =
class AddTrack extends E.Component
	render: ->
		{editor, children} = @props
		
		input = document.createElement "input"
		input.type = "file"
		input.multiple = yes
		input.accept = "audio/*"
		input.addEventListener "change", (e)=>
			for file in e.target.files
				editor.add_clip file
		
		E ".track.add-track.timeline-independent",
			E ".track-content",
				children
				E "button.button",
					onClick: => input.click()
					"Choose Files"
				" or drag and drop"
