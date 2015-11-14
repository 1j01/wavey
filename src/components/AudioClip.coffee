
class @AudioClip extends E.Component
	
	@audio_buffers = {}
	
	@load_clip = (clip, document_id)=>
		return if AudioClip.audio_buffers[clip.audio_id]?
		localforage.getItem "#{document_id}/#{clip.audio_id}", (err, array_buffer)=>
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
	
	@load_clips = (tracks, document_id)->
		for track in tracks when track.type is "audio"
			for clip in track.clips
				@load_clip clip, document_id
	
	render: ->
		E ".audio-clip", style: @props.style,
			E "canvas",
				ref: "canvas"
				height: 80 # = .track-content {height}
				width: @props.clip.length * scale
	
	renderCanvas: ->
		audio_buffer = @props.data
		canvas = React.findDOMNode @refs.canvas
		ctx = canvas.getContext "2d"
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.strokeStyle = @color = getComputedStyle(canvas).color
		
		if audio_buffer
			# @TODO: visualize multiple channels?
			data = audio_buffer.getChannelData 0
			offset = @props.clip.offset
			
			ctx.beginPath()
			for x in [0..canvas.width] by 0.1
				ctx.lineTo x, canvas.height/2 + canvas.height/2 * (data[~~((x/scale + offset)*audio_buffer.sampleRate)])
			ctx.stroke()
	
	componentDidMount: ->
		@renderCanvas()
		@rerenderCanvasWhenTheStylesChange()
	
	componentDidUpdate: ->
		@renderCanvas()
		# @TODO: rerender only when data changed (shouldComponentUpdate can go)
	
	componentWillUnmount: ->
		clearTimeout @tid
		cancelAnimationFrame @animation_frame
	
	shouldComponentUpdate: (nextProps, nextState)->
		nextProps.data isnt @props.data or
		nextProps.style.left isnt @props.style.left
	
	rerenderCanvasWhenTheStylesChange: ->
		@tid = setTimeout =>
			@animation_frame = requestAnimationFrame =>
				canvas = React.findDOMNode @refs.canvas
				ctx = canvas.getContext "2d"
				@renderCanvas() if getComputedStyle(canvas).color isnt @color
				@rerenderCanvasWhenTheStylesChange()
		, 100
