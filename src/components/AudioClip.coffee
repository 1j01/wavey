
class @AudioClip extends E.Component
	render: ->
		E ".audio-clip", style: @props.style,
			E "canvas", ref: "canvas", height: 80, width: 2000 # 80 = .track-content {height}
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
	componentDidMount: -> @renderCanvas(); @rerenderCanvasWhenTheStylesChange()
	componentDidUpdate: -> @renderCanvas()
	shouldComponentUpdate: (nextProps, nextState)->
		nextProps.data isnt @props.data
	rerenderCanvasWhenTheStylesChange: ->
		# @TODO: clearTimeout on componentWillUnmount
		setTimeout =>
			requestAnimationFrame =>
				canvas = React.findDOMNode @refs.canvas
				ctx = canvas.getContext "2d"
				@renderCanvas() if getComputedStyle(canvas).color isnt @color
				@rerenderCanvasWhenTheStylesChange()
		, 100
