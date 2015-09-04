
@E = ReactScript
@E.Component = React.Component

@scale = 90 # @TODO: zooming
@sampleRate = 2500

@sample_data_1 = for i in [0..50*sampleRate]
	x = i*90
	Math.sin((x/50)**0.9) * Math.sin(x**1.1) * (x**0.1) * 0.2
@sample_data_2 = for i in [0..50*sampleRate]
	x = i*90
	# Math.sin((x/50)**0.9) * Math.sin(x**1.1) * 0.9 * ((x*50)%200)/200
	(
		((
			((i >> 10) & 42) * i
		) & 255) / 127 - 1
	) * 0.6


@closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no
