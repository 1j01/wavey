
class @BeatMarkings extends E.Component
	render: ->
		{scale} = @props
		E ".beat-markings", style: position: "relative",
			for x in [0..50]
				[
					E ".beat-marking",
						key: x
						style: position: "absolute", left: "#{x*scale}px"
					for xs in [1..3]
						E ".beat-marking.sub",
							key: "#{x}+#{xs}/4"
							style: position: "absolute", left: "#{x*scale+xs*scale/4}px"
				]
