
{E, Component, GUID, get_clip_start_end, normal_tracks_in} = require "../helpers.coffee"
{document_version, stuff_version} = require "../versions.coffee"
export_audio_buffer_as = require "../export.coffee"
ReactDOM = require "react-dom"
Controls = require "./Controls.coffee"
InfoBar = require "./InfoBar.coffee"
TracksArea = require "./TracksArea.coffee"
audio_clips = require "../audio-clips.coffee"
Range = require "../Range.coffee" # should I rename this AudioRange? (there's a DOM thing called Range)
localforage = require "localforage"
webmidi = require "webmidi"
# async = require "async"

class exports.AudioEditor extends Component
	
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
			playback_sources: []
			position: null
			position_time: null
			scale: 90
			selection: null
			recording: no
			audio_stream: null
			midi_inputs: []
			precording_enabled: no
			moving_selection: no
		
		@_setup_midi =>
			do update_inputs = =>
				@setState midi_inputs: webmidi.inputs
			webmidi.addListener "connected", update_inputs
			webmidi.addListener "disconnected", update_inputs
	
	save: ->
		{document_id} = @props
		{tracks, selection, undos, redos} = @state
		doc = {
			version: document_version
			state: {tracks, selection}
			undos, redos
		}
		localforage.setItem "document:#{document_id}", doc, (err)=>
			if err
				InfoBar.warn "Failed to save the document.\n#{err.message}"
				console.error err
			else
				render()
	
	load: ->
		{document_id} = @props
		localforage.getItem "document:#{document_id}", (err, doc)=>
			if err
				InfoBar.warn "Failed to load the document.\n#{err.message}"
				console.error err
			else if doc
				if not doc.version?
					InfoBar.warn "This document was created before document storage was even versioned. It cannot be loaded."
					return
				if doc.version > document_version
					InfoBar.warn "This document was created with a later version of the editor. Reload to get the latest version."
					return
				if doc.version < document_version
					
					# upgrading code goes here
					# for backwards compatible changes, the version number can simply be incremented
					
					upgrade = (fn)->
						fn doc.state
						fn state for state in doc.undos
						fn state for state in doc.redos
					
					if doc.version is 1
						doc.version++ # recordings added
					
					if doc.version is 2
						doc.version++ # pinned tracks mean the tracks aren't necessarily in order, so selections now use a list of track_ids
						upgrade (state)->
							if state.selection
								{track_a, track_b} = state.selection
								min_track_index = Math.min track_a, track_b
								max_track_index = Math.max track_a, track_b
								state.selection.track_ids = (track.id for track, track_index in state.tracks when min_track_index <= track_index <= max_track_index)
								delete state.selection.track_a
								delete state.selection.track_b
					
					if doc.version is 3
						doc.version++ # clip.time renamed to clip.position
						upgrade (state)->
							for track in state.tracks when track.type is "audio"
								for clip in track.clips
									clip.position = clip.time
									delete clip.time
					
					unless doc.version is document_version
						InfoBar.warn "This document was created with an earlier version of the editor. There is no upgrade path as of yet, sorry."
						return
				
				{state, undos, redos} = doc
				{tracks, selection} = state
				@setState {tracks, undos, redos}
				@select Range.fromJSON selection if selection?
	
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
		@select Range.fromJSON selection if selection?
	
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
		@select Range.fromJSON selection if selection?
	
	# @TODO: soft undo/redo
	
	get_max_length: ->
		{tracks} = @state
		
		max_length = 0
		for track in tracks when track.type is "audio"
			for clip in track.clips
				if clip.recording_id
					recording = audio_clips.recordings[clip.recording_id]
					if recording
						max_length = Math.max max_length, clip.position + (clip.length ? recording.length ? 0)
					else
						InfoBar.warn "Not all tracks have finished loading."
						return
				else
					audio_buffer = audio_clips.audio_buffers[clip.audio_id]
					if audio_buffer
						max_length = Math.max max_length, clip.position + clip.length
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
	
	seek: (position, e)=>
		
		if isNaN position
			InfoBar.warn "Tried to seek to invalid position: #{position}"
			throw new Error "Tried to seek to invalid position: #{position}"
		
		position = Math.max 0, position
		max_length = @get_max_length()
		
		{playing, recording, selection} = @state
		
		return if recording
		
		if playing and max_length? and position < max_length
			@play_from position
			@setState {recording}
		else
			@pause()
			@setState
				position_time: actx.currentTime
				position: position
		
		if selection?
			if e?.shiftKey
				@select_to_position position
			else if selection.length() is 0
				@select_position position
	
	seek_to_start: (e)=>
		@seek 0, e
	
	seek_to_end: (e)=>
		end = @get_max_length()
		return unless end?
		@seek end, e
	
	play: =>
		@play_from @state.position ? 0
	
	play_from: (from_position)=>
		@pause() if @state.playing
		
		max_length = @get_max_length()
		unless @state.recording
			return unless max_length?
			
			if from_position >= max_length or from_position < 0
				from_position = 0
		
		@setState
			tid: unless @state.recording then setTimeout @pause, (max_length - from_position) * 1000 + 20
			# NOTE: an extra few ms because it shouldn't fade out prematurely
			# (even though it might sound better, it might lead you to believe
			# your audio doesn't need a brief fade out at the end when it does)
			
			position_time: actx.currentTime
			position: from_position
			
			playing: yes
			playback_sources: @_schedule_playback from_position, actx
	
	_schedule_playback: (from_position, actx)->
		include_metronome = not (actx instanceof OfflineAudioContext)
		
		{tracks} = @state
		
		playback_sources = []
		
		for track in tracks when track.type is "audio" and not track.muted
			for clip in track.clips
				loaded =
					if clip.recording_id
						audio_clips.recordings[clip.recording_id]?.chunks?
					else
						audio_clips.audio_buffers[clip.audio_id]?
				unless loaded
					InfoBar.warn "Not all tracks have finished loading."
					throw new Error "Not all tracks have finished loading."
				
		for track in tracks when not track.muted
			switch track.type
				when "beat"
					unless include_metronome
						# @TODO: metronome
						continue
				when "audio"
					for clip in track.clips
						source = actx.createBufferSource()
						source.gain = actx.createGain()
						
						if clip.recording_id
							recording = audio_clips.recordings[clip.recording_id]
							unless recording.audio_buffer?
								if recording.chunks[0]?.length
									recording.audio_buffer = actx.createBuffer recording.chunks.length, recording.chunks[0].length * recording.chunks[0][0].length, recording.sample_rate
									for channel, channel_index in recording.chunks
										for chunk, chunk_index in channel
											recording.audio_buffer.copyToChannel chunk, channel_index, chunk_index * chunk.length
							if recording.audio_buffer?
								source.buffer = recording.audio_buffer
							clip_length = clip.length ? recording.length
						else
							source.buffer = audio_clips.audio_buffers[clip.audio_id]
							clip_length = clip.length
						
						source.connect source.gain
						source.gain.connect actx.destination
						
						start_time = actx.currentTime + Math.max(0, clip.position - from_position)
						starting_offset_into_clip = Math.max(0, from_position - clip.position) + clip.offset
						length_to_play_of_clip = clip_length - Math.max(0, from_position - clip.position)
						
						if length_to_play_of_clip > 0
							source.start start_time, starting_offset_into_clip, length_to_play_of_clip
							playback_sources.push source
		
		playback_sources
	
	pause: =>
		clearTimeout @state.tid
		for source in @state.playback_sources
			source?.stop actx.currentTime + 1.0
			source?.gain.gain.value = 0
		@end_recording()
		@setState
			position_time: actx.currentTime
			position: @get_current_position()
			playing: no
			playback_sources: []
	
	update_playback: =>
		if @state.playing
			@seek @get_current_position()
	
	end_recording: =>
		# method overridden by @record
	
	_get_audio_stream: (success_callback)=>
		if @state.audio_stream
			return success_callback(@state.audio_stream)
		
		navigator.mediaDevices.getUserMedia audio: yes
			.then (stream)=>
				success_callback(stream)
			.catch (error)=>
				switch error.name
					when "PermissionDeniedError", "PermissionDismissedError"
						return
					when "NotFoundError", "DevicesNotFoundError"
						InfoBar.warn "No recording devices were found."
					when "SourceUnavailableError"
						InfoBar.warn "No available recording devices were found. Is one in use?"
					else
						InfoBar.warn "Failed to start recording: #{error.name}" + if error.message then ": #{error.message}" else ""
				console.error "navigator.mediaDevices.getUserMedia", error
	
	_setup_midi: (success_callback)=>
		webmidi.enable (error)=>
			if error
				unless error.message?.match(/The Web MIDI API is not supported/)
					InfoBar.warn "Failed gain MIDI access: #{error.name}" + if error.message then ": #{error.message}" else ""
				console.warn "webmidi could not be enabled.", error
			else
				console?.log "webmidi enabled!"
				success_callback()
	
	_find_places_to_record: (wanted_track_types, mutable_tracks)=>
		{selection} = @state
		# for now at least we'll try to do behavior where
		# if we can't place each recording where the selection is
		# we'll just add new tracks for each recording
		# we might keep this behavior, especially because you would want it to scroll to the tracks where you're recording,
		# so you wouldn't want it to start recording one track at your selection and another at the bottom
		
		tracks_to_use_by_type = {}
		tracks_to_use = []
		
		if selection?
			start_position = selection.start()
			
			# available_tracks = (track for track in @get_sorted_tracks(mutable_tracks) when selection.containsTrack(track))
			available_tracks_by_type = {}
			for track in @get_sorted_tracks(mutable_tracks) when selection.containsTrack(track)
				available_tracks_by_type[track.type] ?= []
				available_tracks_by_type[track.type].push(track)
			
			for track_type in wanted_track_types
				if available_tracks_by_type[track_type]?[0]?
					track = available_tracks_by_type[track_type].shift()
					switch track.type
						when "audio"
							for clip in track.clips
								{clip_start, clip_end} = get_clip_start_end clip
								if clip_end > start_position
									track = null
						when "midi"
							for note in track.notes
								if note.t + note.length > start_position
									track = null
						else
							throw new Error "Unhandled recording track type #{track_type}"
					if track?
						tracks_to_use_by_type[track.type] ?= []
						tracks_to_use_by_type[track_type].push(track)
						tracks_to_use.push(track)
		
		if tracks_to_use.length < wanted_track_types.length
			tracks_to_use_by_type = {}
			tracks_to_use = []
			start_position ?= 0
			
			for track_type in wanted_track_types
				switch track_type
					when "audio"
						track = {id: GUID(), type: "audio", clips: []}
					when "midi"
						track = {id: GUID(), type: "midi", notes: []}
					else
						throw new Error "Unhandled recording track type #{track_type}"
				mutable_tracks.push track
				tracks_to_use_by_type[track.type] ?= []
				tracks_to_use_by_type[track_type].push(track)
				tracks_to_use.push(track)
		
		if start_position > 0
			@select_position start_position, (track.id for track in tracks_to_use)

		{start_position, tracks_to_use_by_type}
	
	record_midi: (midi_input)=>
		return if @state.recording
		
		# recording_id = GUID()
		# @undoable (tracks)=>
			# {start_position, tracks_to_use_by_type} = @_find_places_to_record(["midi"], tracks)
			# [track] = tracks_to_use_by_type.midi
			
			# console?.log track
		InfoBar.warn "MIDI recording is not yet implemented"
	
	record: =>
		# TODO: you should actually while recording be able to start recording with more (or less) devices
		return if @state.recording
		# wanted_track_types = ["audio", "midi"]
		# tracks_to_use_by_type = _find_places_to_record(wanted_track_types)
		# console.log {wanted_track_types, tracks_to_use_by_type}
		
		# audio_stream = null
		# midi_inputs = []
		
		@_get_audio_stream (stream)=>
			recording_id = GUID()
			@undoable (tracks)=>
				{start_position, tracks_to_use_by_type} = @_find_places_to_record(["audio"], tracks)
				[track] = tracks_to_use_by_type.audio
				
				clip =
					id: GUID()
					audio_id: recording_id
					recording_id: recording_id
					position: start_position
					offset: 0
				
				track.clips.push clip
				
				source = actx.createMediaStreamSource stream
				
				recording =
					id: recording_id
					chunks: [[], []]
					chunk_ids: [[], []]
					length: 0
				
				audio_clips.recordings[clip.recording_id] = recording
				audio_clips.loading[clip.audio_id] = yes
				
				current_chunk = 0
				chunk_size = 2 ** 14 # samples (2 to an integer power between 8 and 14 inclusive)
				
				ended = no
				final_recording_length = undefined
				
				recorder = actx.createScriptProcessor chunk_size, 2, if chrome? then 1 else 0
				recorder.onaudioprocess = (e)=>
					
					console?.log "onaudioprocess", if ended then "(final)" else ""
					
					recording.sample_rate = e.inputBuffer.sampleRate
					
					chunks = []
					chunk_ids = []
					for i in [0...e.inputBuffer.numberOfChannels]
						# new Float32Array necessary in chrome
						data = new Float32Array e.inputBuffer.getChannelData i
						chunks.push recording.chunks[i].concat [data]
						chunk_ids.push recording.chunk_ids[i].concat [chunk_id = GUID()]
						do (chunk_id, data)=>
							localforage.setItem "recording:#{recording_id}:chunk:#{chunk_id}", data, (err)=>
								if err
									InfoBar.warn "Failing to store recording! #{err.message}"
									console.error "Failed to store recording chunk", err
					recording.chunks = chunks
					recording.chunk_ids = chunk_ids
					recording.length = final_recording_length ? chunk_ids[0].length * data.length / recording.sample_rate
					
					save = =>
						localforage.setItem "recording:#{clip.recording_id}", {
							id: recording.id
							sample_rate: recording.sample_rate
							chunk_ids: recording.chunk_ids
							length: recording.length
						}, (err)=>
							if err
								InfoBar.warn "Failing to store recording! #{err.message}"
								console.error "Failed to store recording metadata", err
					
					@end_recording = =>
						return if ended
						console.log "last recording.length", recording.length
						final_recording_length = recording.length = @get_current_position() - start_position
						console.log "final_recording_length", final_recording_length
						save()
						ended = yes
						@setState
							recording: no
							position: start_position + final_recording_length
							position_time: actx.currentTime
					
					if ended
						source.disconnect()
						recorder.disconnect()
						delete window["chrome bug workaround (#{recording_id})"]
						console?.log "ended recording"
					
					save()
					render()
				
				source.connect recorder
				# TODO: Are these chrome hacks still necessary?
				recorder.connect actx.destination if chrome?
				# http://stackoverflow.com/questions/24338144/chrome-onaudioprocess-stops-getting-called-after-a-while
				if chrome? then window["chrome bug workaround (#{recording_id})"] = recorder
				
				@setState
					recording: yes
					audio_stream: stream
					=> @play_from start_position
	
	stop_recording: =>
		@pause()
	
	precord: (seconds_back_in_time_woo_time_travel)=>
		InfoBar.warn "Precording is not yet implemented"
	
	enable_precording: (seconds)=>
		InfoBar.warn "Sorry, precording is not yet implemented"
	
	select: (selection)=>
		@setState {selection}
	
	select_to: (to_position, to_track_id)=>
		{tracks, selection} = @state
		to_position = Math.max(0, to_position)
		# TODO: this should be way simpler
		sorted_tracks = @get_sorted_tracks tracks
		from_track = track for track in sorted_tracks when track.id is selection.firstTrackID()
		to_track = track for track in sorted_tracks when track.id is to_track_id
		include_tracks =
			if sorted_tracks.indexOf(from_track) < sorted_tracks.indexOf(to_track)
				sorted_tracks.slice sorted_tracks.indexOf(from_track), sorted_tracks.indexOf(to_track) + 1
			else
				sorted_tracks.slice sorted_tracks.indexOf(to_track), sorted_tracks.indexOf(from_track) + 1
		track_ids = [selection.firstTrackID()].concat(track.id for track in include_tracks when track.id isnt selection.firstTrackID())
		@select_to_position to_position, track_ids
	
	select_position: (position, track_ids)=>
		{selection} = @state
		@select new Range position, position, track_ids ? selection?.track_ids ? []
	
	select_to_position: (position, track_ids)=>
		{selection} = @state
		@select new Range selection.a, position, track_ids ? selection?.track_ids ? []
	
	deselect: =>
		@select null
	
	select_all: =>
		{tracks} = @state
		max_length = @get_max_length()
		return unless max_length?
		@select new Range 0, max_length, (track.id for track in tracks)
	
	select_vertically: (direction, e)=>
		{tracks, selection} = @state
		return unless selection
		sorted_tracks = normal_tracks_in @get_sorted_tracks tracks
		switch direction
			when "up"
				selected_track_id = selection.firstTrackID(sorted_tracks)
				delta = -1
			when "down"
				selected_track_id = selection.lastTrackID(sorted_tracks)
				delta = +1
		for track, track_index in sorted_tracks
			break if track.id is selected_track_id
		next_selected_track_id = sorted_tracks[track_index + delta]?.id
		if e?.shiftKey
			@select new Range selection.a, selection.b, selection.track_ids.concat(next_selected_track_id) if next_selected_track_id
		else
			@select new Range selection.a, selection.b, [next_selected_track_id ? selected_track_id]
	
	select_horizontally: (delta_seconds)->
		{selection} = @state
		max_length = @get_max_length()
		return unless max_length?
		to = Math.max(0, Math.min(max_length, selection.b + delta_seconds))
		@select_to_position to
	
	select_up: (e)=>
		@select_vertically "up", e
	
	select_down: (e)=>
		@select_vertically "down", e
	
	delete: =>
		{selection} = @state
		return unless selection?.length()
		
		@undoable (tracks)=>
			collapsed = selection.collapse tracks
			@select collapsed
			@seek collapsed.start()
	
	copy: =>
		{selection, tracks} = @state
		return unless selection?.length()
		sorted_tracks = @get_sorted_tracks tracks
		localforage.setItem "clipboard", selection.contents(sorted_tracks), (err)=>
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
			else if clipboard?
				
				if not clipboard.version?
					InfoBar.warn "The clipboard data does not appear to contain a version number. It cannot be pasted."
					console.warn "clipboard:", clipboard
					return
				if clipboard.version > stuff_version
					InfoBar.warn "The clipboard data was copied from a later version of the editor. Reload to get the latest version."
					return
				if clipboard.version < stuff_version
					# upgrading code should go here
					# for backwards compatible changes, the version number can simply be incremented
					
					if clipboard.version is 1
						clipboard.version += 1 # recordings added
					
					if clipboard.version is 2
						clipboard.version += 1 # renamed clip.time to clip.position
						for row in clipboard.rows
							for clip in row
								clip.position = clip.time
								delete clip.time
					
					if clipboard.version < stuff_version
						InfoBar.warn "The clipboard data was copied from an earlier version of the editor. There is no upgrade path as of yet, sorry."
						return
				
				@undoable (tracks)=>
					{selection} = @state
					sorted_tracks = @get_sorted_tracks tracks
					
					if selection?
						# @TODO: handle excess selected tracks better
						# (currently it collapses the entire selection, but only inserts as many rows as are in the clipboard)
						collapsed_selection = selection.collapse tracks
						track_id = collapsed_selection.firstTrackID(sorted_tracks)
						position = collapsed_selection.start()
					else
						track_id = null
						position = 0
					after = Range.insert clipboard, position, track_id, tracks, sorted_tracks
					@select after
	
	insert: (stuff, position, track_id)->
		@undoable (tracks)=>
			sorted_tracks = @get_sorted_tracks tracks
			Range.insert stuff, position, track_id, tracks, sorted_tracks
	
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
				if selection?.containsTrack track
					updated_selection = new Range selection.a, selection.b, (track_id for track_id in selection.track_ids when track_id isnt track.id)
					if updated_selection.length
						@select updated_selection
					else
						@deselect()
	
	add_clip: (file, at_selection)->
		{document_id} = @props
		if at_selection
			{selection} = @state
			return unless selection?
		reader = new FileReader
		reader.onload = (e)=>
			array_buffer = e.target.result
			clip = {id: GUID(), audio_id: GUID(), position: 0, offset: 0}
			
			audio_clips.loading[clip.audio_id] = yes
			
			localforage.setItem "audio:#{clip.audio_id}", array_buffer, (err)=>
				if err
					InfoBar.warn "Failed to store audio data.\n#{err.message}"
					console.error err
				else
					# @TODO: optimize by decoding and storing in parallel, but keep good error handling
					actx.decodeAudioData array_buffer, (buffer)=>
						audio_clips.audio_buffers[clip.audio_id] = buffer
						
						clip.length = buffer.length / buffer.sampleRate
						
						stuff = {version: stuff_version, rows: [[clip]], length: clip.length}
						if at_selection
							@insert stuff, selection.start(), selection.firstTrackID()
						else
							@insert stuff, 0
			, (e)=>
				InfoBar.warn "Audio not playable or not supported."
				console.error e
		
		reader.onerror = (e)=>
			InfoBar.warn "Failed to read audio file."
			console.error e
		
		reader.readAsArrayBuffer file
	
	get_sorted_tracks: (tracks)=>
		track_els = ReactDOM.findDOMNode(@).querySelectorAll ".track"
		track_positions = (track_el.getBoundingClientRect().top for track_el in track_els)
		track_positions = {}
		for track_el in track_els
			track_positions[track_el.dataset.trackId] = track_el.getBoundingClientRect().top
		tracks.slice().sort (track_a, track_b)->
			track_positions[track_a.id] - track_positions[track_b.id]
	
	import_files: =>
		input = document.createElement "input"
		input.type = "file"
		input.multiple = yes
		input.accept = "audio/*"
		input.addEventListener "change", (e)=>
			# TODO: add tracks in the order we get them, not by how long each clip takes to load
			# do it by making loading state placeholder track/clip representations
			# also DRY with code in TracksArea
			for file in e.target.files
				@add_clip file
		input.click()
	
	export_as: (file_type, range)=>
		sample_rate = 44100
		if range?
			start = range.start()
			length = range.length()
		else
			start = 0
			length = @get_max_length()
		number_of_channels = 2
		oactx = new OfflineAudioContext number_of_channels, sample_rate * length, sample_rate
		@_schedule_playback start, oactx
		oactx.startRendering()
			.then (rendered_audio_buffer)=>
				export_audio_buffer_as rendered_audio_buffer, file_type
	
	componentDidUpdate: (last_props, last_state)=>
		{document_id} = @props
		{tracks, selection, undos, redos, moving_selection} = @state
		
		if (
			tracks isnt last_state.tracks or
			(selection isnt last_state.selection and not moving_selection) or
			undos isnt last_state.undos or
			redos isnt last_state.redos
		)
			@save()
		
		if tracks isnt last_state.tracks
			@update_playback()
			audio_clips.load_clips tracks, InfoBar
	
	componentDidMount: =>
		
		@load()
		
		window.addEventListener "keydown", @keydown_listener = (e)=>
			return if e.defaultPrevented
			return if e.altKey
			
			seek_or_select = (delta_seconds)=>
				if e.shiftKey
					@select_horizontally(delta_seconds)
				else
					@seek(@get_current_position() + delta_seconds)
			
			page = (delta_pages)=>
				track_content_area = ReactDOM.findDOMNode(@).querySelector(".track-content-area")
				track_content_area.scrollLeft += track_content_area.clientWidth * delta_pages
			
			if e.ctrlKey
				switch e.keyCode
					when 65 # A
						@select_all() unless e.shiftKey
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
						if @state.recording
							@stop_recording()
						else
							@record()
					# @TODO: finer control
					when 37 # Left
						seek_or_select(-1)
					when 39 # Right
						seek_or_select(+1)
					when 33 # Page Up
						page(-1)
					when 34 # Page Down
						page(+1)
					when 38 # Up
						@select_up e
					when 40 # Down
						@select_down e
					when 36 # Home
						@seek_to_start e
					when 35 # End
						@seek_to_end e
					else
						return # don't prevent default
			
			e.preventDefault()
	
	componentWillUnmount: ->
		@pause()
		window.removeEventListener "keydown", @keydown_listener
	
	render: ->
		{tracks, selection, position, position_time, scale, playing, recording, precording_enabled} = @state
		{themes, set_theme} = @props
		E ".audio-editor",
			className: {playing}
			tabIndex: 0
			role: "application"
			style: outline: "none"
			onMouseDown: (e)=>
				return if e.isDefaultPrevented()
				if e.target.closest("button")
					# prevent focusing the button when clicking with the mouse
					# but don't preventDefault because that breaks :active in Firefox
					setTimeout => ReactDOM.findDOMNode(@).focus()
					return
				return if e.target.closest("p")
				unless e.button > 0
					e.preventDefault()
				ReactDOM.findDOMNode(@).focus()
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
			onWheel: (e)=>
				if e.ctrlKey
					e.preventDefault()
					if e.deltaY > 0
						@setState scale: @state.scale * 0.75
					else
						@setState scale: @state.scale / 0.75
			E Controls, {playing, recording, selection, precording_enabled, themes, set_theme, editor: @, key: "controls"}
			E "div",
				key: "infobar"
				E InfoBar #, ref: (@infobar)=> # @TODO: instanced InfoBar API
			E TracksArea, {tracks, selection, position, position_time, scale, playing, editor: @, key: "tracks-area"}
