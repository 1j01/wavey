
class @AudioClip extends E.Component
	
	@audio_buffers = {}
	@recordings: {}
	@loading = {}
	
	@load_clip = (clip)=>
		return if AudioClip.audio_buffers[clip.audio_id]?
		return if AudioClip.loading[clip.audio_id]?
		
		AudioClip.loading[clip.audio_id] = yes
		
		if clip.recording_id?
			localforage.getItem "recording:#{clip.recording_id}", (err, recording)=>
				if err
					InfoBar.error "Failed to load recording.\n#{err.message}"
					console.error err
				else if recording
					AudioClip.recordings[clip.recording_id] = recording
					chunks = [[], []]
					loaded = 0
					for channel_chunk_ids, channel_index in recording.chunk_ids
						for chunk_id, chunk_index in channel_chunk_ids
							do (channel_chunk_ids, channel_index, chunk_id, chunk_index)=>
								localforage.getItem "recording:#{clip.recording_id}:chunk:#{chunk_id}", (err, typed_array)=>
									if err
										InfoBar.error "Failed to load part of a recording.\n#{err.message}"
										console.error err
									else if typed_array
										chunks[channel_index][chunk_index] = typed_array
										loaded += 1
										if loaded is recording.chunk_ids.length * channel_chunk_ids.length
											recording.chunks = chunks
											render()
									else
										InfoBar.warn "Part of a recording is missing from storage."
										console.warn "A chunk of a recording (#{chunk_id}) is missing from storage.", clip, recording
				else
					InfoBar.warn "A recording is missing from storage."
					console.warn "A recording is missing from storage.", clip
		else
			localforage.getItem "audio:#{clip.audio_id}", (err, array_buffer)=>
				if err
					InfoBar.error "Failed to load audio data.\n#{err.message}"
					console.error err
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
		{clip, data, sample_rate, length, scale, style} = @props
		{offset} = clip
		offset ?= 0
		
		if data instanceof Array
			typed_arrays = data[0]
			at = (x)->
				len = typed_arrays[0]?.length
				idx = ~~((x/scale + offset) * sample_rate)
				typed_arrays[idx // len]?[idx % len]
		else if data
			audio_buffer = data
			typed_array = audio_buffer.getChannelData 0
			at = (x)->
				typed_array[~~((x/scale + offset) * sample_rate)]
		
		width = length * scale
		height = 80 # = .track-content {height}
		
		if at? and width
			pathdata =
				for x in [0..width] by 0.1
					y = height * (at(x) + 1) / 2
					"#{if x is 0 then "M" else "L"}#{x.toFixed(2)} #{~~y}"
		else
			width = 0
		
		# @TODO: visualize multiple channels
		
		E "svg.audio-clip", {
			style
			width, height
			data: {length}
			xmlns: "http://www.w3.org/svg/2000"
			viewBox: "0 0 #{width} #{height}"
		},
			# @TODO: a path for each chunk for performance when recording
			# maybe even for AudioBuffer clips, as this may dramatically speed up rendering in Firefox and Edge
			# (assuming they have AABB optimizations)
			E "path", d: pathdata.join("") if pathdata?
	
	shouldComponentUpdate: (last_props)->
		@props.data isnt last_props.data or
		(@props.clip.recording_id? and @props.data?[0]?.length isnt last_props.data?[0]?.length) or
		@props.clip.offset isnt last_props.clip.offset or
		@props.length isnt last_props.length or
		@props.scale isnt last_props.scale
