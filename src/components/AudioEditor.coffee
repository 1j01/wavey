
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no, track_sources: []
	render: ->
		{playing} = @state
		{document_id, tracks, themes, set_theme} = @props
		play = =>
			@setState
				playing: yes
				track_sources:
					for track in tracks
						for clip in track.clips
							source = actx.createBufferSource()
							source.gain = actx.createGain()
							source.buffer = audio_buffer_for_clip clip.id
							source.connect source.gain
							source.gain.connect actx.destination
							source.start actx.currentTime + clip.time
							source

		pause = =>
			for track_sources in @state.track_sources
				for source in track_sources
					source.stop actx.currentTime + 1.0
					source.gain.gain.value = 0
			@setState
				playing: no
				track_sources: []
		
		E ".audio-editor",
			# @TODO!
			#onKeyPress: (e)=>
				#if e.keyCode is 32
					#e.preventDefault()
					#if @state.playing
						#pause()
					#else
						#play()
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
