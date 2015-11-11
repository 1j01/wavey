
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
				
				#add = (file)=>
					#reader = new FileReader
					#reader.onload = (e)=>
						#arrayBuffer = e.target.result
						#guid = GUID()
						#localforage.setItem "#{document_id}/#{guid}", arrayBuffer, (err)=>
							#
						#actx.decodeAudioData arrayBuffer, (buffer)=>
							#source = actx.createBufferSource()
							#source.buffer = buffer
							#source.start 0
							#source.connect actx.destination
						#, (e)=>
							#alert "Audio not playable or not supported."
							#console.error e
					#
					#reader.onerror = (e)=>
						#alert "Failed to read audio file."
						#console.error e
					#
					#reader.readAsArrayBuffer file
				
				#add file for file in e.dataTransfer.files
				
				track_index = tracks.length - 1
				if tracks[track_index].clips.length > 0
					tracks.push {clips: []}
					track_index = tracks.length - 1
				
				for file in e.dataTransfer.files
					add_clip track_index, file
				
			E Controls, {playing, play, pause, themes, set_theme}
			E Tracks, {tracks}
