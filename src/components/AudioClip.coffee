
class @AudioClip extends E.Component
	
	@audio_buffers_by_clip_id = {}
	
	@load_clip = (clip_id, document_id)=>
		return if AudioClip.audio_buffers_by_clip_id[clip_id]?
		localforage.getItem "#{document_id}/#{clip_id}", (err, array_buffer)=>
			if err
				alert "Failed to load audio data.\n#{err.message}"
				console.error err
			else if array_buffer
				actx.decodeAudioData array_buffer, (buffer)=>
					AudioClip.audio_buffers_by_clip_id[clip_id] = buffer
					remove_alert "Not all tracks have finished loading."
					render()
			else
				alert "An audio clip is missing from storage."
				console.warn "An audio clip is missing from storage.", clip_id
	
	@load_clips = (tracks, document_id)->
		for track in tracks
			for clip in track.clips
				@load_clip clip.id, document_id
	
	render: ->
		E ".audio-clip", style: @props.style,
			E "canvas",
				ref: "canvas"
				height: 80 # = .track-content {height}
				width: 2000
	
	renderCanvas: ->
		audio_buffer = @props.data
		canvas = React.findDOMNode @refs.canvas
		ctx = canvas.getContext "2d"
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.strokeStyle = @color = getComputedStyle(canvas).color
		
		if audio_buffer
			# @TODO: visualize multiple channels?
			data = audio_buffer.getChannelData 0
			
			ctx.beginPath()
			for x in [0..canvas.width] by 0.1
				ctx.lineTo x, canvas.height/2 + canvas.height/2 * (data[~~(x/scale*audio_buffer.sampleRate)])
			ctx.stroke()
	
	componentDidMount: ->
		@renderCanvas()
		@rerenderCanvasWhenTheStylesChange()
	
	componentDidUpdate: ->
		@renderCanvas()
	
	componentWillUnmount: ->
		clearTimeout @tid
		cancelAnimationFrame @animation_frame
	
	shouldComponentUpdate: (nextProps, nextState)->
		nextProps.data isnt @props.data
	
	rerenderCanvasWhenTheStylesChange: ->
		@tid = setTimeout =>
			@animation_frame = requestAnimationFrame =>
				canvas = React.findDOMNode @refs.canvas
				ctx = canvas.getContext "2d"
				@renderCanvas() if getComputedStyle(canvas).color isnt @color
				@rerenderCanvasWhenTheStylesChange()
		, 100
