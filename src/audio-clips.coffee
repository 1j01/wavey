
localforage = require "localforage"

class AudioClipStorage
	constructor: ->
		# TODO: make these into Maps
		@audio_buffers = {}
		@recordings = {}
		@loading = {}
		@_errors = {}
		@_suggestions = {}
		# dependencies must be injected before use
		# XXX: I'm sure there's a cleaner way of doing this
		@InfoBar = null
		@remove_broken_clips = null
	
	has_error: (clip)=>
		@_errors[clip.audio_id]
	
	show_error: (clip)=>
		error_message = @_errors[clip.audio_id]
		suggestion = @_suggestions[clip.audio_id]
		
		# TODO: instead of taking "suggestions" and desugaring them into buttons,
		# just take buttons in fail_warn, created via sugar functions
		# this will also make the actual error object available for issue reporting
		@InfoBar.warn error_message,
			switch suggestion
				when "remove_broken_clips"
					[{
						label: "Remove broken clips"
						action: @remove_broken_clips
					}]
				when "reload_app"
					[{
						label: "Reload app"
						action: -> location.reload()
					}]
		###
				when "report_issue"
					[{
						label: "Report issue"
						action: ->
							# TODO: actually logging errors automatically would be best
							email_address = "isaiahodhner@gmail.com"
							new_issue_url = "https://github.com/1j01/wavey/issues/new"
							labels = ["Bug", "Error"]
							title = "Error: #{error_message}"
							issue_description = """
								
								<!--
									hint/message to issue-reporter here
									ask for details (ideally steps to reproduce)
									make it clear this won't be included in the message
								-->
								
								```
								#{error}
								```
								
							"""
							email_body = """
								
								[Knowing that the error occurred is most]
								[If you can, please give steps you took before this error occurred] 
								
								
								#{error}
							"""
							
							enc = encodeURIComponent
							labels_qs = ""
							for label, index in labels
								labels_qs += "&" if index > 0
								labels_qs += "labels[]=#{enc label}"
							query_string = "#{labels_qs}&title=#{enc title}&body=#{enc issue_description}"
							new_issue_url = "#{new_issue_url}?#{query_string}"
							email_url = "mailto:${email_address}?subject=#{enc title}&body=#{enc email_body}"
							window.open(new_issue_url)
					}]
		###
	
	throttle = 0
	
	load_clip: (clip)=>
		
		return if @audio_buffers[clip.audio_id]?
		return if @loading[clip.audio_id]?
		return if @_errors[clip.audio_id]?
		
		@loading[clip.audio_id] = yes
		
		fail_warn = (error_message, options={})=>
			{suggestion} = options
			suggestion ?= "remove_broken_clips"
			@_errors[clip.audio_id] = error_message
			@_suggestions[clip.audio_id] = suggestion
			@loading[clip.audio_id] = no
			@show_error(clip)
		
		handle_localforage_error = (error_message, error)=>
			if error instanceof RangeError
				error_message = "We appear to have run out of memory loading the document."
			else
				error_message = "#{error_message} #{error.message}"
			# TODO: issue report button too
			fail_warn error_message, {suggestion: "reload_app"}
		
		if clip.recording_id?
			recording_storage_key = "recording:#{clip.recording_id}"
			localforage.getItem recording_storage_key, (err, recording)=>
				if err
					handle_localforage_error "Failed to load a recording.", err
					console.error "Error loading #{recording_storage_key}"
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
									chunk_storage_key = "recording:#{clip.recording_id}:chunk:#{chunk_id}"
									localforage.getItem chunk_storage_key, (err, typed_array)=>
										if err
											handle_localforage_error "Failed to load part of a recording.", err
											console.error "Error loading a chunk of a recording (key #{chunk_storage_key})", clip, recording
										else if typed_array
											chunks[channel_index][chunk_index] = typed_array
											total_loaded_chunks += 1
											throttle -= 1 # this will not unthrottle anything during the document load
											if total_loaded_chunks is recording.chunk_ids.length * channel_chunk_ids.length
												recording.chunks = chunks
												render()
										else
											fail_warn "Part of a recording is missing from storage."
											console.warn "A chunk of a recording is missing from storage (key #{chunk_storage_key})", clip, recording
								, throttle += 1
						if channel_chunk_ids.length is 0 and channel_index is recording.chunk_ids.length - 1
							recording.chunks = chunks
							render()
				else
					fail_warn "A recording is missing from storage."
					console.warn "A recording is missing from storage (key #{recording_storage_key}) for clip:", clip
		else
			audio_storage_key = "audio:#{clip.audio_id}"
			localforage.getItem audio_storage_key, (err, array_buffer)=>
				if err
					handle_localforage_error "Failed to load audio data.", err
					console.error "Error loading #{audio_storage_key}"
				else if array_buffer
					actx.decodeAudioData array_buffer, (buffer)=>
						@audio_buffers[clip.audio_id] = buffer
						# TODO: um, only hide this if it's all finished?
						@InfoBar.hide "Not all tracks have finished loading."
						render()
				else
					fail_warn "An audio clip is missing from storage."
					console.warn "Audio data is missing from storage (key #{audio_storage_key}) for clip:", clip
	
	load_clips: (tracks)=>
		for track in tracks when track.type is "audio"
			for clip in track.clips
				@load_clip clip

module.exports = new AudioClipStorage
