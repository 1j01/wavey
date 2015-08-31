
class @AudioClip extends E.Component
	render: ->
		E ".audio-clip", style: @props.style,
			E "canvas", ref: "canvas", height: 80, width: 2000 # 80 = .track-content {height}
	renderCanvas: ->
		{data} = @props
		canvas = React.findDOMNode @refs.canvas
		ctx = canvas.getContext "2d"
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.strokeStyle = getComputedStyle(canvas).color
		ctx.beginPath()
		for x in [0..canvas.width] by 0.1
			ctx.lineTo x, canvas.height/2 + canvas.height/2 * (data[~~(x/scale*sampleRate)])
		ctx.stroke()
	componentDidMount: -> @renderCanvas()
	componentDidUpdate: -> @renderCanvas()
	shouldComponentUpdate: (nextProps, nextState)->
		nextProps.data isnt @props.data
		# canvas = React.findDOMNode @refs.canvas
		# ctx = canvas.getContext "2d"
		# if getComputedStyle(canvas).color isnt ctx.strokeStyle
		# 	return yes
