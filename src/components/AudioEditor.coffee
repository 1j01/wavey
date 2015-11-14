
class @AudioEditor extends E.Component
	
	copy_of = (o)-> JSON.parse JSON.stringify o
	
	constructor: ->
		@state =
			tracks: [
				{
					id: "beat-track"
					type: "beat"
					muted: yes
					pinned: yes
				}
			]
			undos: []
			redos: []
			playing: no
			track_sources: []
			position: null
			position_time: null
			selection: null
	
	save: ->
		{document_id} = @props
		{tracks, selection, undos, redos} = @state
		doc = {state: {tracks, selection}, undos, redos}
		localforage.setItem "#{document_id}", doc, (err)=>
			if err
				InfoBar.warn "Failed to save the document.\n#{err.message}"
				console.error err
			else
				render()
	
	load: ->
		{document_id} = @props
		localforage.getItem "#{document_id}", (err, doc)=>
			if err
				InfoBar.warn "Failed to load the document.\n#{err.message}"
				console.error err
			else if doc
				{state, undos, redos} = doc
				{tracks, selection} = state
				@setState {tracks, undos, redos}
				@select Selection.fromJSON selection if selection?
	
	undoable: (fn)->
		{tracks, selection, undos, redos} = @state
		tracks = copy_of tracks
		undos = copy_of undos
		redos = []
		undos.push
			tracks: copy_of tracks
			selection: copy_of selection
		fn tracks
		@setState {tracks, undos, redos}
	
	undo: ->
		{tracks, selection, undos, redos} = @state
		return unless undos.length
		tracks = copy_of tracks
		undos = copy_of undos
		redos = copy_of redos
		redos.push
			tracks: copy_of tracks
			selection: copy_of selection
		{tracks, selection} = undos.pop()
		@setState {tracks, undos, redos}
		@select Selection.fromJSON selection if selection?
	
	redo: ->
		{tracks, selection, undos, redos} = @state
		return unless redos.length
		tracks = copy_of tracks
		undos = copy_of undos
		redos = copy_of redos
		undos.push
			tracks: copy_of tracks
			selection: copy_of selection
		{tracks, selection} = redos.pop()
		@setState {tracks, undos, redos}
		@select Selection.fromJSON selection if selection?
	
	# @TODO: soft undo/redo
	
	get_max_length: ->
		{tracks} = @state
		
		max_length = 0
		for track in tracks when track.type is "audio"
			for clip in track.clips
				audio_buffer = AudioClip.audio_buffers[clip.audio_id]
				if audio_buffer
					max_length = Math.max max_length, clip.time + clip.length
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
				for track in tracks when track.type is "audio"
					for clip in track.clips
						source = actx.createBufferSource()
						source.gain = actx.createGain()
						source.buffer = AudioClip.audio_buffers[clip.audio_id]
						source.connect source.gain
						source.gain.connect actx.destination
						source.gain.gain.value = if track.muted then 0 else 1
						
						# @TODO: maybe rename clip.time to clip.start_time or clip.start
						start_time = Math.max(0, clip.time - from_time)
						starting_offset_into_clip = Math.max(0, from_time - clip.time) + clip.offset
						length_to_play_of_clip = clip.length - Math.max(0, from_time - clip.time)
						
						if length_to_play_of_clip > 0
							source.start actx.currentTime + start_time, starting_offset_into_clip, length_to_play_of_clip
							source
	
	pause: =>
		clearTimeout @state.tid
		for track_sources in @state.track_sources
			for source in track_sources
				source?.stop actx.currentTime + 1.0
				source?.gain.gain.value = 0
		@setState
			position_time: actx.currentTime
			position: @get_current_position()
			playing: no
			track_sources: []
	
	update_playback: =>
		if @state.playing
			@seek @get_current_position()
	
	select: (selection)=>
		@setState {selection}
	
	deselect: =>
		@select null
	
	delete: =>
		{selection} = @state
		return unless selection?.length()
		
		@undoable (tracks)=>
			for track, track_index in tracks when track.type is "audio" and selection.containsTrackIndex track_index
				clips = []
				for clip in track.clips
					buffer = AudioClip.audio_buffers[clip.audio_id]
					unless buffer?
						InfoBar.warn "Not all selected tracks have finished loading."
						return
					clip_end = clip.time + clip.length
					clip_start = clip.time
					if selection.start() < clip_end and selection.end() > clip_start
						if selection.start() > clip_start
							clips.push
								id: GUID()
								audio_id: clip.audio_id
								time: clip_start
								length: selection.start() - clip_start
								offset: clip.offset
						if selection.end() < clip_end
							clips.push
								id: GUID()
								audio_id: clip.audio_id
								time: selection.start()
								length: clip_end - selection.end()
								offset: clip.offset + selection.end() - clip_start
					else
						if clip_start >= selection.end()
							clip.time -= selection.length()
						clips.push clip
				track.clips = clips
			@select new Selection selection.start(), selection.start(), selection.startTrackIndex(), selection.endTrackIndex()
			@seek selection.start()
	
	copy: =>
		{selection, tracks} = @state
		return unless selection?.length()
		
		# @TODO: copy and paste emptyness (include a length value in the clipboard)
		
		clipboard = []
		for track, track_index in tracks when track.type is "audio" and selection.containsTrackIndex track_index
			clips = []
			for clip in track.clips
				buffer = AudioClip.audio_buffers[clip.audio_id]
				unless buffer?
					InfoBar.warn "Not all selected tracks have finished loading."
					return
				clip_end = clip.time + clip.length
				clip_start = clip.time
				if selection.start() < clip_end and selection.end() > clip_start
					if selection.start() <= clip_start and selection.end() >= clip_end
						# clip is entirely contained within selection
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: clip_start - selection.start()
							length: clip.length
							offset: clip.offset
					else if selection.start() > clip_start and selection.end() < clip_end
						# selection is entirely within clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: 0
							length: selection.length()
							offset: clip.offset - clip_start + selection.start()
					else if selection.start() < clip_end <= selection.end()
						# selection overlaps end of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: 0
							length: clip_end - selection.start()
							offset: clip.offset - clip_start + selection.start()
					else if selection.start() <= clip_start < selection.end()
						# selection overlaps start of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: clip_start - selection.start()
							length: selection.end() - clip_start
							offset: clip.offset
			clipboard.push clips
		
		localforage.setItem "clipboard", clipboard, (err)=>
			if err
				InfoBar.warn "Failed to store clipboard data.\n#{err.message}"
				console.error err
	
	cut: =>
		@copy()
		@delete()
	
	paste: =>
		localforage.getItem "clipboard", (err, clipboard)=>
			if err
				InfoBar.warn "Failed to load clipboard data.\n#{err.message}"
				console.error err
			else
				# @FIXME: extra undoable
				@delete()
				{tracks, selection} = @state
				if selection?
					@insert clipboard, selection.start(), selection.startTrackIndex()
				else
					@insert clipboard, 0, tracks.length
	
	insert: (stuff, insertion_position, insertion_track_start_index)->
		@undoable (tracks)=>
			
			insertion_length = 0
			for clips in stuff
				for clip in clips
					insertion_length = Math.max(insertion_length, clip.time + clip.length)
			
			insertion_track_end_index = insertion_track_start_index + stuff.length - 1
			
			for track in tracks.slice(insertion_track_start_index, insertion_track_end_index + 1) when track.type is "audio"
				clips = []
				for clip in track.clips
					if clip.time >= insertion_position
						clip.time += insertion_length
						clips.push clip
					else if clip.time + clip.length > insertion_position
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: clip.time
							length: insertion_position - clip.time
							offset: clip.offset
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							time: insertion_position + insertion_length
							length: clip.length - (insertion_position - clip.time)
							offset: clip.offset + insertion_position - clip.time
					else
						clips.push clip
				track.clips = clips
			
			for clips, i in stuff
				track = tracks[insertion_track_start_index + i]
				if not track? and clips.length
					track = {id: GUID(), type: "audio", clips: []}
					tracks.push track
				for clip in clips
					clip.time += insertion_position
					clip.id = GUID()
					track.clips.push clip
			
			end = insertion_position + insertion_length
			@select new Selection end, end, insertion_track_start_index, insertion_track_end_index
	
	set_track_prop: (track_id, prop, value)->
		@undoable (tracks)=>
			for track in tracks when track.id is track_id
				track[prop] = value
	
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
			{selection} = @state
			for track, track_index in tracks when track.id is track_id by -1
				tracks.splice track_index, 1
				if selection.containsTrackIndex track_index
					if selection.startTrackIndex() is selection.endTrackIndex()
						@deselect()
					else
						@select new Selection selection.start(), selection.end(), selection.startTrackIndex(), selection.endTrackIndex() - 1
	
	add_clip: (file, at_selection)->
		{document_id} = @props
		if at_selection
			{selection} = @state
			return unless selection?
		reader = new FileReader
		reader.onload = (e)=>
			array_buffer = e.target.result
			clip = {id: GUID(), audio_id: GUID(), time: 0}
			
			localforage.setItem "#{document_id}/#{clip.audio_id}", array_buffer, (err)=>
				if err
					InfoBar.warn "Failed to store audio data.\n#{err.message}"
					console.error err
				else
					# TODO: optimize by decoding and storing in parallel, but keep good error handling
					actx.decodeAudioData array_buffer, (buffer)=>
						AudioClip.audio_buffers[clip.audio_id] = buffer
						
						clip.length = buffer.length / buffer.sampleRate
						clip.offset = 0
						
						if at_selection
							@insert [[clip]], selection.start(), selection.startTrackIndex()
						else
							@insert [[clip]], 0, @state.tracks.length
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
		
		@load()
		
		window.addEventListener "keydown", @keydown_listener = (e)=>
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
						@cut() unless e.shiftKey
					when 67 # C
						@copy() unless e.shiftKey
					when 86 # V
						@paste() unless e.shiftKey
					when 90 # Z
						if e.shiftKey then @redo() else @undo()
					when 89 # Y
						@redo() unless e.shiftKey
					else
						return # don't prevent default
			else
				switch e.keyCode
					# @TODO: media keys?
					when 32 # Spacebar
						unless e.target.tagName.match /button/i
							if @state.playing
								@pause()
							else
								@play()
					when 46, 8 # Delete, Backspace
						@delete()
					when 82 # R
						@TODO.record()
					when 37 # Left
						# @TODO: finer control as well
						@seek @get_current_position() - 1
					when 39 # Right
						@seek @get_current_position() + 1
					when 38, 33 # Up, Page Up
						@TODO.up()
					when 40, 34 # Down, Page Down
						@TODO.down()
					when 36 # Home
						@seek_to_start()
					when 35 # End
						@seek_to_end()
					else
						return # don't prevent default
			
			e.preventDefault()
	
	componentWillUnmount: ->
		@pause()
		window.removeEventListener "keydown", @keydown_listener
	
	render: ->
		{tracks, selection, position, position_time, playing} = @state
		{themes, set_theme} = @props
		
		E ".audio-editor",
			className: {playing}
			tabIndex: 0
			style: outline: "none"
			onMouseDown: (e)=>
				return if e.isDefaultPrevented()
				e.preventDefault()
				React.findDOMNode(@).focus()
			onDragOver: (e)=>
				return if e.isDefaultPrevented()
				e.preventDefault()
				e.dataTransfer.dropEffect = "copy"
				@deselect()
			onDrop: (e)=>
				return if e.isDefaultPrevented()
				e.preventDefault()
				for file in e.dataTransfer.files
					@add_clip file
			E Controls, {playing, editor: @, themes, set_theme, key: "controls"}
			E "div",
				key: "infobar"
				E InfoBar # @TODO, ref: (@infobar)=>
			E Tracks, {tracks, selection, position, position_time, playing, editor: @, key: "tracks"}
