
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no, track_sources: [], position: null
	
	play: (from_time)=>
		{tracks} = @props
		
		max_length = 0
		for track in tracks
			for clip in track.clips
				audio_buffer = audio_buffer_for_clip clip.id
				if audio_buffer
					max_length = Math.max max_length, clip.time + audio_buffer.length / audio_buffer.sampleRate
				else
					alert "Not all tracks have finished loading."
					return
		
		from_time ?= @state.position ? 0
		if from_time >= max_length
			from_time = 0
		
		@setState
			tid: setTimeout @pause, (max_length - from_time) * 1000 + 20
			# NOTE: an extra few ms because it shouldn't fade out prematurely
			# (even though might sound better, it might lead you to believe
			# your audio doesn't need a brief fade out at the end when it does)
			start_time: actx.currentTime - from_time
			position: from_time + 0.00001
			playing: yes
			track_sources:
				for track in tracks
					for clip in track.clips
						source = actx.createBufferSource()
						source.gain = actx.createGain()
						source.buffer = audio_buffer_for_clip clip.id
						source.connect source.gain
						source.gain.connect actx.destination
						source.start actx.currentTime + clip.time, from_time
						source

	pause: =>
		clearTimeout @state.tid
		for track_sources in @state.track_sources
			for source in track_sources
				source.stop actx.currentTime + 1.0
				source.gain.gain.value = 0
		@setState
			position: actx.currentTime - @state.start_time
			playing: no
			track_sources: []
	
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
		{playing, position} = @state
		{document_id, tracks, themes, set_theme} = @props
		
		window.alert = (message)=>
			@setState alert_message: message
		
		window.remove_alert = (message)=>
			if @state.alert_message is message
				@setState alert_message: null
		
		E ".audio-editor",
			className: {playing}
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
			E Controls, {playing, play, pause, themes, set_theme, key: "controls"}
			E "div",
				key: "infobar",
				if @state.alert_message
					# @TODO: remove Gtk-isms
					# @TODO: animate appearing/disappearing
					E "GtkInfoBar.warning",
						E "GtkLabel", @state.alert_message
						E "button.button",
							onClick: => @setState alert_message: null
							E "GtkLabel", "Dismiss"
			E Tracks, {tracks, position, playing, key: "tracks"}
