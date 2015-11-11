
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no
	render: ->
		{playing} = @state
		{document_id, tracks, themes, set_theme} = @props
		play = => @setState playing: yes
		pause = => @setState playing: no
		E ".audio-editor",
			onDragOver: (e)=>
				e.preventDefault()
			onDrop: (e)=>
				e.preventDefault()
				
				track_index = tracks.length - 1
				if tracks[track_index].clips.length > 0
					tracks.push {clips: []}
					track_index = tracks.length - 1
				
				for file in e.dataTransfer.files
					add_clip track_index, file
				
			E Controls, {playing, play, pause, themes, set_theme}
			E Tracks, {tracks}
