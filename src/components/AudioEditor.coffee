
class @AudioEditor extends E.Component
	constructor: ->
		@state =
			playing: no
			track_sources: []
			position: null
			position_time: null
	
	get_max_length: ->
		{tracks} = @props
		
		max_length = 0
		for track in tracks
			for clip in track.clips
				audio_buffer = AudioClip.audio_buffers_by_clip_id[clip.id]
				if audio_buffer
					max_length = Math.max max_length, clip.time + audio_buffer.length / audio_buffer.sampleRate
				else
					alert "Not all tracks have finished loading."
					return
		
		max_length
	
	get_current_position: ->
		@state.position +
			if @state.playing
				actx.currentTime - @state.position_time
			else
				0
	
	seek: (time)=>
		if isNaN time
			alert "Tried to seek to invalid time: #{time}"
			return
		
		max_length = @get_max_length()
		return unless max_length?
		
		if @state.playing and time < max_length
			@pause()
			@play time
		else
			@pause()
			@setState
				position_time: actx.currentTime
				position: Math.max 0, time
	
	seek_to_start: =>
		@seek 0
	
	seek_to_end: =>
		end = @get_max_length()
		return unless end?
		@seek end
	
	play: (from_time)=>
		@pause() if @state.playing
		
		max_length = @get_max_length()
		return unless max_length?
		
		from_time ?= @state.position ? 0
		if from_time >= max_length or from_time < 0
			from_time = 0
		
		{tracks} = @props
		
		@setState
			tid: setTimeout @pause, (max_length - from_time) * 1000 + 20
			# NOTE: an extra few ms because it shouldn't fade out prematurely
			# (even though might sound better, it might lead you to believe
			# your audio doesn't need a brief fade out at the end when it does)
			
			position_time: actx.currentTime
			position: from_time
			
			playing: yes
			track_sources:
				for track in tracks
					for clip in track.clips
						source = actx.createBufferSource()
						source.gain = actx.createGain()
						source.buffer = AudioClip.audio_buffers_by_clip_id[clip.id]
						source.connect source.gain
						source.gain.connect actx.destination
						source.gain.gain.value = if track.muted then 0 else 1
						source.start actx.currentTime + Math.max(0, clip.time - from_time), Math.max(0, from_time - clip.time)
						source
	
	pause: =>
		clearTimeout @state.tid
		for track_sources in @state.track_sources
			for source in track_sources
				source.stop actx.currentTime + 1.0
				source.gain.gain.value = 0
		@setState
			position_time: actx.currentTime
			position: @get_current_position()
			playing: no
			track_sources: []
	
	update_playback: =>
		if @state.playing
			@seek @get_current_position()
	
	set_track_prop: (track_index, prop, value)->
		{tracks, save_tracks} = @props
		undoable()
		tracks[track_index][prop] = value
		save_tracks()
		
		if prop is "muted" and @state.playing
			for source in @state.track_sources[track_index]
				source.gain.gain.value = if value then 0 else 1
	
	add_clip: (file, track_index, time=0)->
		{document_id, tracks, save_tracks} = @props
		reader = new FileReader
		reader.onload = (e)=>
			array_buffer = e.target.result
			id = GUID()
			
			localforage.setItem "#{document_id}/#{id}", array_buffer, (err)=>
				if err
					alert "Failed to store audio data.\n#{err.message}"
					console.error err
				else
					# TODO: optimize by decoding and storing in parallel, but keep good error handling
					actx.decodeAudioData array_buffer, (buffer)=>
						AudioClip.audio_buffers_by_clip_id[id] = buffer
						clip = {time, id}
						
						undoable()
						
						# @TODO: add tracks earlier with a loading indicator and remove them if an error occurs
						# and make it so you can't edit them while they're loading (e.g. pasting audio where audio is already going to be)
						unless track_index?
							track_index = tracks.length - 1
							if tracks[track_index].clips.length > 0
								tracks.push {clips: []}
								track_index = tracks.length - 1
						
						tracks[track_index].clips.push clip
						save_tracks()
						@update_playback()
			, (e)=>
				alert "Audio not playable or not supported."
				console.error e
		
		reader.onerror = (e)=>
			alert "Failed to read audio file."
			console.error e
		
		reader.readAsArrayBuffer file

	componentDidMount: =>
		window.addEventListener "keydown", (e)=>
			return if e.defaultPrevented
			return if e.altKey
			
			if e.ctrlKey
				switch e.keyCode
					when 65 # A
						@TODO.select_all() unless e.shiftKey
					when 83 # S
						if e.shiftKey then @TODO.save_as() else @TODO.save()
					when 79 # O
						@TODO.open() unless e.shiftKey
					when 78 # N
						@TODO.new() unless e.shiftKey
					when 88 # X
						@TODO.cut() unless e.shiftKey
					when 67 # C
						@TODO.copy() unless e.shiftKey
					when 86 # V
						@TODO.paste() unless e.shiftKey
					when 90 # Z
						if e.shiftKey then redo() else undo()
					when 89 # Y
						redo() unless e.shiftKey
					else
						return # don't prevent default
			else
				switch e.keyCode
					when 32 # Spacebar
						unless e.target.tagName.match /button/i
							if @state.playing
								@pause()
							else
								@play()
					when 82 # R
						@TODO.record()
					when 37 # Left
						# @TODO: finer control as well
						@seek @get_current_position() - 1
					when 39 # Right
						@seek @get_current_position() + 1
					when 38 # Up
						@TODO.up()
					when 40 # Down
						@TODO.down()
					when 36 # Home
						@seek_to_start()
					when 35 # End
						@seek_to_end()
			
			e.preventDefault()
	
	render: ->
		{playing, position, position_time} = @state
		{tracks, save_tracks, themes, set_theme} = @props
		
		window.alert = (message)=>
			@setState alert_message: message
		
		window.remove_alert = (message)=>
			if @state.alert_message is message
				@setState alert_message: null
		
		play = => @play()
		pause = => @pause()
		go_to_start = => @seek_to_start()
		go_to_end = => @seek_to_end()
		seek = (t)=> @seek t
		
		mute_track = (track_index)=>
			@set_track_prop track_index, "muted", on
		
		unmute_track = (track_index)=>
			@set_track_prop track_index, "muted", off
		
		pin_track = (track_index)=>
			@set_track_prop track_index, "pinned", on
		
		unpin_track = (track_index)=>
			@set_track_prop track_index, "pinned", off
		
		remove_track = (track_index)=>
			undoable()
			tracks.splice track_index, 1
			save_tracks()
			@update_playback()
		
		add_clip = @add_clip
		
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
				return if e.isDefaultPrevented()
				e.preventDefault()
				for file in e.dataTransfer.files
					@add_clip file
			E Controls, {playing, play, pause, go_to_start, go_to_end, themes, set_theme, key: "controls"}
			E "div",
				key: "infobar",
				if @state.alert_message
					# @TODO: separate component
					# @TODO: remove Gtk-isms
					# @TODO: animate appearing/disappearing
					E "GtkInfoBar.warning",
						E "GtkLabel", @state.alert_message
						E "button.button",
							onClick: => @setState alert_message: null
							E "GtkLabel", "Dismiss"
			E Tracks, {tracks, position, position_time, playing, seek, mute_track, unmute_track, pin_track, unpin_track, remove_track, add_clip, key: "tracks"}
