
React = @React ? require "react"

is_plainish_object = (o)->
	o? and typeof o is "object" and not (
		o.length? or # (e.g. [])
		React.isValidElement o # (e.g. E())
	)

add = (from, {to})->
	if from instanceof Array
		add thing, {to} for thing in from
	else if is_plainish_object from
		for k, v of from when v
			to.push hyphenate k
	else if from?
		to.push from

hyphenate = (v)->
	"#{v}"
		.replace /_/g, "-"
		.replace /([a-z])([A-Z])/g, (m, az, AZ)->
			"#{az}-#{AZ.toLowerCase()}"

E = (elementType, args...)->
	
	elementType ?= ""
	
	if is_plainish_object args[0]
		[attrArgs, childArgs...] = args
	else
		[childArgs...] = args
		attrArgs = null
	
	switch typeof elementType
		when "string"
			selector = elementType
			elementType = "div"
			selAttrs = selector.replace /^[a-z][a-z0-9\-_]*/i, (match)->
				elementType = match
				""
			
			finalAttrs = {}
			classNames = []
			
			addAttr = (ak, av)->
				# Why doesn't React handle boolean attributes?
				finalAttrs[ak] = av unless av is false
			
			for ak, av of attrArgs
				if ak in ["class", "className", "classes", "classNames", "classList"]
					add av, to: classNames
				else if ak is "data"
					addAttr "data-#{hyphenate dk}", dv for dk, dv of av
				else if ak.match /^data|aria/
					addAttr (hyphenate ak), av
				else
					addAttr ak, av
			
			if selAttrs
				unhandled = selAttrs
					.replace /\.([a-z][a-z0-9\-_]*)/gi, (m, className)->
						classNames.push className
						""
					.replace /#([a-z][a-z0-9\-_]*)/gi, (m, id)->
						finalAttrs.id = id
						""
			
			if unhandled
				throw new Error "Unhandled selector fragment '#{unhandled}' in selector: '#{selector}'"
			
			finalAttrs.className = classNames.join " " if classNames.length
			
		when "function"
			finalAttrs = attrArgs
		else
			throw new Error "Invalid first argument to ReactScript: #{elementType}"
	
	finalChildren = []
	add childArgs, to: finalChildren
	
	React.createElement elementType, finalAttrs, finalChildren


if module?.exports?
	module.exports = E
else
	@ReactScript = E
