
class @BeatMarkings extends E.Component
	render: ->
		E ".beat-markings", style: position: "relative",
			for x in [0..50]
				[
					E ".beat-marking", style: position: "absolute", left: "#{x*scale}px"
					for xs in [1..3]
						E ".beat-marking.sub", style: position: "absolute", left: "#{x*scale+xs*scale/4}px"
				]
