
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no, track_sources: [], position: null
	
	update_position_indicator: (start_time = @state.start_time)=>
		@setState position: actx.currentTime - start_time + 0.001, alternate_hack: not @state.alternate_hack
	
	play: =>
		{tracks} = @props
		
		for track in tracks
			for clip in track.clips
				unless audio_buffer_for_clip clip.id
					alert "Not all tracks have finished loading."
					return
		
		# @TODO: end playback after all of the clips have played
		
		@setState
			start_time: actx.currentTime
			playing: yes
			iid: setInterval @update_position_indicator, 500
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
		@update_position_indicator actx.currentTime

	pause: =>
		clearInterval @state.iid
		for track_sources in @state.track_sources
			for source in track_sources
				source.stop actx.currentTime + 1.0
				source.gain.gain.value = 0
		@setState
			playing: no
			track_sources: []
			iid: -1
		@update_position_indicator()
	
	componentDidMount: =>
		window.addEventListener "keypress", (e)=>
			if e.keyCode is 32 # Spacebar
				unless e.target.tagName.match /button/i
					e.preventDefault()
					if @state.playing
						@pause()
					else
						@play()
	
	render: ->
		{playing, position, alternate_hack} = @state
		{document_id, tracks, themes, set_theme} = @props
		
		window.alert = (message)=>
			@setState alert_message: message
		
		window.remove_alert = (message)=>
			if @state.alert_message is message
				@setState alert_message: null
		
		E ".audio-editor",
			# @FIXME buttons "shimmer" once every second due to this hack (and when you hit spacebar)
			className: {playing, alternate_hack}
			tabIndex: 0
			style: outline: "none"
			onMouseDown: (e)=>
				e.preventDefault()
				React.findDOMNode(@).focus()
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
			
			play = => @play()
			pause = => @pause()
			E Controls, {playing, play, pause, themes, set_theme}
			E "div",
				if @state.alert_message
					# @TODO: remove Gtk-isms
					# @TODO: animate appearing/disappearing
					E "GtkInfoBar.warning",
						E "GtkLabel", @state.alert_message
						E "button.button",
							onClick: => @setState alert_message: null
							E "GtkLabel", "Dismiss"
			E Tracks, {tracks, position}
