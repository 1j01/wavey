
{E} = require "../helpers.coffee"
InfoBar = require "./InfoBar.coffee"

localforage = require "localforage"

module.exports =
class AudioClip extends E.Component
	
	@audio_buffers = {}
	@recordings = {}
	@loading = {}
	
	throttle = 0
	
	@load_clip = (clip)=>
		return if AudioClip.audio_buffers[clip.audio_id]?
		return if AudioClip.loading[clip.audio_id]?
		
		AudioClip.loading[clip.audio_id] = yes
		
		if clip.recording_id?
			localforage.getItem "recording:#{clip.recording_id}", (err, recording)=>
				if err
					InfoBar.error "Failed to load recording.\n#{err.message}"
					throw err
				else if recording
					AudioClip.recordings[clip.recording_id] = recording
					chunks = [[], []]
					loaded = 0
					for channel_chunk_ids, channel_index in recording.chunk_ids
						for chunk_id, chunk_index in channel_chunk_ids
							do (channel_chunk_ids, channel_index, chunk_id, chunk_index)=>
								# timeout because of DOMException: The transaction was aborted, so the request cannot be fulfilled.
								# Internal error: Too many transactions queued.
								# https://code.google.com/p/chromium/issues/detail?id=338800
								setTimeout ->
									localforage.getItem "recording:#{clip.recording_id}:chunk:#{chunk_id}", (err, typed_array)=>
										if err
											InfoBar.error "Failed to load part of a recording.\n#{err.message}"
											throw err
										else if typed_array
											chunks[channel_index][chunk_index] = typed_array
											loaded += 1
											throttle -= 1 # this will not unthrottle anything during the document load
											if loaded is recording.chunk_ids.length * channel_chunk_ids.length
												recording.chunks = chunks
												render()
										else
											InfoBar.warn "Part of a recording is missing from storage."
											console.warn "A chunk of a recording (#{chunk_id}) is missing from storage.", clip, recording
								, throttle += 1
				else
					InfoBar.warn "A recording is missing from storage."
					console.warn "A recording is missing from storage.", clip
		else
			localforage.getItem "audio:#{clip.audio_id}", (err, array_buffer)=>
				if err
					InfoBar.error "Failed to load audio data.\n#{err.message}"
					throw err
				else if array_buffer
					actx.decodeAudioData array_buffer, (buffer)=>
						AudioClip.audio_buffers[clip.audio_id] = buffer
						InfoBar.hide "Not all tracks have finished loading."
						render()
				else
					InfoBar.warn "An audio clip is missing from storage."
					console.warn "An audio clip is missing from storage.", clip
	
	@load_clips = (tracks)->
		for track in tracks when track.type is "audio"
			for clip in track.clips
				@load_clip clip
	
	render: ->
		{data, sample_rate, length, offset, scale, style} = @props
		
		if data instanceof Array
			typed_arrays = data[0]
			chunk_length = typed_arrays[0]?.length
		else if data
			audio_buffer = data
			typed_array = audio_buffer.getChannelData 0
			chunk_length = 500
			typed_arrays =
				for i in [0..data.length] by chunk_length
					typed_array.subarray i, i + chunk_length
		
		width = (length ? 0) * scale
		height = 80 # = .track-content {height}
		
		# @TODO: visualize multiple channels
		
		E "svg.audio-clip", {
			style
			width, height
			data: {length}
			xmlns: "http://www.w3.org/svg/2000"
			viewBox: "0 0 #{width} #{height}"
			# bufferedRendering: "static"
		},
			if width
				at = (x)->
					len = typed_arrays[0]?.length
					idx = ~~((x/scale + offset) * sample_rate)
					typed_arrays[idx // len]?[idx % len]
				
				key = 0
				for chunk_x in [0..width] by chunk_length / scale
					pathdata =
						for x in [0..chunk_length/scale] by 0.1
							y = height * (at(chunk_x + x) + 1) / 2
							"#{if x is 0 then "M" else "L"}#{(chunk_x + x).toFixed(2)} #{~~y}"
					key += 1
					E "path", {key, d: pathdata.join("")}
	
	shouldComponentUpdate: (last_props)->
		@props.data isnt last_props.data or
		@props.offset isnt last_props.offset or
		@props.length isnt last_props.length or
		@props.scale isnt last_props.scale
