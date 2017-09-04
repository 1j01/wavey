
localforage = require "localforage"

class AudioClipStorage
	constructor: ->
		@audio_buffers = {}
		@recordings = {}
		@loading = {}
		@_errors = {}
		# dependencies to be injected before use
		@InfoBar = null
		@remove_broken_clips = null
		# XXX: I'm sure there's a better way to do this
	
	has_error: (clip)=>
		@_errors[clip.audio_id]
	
	show_error: (clip)=>
		error_message = @_errors[clip.audio_id]
		@InfoBar.warn error_message, [
			{
				label: "Remove broken clips"
				action: @remove_broken_clips
			}
		]
	
	throttle = 0
	
	load_clip: (clip)=>
		
		return if @audio_buffers[clip.audio_id]?
		return if @loading[clip.audio_id]?
		
		@loading[clip.audio_id] = yes
		
		fail_warn = (error_message)=>
			@_errors[clip.audio_id] = error_message
			@show_error(clip)
		
		if clip.recording_id?
			localforage.getItem "recording:#{clip.recording_id}", (err, recording)=>
				if err
					@InfoBar.error "Failed to load recording.\n#{err.message}"
					throw err
				else if recording
					@recordings[clip.recording_id] = recording
					chunks = [[], []]
					total_loaded_chunks = 0
					for channel_chunk_ids, channel_index in recording.chunk_ids
						for chunk_id, chunk_index in channel_chunk_ids
							do (channel_chunk_ids, channel_index, chunk_id, chunk_index)=>
								# throttling to avoid DOMException: The transaction was aborted, so the request cannot be fulfilled.
								# Internal error: Too many transactions queued.
								# https://code.google.com/p/chromium/issues/detail?id=338800
								setTimeout ->
									localforage.getItem "recording:#{clip.recording_id}:chunk:#{chunk_id}", (err, typed_array)=>
										if err
											@InfoBar.error "Failed to load part of a recording.\n#{err.message}"
											throw err
										else if typed_array
											chunks[channel_index][chunk_index] = typed_array
											total_loaded_chunks += 1
											throttle -= 1 # this will not unthrottle anything during the document load
											if total_loaded_chunks is recording.chunk_ids.length * channel_chunk_ids.length
												recording.chunks = chunks
												render()
										else
											fail_warn "Part of a recording is missing from storage."
											console.warn "A chunk of a recording (chunk_id: #{chunk_id}) is missing from storage.", clip, recording
								, throttle += 1
						if channel_chunk_ids.length is 0 and channel_index is recording.chunk_ids.length - 1
							recording.chunks = chunks
							render()
				else
					fail_warn "A recording is missing from storage."
					console.warn "A recording is missing from storage. clip:", clip
		else
			localforage.getItem "audio:#{clip.audio_id}", (err, array_buffer)=>
				if err
					@InfoBar.error "Failed to load audio data.\n#{err.message}"
					throw err
				else if array_buffer
					actx.decodeAudioData array_buffer, (buffer)=>
						@audio_buffers[clip.audio_id] = buffer
						@InfoBar.hide "Not all tracks have finished loading."
						render()
				else
					fail_warn "An audio clip is missing from storage."
					console.warn "An audio clip is missing from storage. clip:", clip
	
	load_clips: (tracks)=>
		for track in tracks when track.type is "audio"
			for clip in track.clips
				@load_clip clip

module.exports = new AudioClipStorage
