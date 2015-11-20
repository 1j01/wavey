
class @AudioClip extends E.Component
	
	@audio_buffers = {}
	@audio_buffers_loading = {}
	
	@load_clip = (clip)=>
		return if clip.recording_id
		return if AudioClip.audio_buffers[clip.audio_id]?
		return if AudioClip.audio_buffers_loading[clip.audio_id]?
		
		AudioClip.audio_buffers_loading[clip.audio_id] = yes
		
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
		{clip, data, sample_rate, style} = @props
		{length} = clip
		if data instanceof Array and data[0][0]?
			one_channel = data[0]
			num_chunks = one_channel.length
			chunk_size = one_channel[0].length
			console.log "AudioClip::render", {num_chunks, chunk_size, sample_rate}
			length = chunk_size * num_chunks / sample_rate
		E ".audio-clip", {style},
			E "canvas",
				ref: "canvas"
				height: 80 # = .track-content {height}
				width: length * scale
	
	renderCanvas: ->
		canvas = React.findDOMNode @refs.canvas
		ctx = canvas.getContext "2d"
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.strokeStyle = @color = getComputedStyle(canvas).color
		
		{clip, data, sample_rate} = @props
		{offset} = clip
		offset ?= 0
		
		# @TODO: visualize multiple channels
		
		if data instanceof Array
			typed_arrays = data[0]
			at = (x)->
				len = typed_arrays[0]?.length
				idx = ~~((x/scale + offset) * sample_rate)
				# console.log idx, len, idx // len
				typed_arrays[idx // len]?[idx % len]
		else if data
			audio_buffer = data
			typed_array = audio_buffer.getChannelData 0
			at = (x)->
				typed_array[~~((x/scale + offset) * sample_rate)]
		
		if at?
			ctx.beginPath()
			for x in [0..canvas.width] by 0.1
				ctx.lineTo x, canvas.height/2 + canvas.height/2 * at(x)
			ctx.stroke()
		else
			ctx.save()
			ctx.lineWidth = 5
			ctx.setLineDash [5, 15]
			ctx.beginPath()
			ctx.moveTo 0, canvas.height/2
			ctx.lineTo canvas.width, canvas.height/2
			ctx.stroke()
			ctx.restore()
	
	componentDidMount: ->
		@renderCanvas()
		@rerenderCanvasWhenTheStylesChange()
	
	componentDidUpdate: (last_props)->
		@renderCanvas() if (
			@props.data isnt last_props.data or
			(@props.clip.recording_id? and @props.data?[0]?.length isnt last_props.data?[0]?.length) or # @TODO: only if actively recording
			@props.clip.offset isnt last_props.clip.offset or
			@props.clip.length isnt last_props.clip.length
		)
	
	componentWillUnmount: ->
		clearTimeout @tid
		cancelAnimationFrame @animation_frame
	
	rerenderCanvasWhenTheStylesChange: ->
		@tid = setTimeout =>
			@animation_frame = requestAnimationFrame =>
				canvas = React.findDOMNode @refs.canvas
				ctx = canvas.getContext "2d"
				@renderCanvas() if getComputedStyle(canvas).color isnt @color
				@rerenderCanvasWhenTheStylesChange()
		, 100
