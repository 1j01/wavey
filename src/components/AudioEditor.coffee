
class @AudioEditor extends E.Component
	
	copy_of = (o)-> JSON.parse JSON.stringify o
	
	constructor: ->
		@state =
			tracks: {
				"beat-track": {
					muted: yes
					pinned: yes
				}
			}
			undos: []
			redos: []
			playing: no
			track_sources: []
			position: null
			position_time: null
	
	save: ->
		{document_id} = @props
		{tracks, undos, redos} = @state
		localforage.setItem "#{document_id}/tracks", tracks, (err)=>
			if err
				InfoBar.warn "Failed to store track metadata.\n#{err.message}"
				console.error err
			else
				render()
		localforage.setItem "#{document_id}/undos", undos
		localforage.setItem "#{document_id}/redos", redos
		# @TODO: error handling
	
	undoable: (fn)->
		{tracks, undos, redos} = @state
		tracks = copy_of tracks
		undos = copy_of undos
		redos = []
		undos.push copy_of tracks
		fn tracks
		@setState {tracks, undos, redos}
	
	undo: ->
		{tracks, undos, redos} = @state
		return unless undos.length
		tracks = copy_of tracks
		undos = copy_of undos
		redos = copy_of redos
		redos.push copy_of tracks
		tracks = undos.pop()
		@setState {tracks, undos, redos}
	
	redo: ->
		{tracks, undos, redos} = @state
		return unless redos.length
		tracks = copy_of tracks
		undos = copy_of undos
		redos = copy_of redos
		undos.push copy_of tracks
		tracks = redos.pop()
		@setState {tracks, undos, redos}
	
	get_max_length: ->
		{tracks} = @state
		
		max_length = 0
		for track_id, track of tracks when track.clips
			for clip in track.clips
				audio_buffer = AudioClip.audio_buffers_by_clip_id[clip.id]
				if audio_buffer
					max_length = Math.max max_length, clip.time + audio_buffer.length / audio_buffer.sampleRate
				else
					InfoBar.warn "Not all tracks have finished loading."
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
			InfoBar.warn "Tried to seek to invalid time: #{time}"
			return
		
		max_length = @get_max_length()
		
		if @state.playing and max_length? and time < max_length
			@play_from time
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
	
	play: =>
		@play_from @state.position ? 0
	
	play_from: (from_time)=>
		@pause() if @state.playing
		
		max_length = @get_max_length()
		return unless max_length?
		
		if from_time >= max_length or from_time < 0
			from_time = 0
		
		{tracks} = @state
		
		@setState
			tid: setTimeout @pause, (max_length - from_time) * 1000 + 20
			# NOTE: an extra few ms because it shouldn't fade out prematurely
			# (even though might sound better, it might lead you to believe
			# your audio doesn't need a brief fade out at the end when it does)
			
			position_time: actx.currentTime
			position: from_time
			
			playing: yes
			track_sources:
				# @TODO: metronome when beat track is unmuted
				for track_id, track of tracks when track.clips
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
	
	set_track_prop: (track_id, prop, value)->
		@undoable (tracks)=>
			tracks[track_id][prop] = value
	
	mute_track: (track_id)=>
		@set_track_prop track_id, "muted", on
	
	unmute_track: (track_id)=>
		@set_track_prop track_id, "muted", off
	
	pin_track: (track_id)=>
		@set_track_prop track_id, "pinned", on
	
	unpin_track: (track_id)=>
		@set_track_prop track_id, "pinned", off
	
	remove_track: (track_id)=>
		@undoable (tracks)=>
			delete tracks[track_id]
			# @TODO: splice from track_order?
	
	add_clip: (file, track_id, time=0)->
		{document_id} = @props
		reader = new FileReader
		reader.onload = (e)=>
			array_buffer = e.target.result
			id = GUID()
			
			localforage.setItem "#{document_id}/#{id}", array_buffer, (err)=>
				if err
					InfoBar.warn "Failed to store audio data.\n#{err.message}"
					console.error err
				else
					# TODO: optimize by decoding and storing in parallel, but keep good error handling
					actx.decodeAudioData array_buffer, (buffer)=>
						AudioClip.audio_buffers_by_clip_id[id] = buffer
						clip = {time, id}
						
						@undoable (tracks)=>
							# @TODO: add tracks earlier with a loading indicator and remove them if an error occurs
							# and make it so you can't edit them while they're loading (e.g. pasting audio where audio is already going to be)
							unless track_id?
								for _track_id, _track of tracks
									last_track = _track
									last_track_id = _track_id
								if last_track?.clips?.length is 0
									track_id = last_track_id
								else
									track_id = GUID()
									tracks[track_id] = {clips: []}
							
							tracks[track_id].clips.push clip
			, (e)=>
				InfoBar.warn "Audio not playable or not supported."
				console.error e
		
		reader.onerror = (e)=>
			InfoBar.warn "Failed to read audio file."
			console.error e
		
		reader.readAsArrayBuffer file
	
	componentDidUpdate: (last_props, last_state)=>
		{document_id} = @props
		{tracks, undos, redos} = @state
		if (
			tracks isnt last_state.tracks or
			undos isnt last_state.undos or
			redos isnt last_state.redos
		)
			@save()
			@update_playback()
			AudioClip.load_clips(tracks, document_id)
	
	componentDidMount: =>
		{document_id} = @props
		
		localforage.getItem "#{document_id}/tracks", (err, tracks)=>
			if err
				InfoBar.warn "Failed to load the document.\n#{err.message}"
				console.error err
			else if tracks
				@setState {tracks}
				
				localforage.getItem "#{document_id}/undos", (err, undos)=>
					if err
						InfoBar.warn "Failed to load undo history.\n#{err.message}"
						console.error err
					else if undos
						@setState {undos}
				
				localforage.getItem "#{document_id}/redos", (err, redos)=>
					if err
						InfoBar.warn "Failed to load redo history.\n#{err.message}"
						console.error err
					else if redos
						@setState {redos}
		
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
						if e.shiftKey then @redo() else @undo()
					when 89 # Y
						@redo() unless e.shiftKey
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
					else
						return # don't prevent default
			
			e.preventDefault()
	
	render: ->
		{tracks, playing, position, position_time} = @state
		{themes, set_theme} = @props
		
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
			E Controls, {playing, editor: @, themes, set_theme, key: "controls"}
			E "div",
				key: "infobar"
				E InfoBar # @TODO, ref: (@infobar)=>
			E Tracks, {tracks, position, position_time, playing, editor: @, key: "tracks"}
