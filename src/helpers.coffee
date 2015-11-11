
@E = ReactScript
@E.Component = React.Component

@scale = 90 # @TODO: zooming
@sampleRate = 2500

gen = (count)->
	out = ""
	for i in [0...count]
		out += (((1+Math.random())*0x10000)|0).toString(16).substring(1)
	out

@GUID = ->
	[gen(2), gen(1), gen(1), gen(1), gen(3)].join("-")

@closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no
