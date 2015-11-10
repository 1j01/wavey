
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no
	render: ->
		{playing} = @state
		{tracks, themes, set_theme} = @props
		play = => @setState playing: yes
		pause = => @setState playing: no
		E ".audio-editor",
			onDragOver: (e)=>
				e.preventDefault()
			onDrop: (e)=>
				e.preventDefault()
				
				add = (file)=>
					reader = new FileReader
					reader.onload = (e)=>
						actx.decodeAudioData e.target.result, (buffer)=>
							source = actx.createBufferSource()
							source.buffer = buffer
							source.start 0
							source.connect actx.destination
						, (e)=>
							alert "Audio not playable or not supported."
							console.error e
					
					reader.onerror = (e)=>
						alert "Failed to decode audio file. You sure it is one?"
						console.error e
					
					reader.readAsArrayBuffer file
				
				add file for file in e.dataTransfer.files
				
			E Controls, {playing, play, pause, themes, set_theme}
			E Tracks, {tracks}
