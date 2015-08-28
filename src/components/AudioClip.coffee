
class @AudioClip extends E.Component
	render: ->
		E ".audio-clip",
			E "canvas", ref: "canvas", height: 80, width: 5000
	renderCanvas: ->
		canvas = React.findDOMNode @refs.canvas
		ctx = canvas.getContext "2d"
		ctx.strokeStyle = getComputedStyle(canvas).color
		for x in [0..canvas.width] by 0.1
			ctx.lineTo x, canvas.height/2 + canvas.height/2 * Math.sin((x/50)**0.9) * Math.sin(x**1.1) * (if Math.sin(x) < 0.1 then (x**0.1) else 1) * 0.5
		ctx.stroke()
	componentDidMount: -> @renderCanvas()
	componentDidUpdate: -> @renderCanvas()
