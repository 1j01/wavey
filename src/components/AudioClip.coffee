
class @AudioClip extends E.Component
	
	@audio_buffers = {}
	@audio_buffers_loading = {}
	
	@load_clip = (clip, document_id)=>
		return if AudioClip.audio_buffers[clip.audio_id]?
		return if AudioClip.audio_buffers_loading[clip.audio_id]?
		AudioClip.audio_buffers_loading[clip.audio_id] = yes
		
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
