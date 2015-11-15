
@E = ReactScript
@E.Component = React.Component

@scale = 90 # @TODO: zooming

@GUID = ->
	array = new Uint32Array 4
	crypto.getRandomValues array
	("00000000#{n.toString 16}".slice -8 for n in array).join ""

@closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no
