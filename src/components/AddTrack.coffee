
class @AddTrack extends E.Component
	render: ->
		{editor} = @props
		
		input = document.createElement "input"
		input.type = "file"
		input.multiple = yes
		input.accept = "audio/*"
		input.addEventListener "change", (e)=>
			for file in e.target.files
				editor.add_clip file
		
		E ".track.add-track",
			E ".track-content",
				E "button.button",
					onClick: => input.click()
					"Choose Files"
				" or drag and drop"
