
React = @React ? require "react"

is_plainish_object = (o)->
	o? and typeof o is "object" and not (
		o instanceof Array or # (e.g. [])
		React.isValidElement o # (e.g. E())
	)

add = (from, {to})->
	if from instanceof Array
		add thing, {to} for thing in from
		return yes
	else if is_plainish_object from
		for k, v of from when v
			to.push hyphenate k
		return yes
	else if from?
		to.push from
	return no

hyphenate = (v)->
	"#{v}"
		.replace /_/g, "-"
		.replace /([a-z])([A-Z])/g, (m, az, AZ)->
			"#{az}-#{AZ.toLowerCase()}"

E = (element_type, args...)->
	
	element_type ?= ""
	
	if is_plainish_object args[0]
		[attr_args, child_args...] = args
	else
		[child_args...] = args
		attr_args = null
	
	switch typeof element_type
		when "string"
			selector = element_type
			element_type = "div"
			partial_selector = selector.replace /^[a-z][a-z0-9\-_]*/i, (match)->
				element_type = match
				""
			
			final_attributes = {}
			class_names = []
			
			addAttr = (attr_k, attr_v, aria)->
				# Why doesn't React handle boolean attributes?
				# @TODO: warn if attribute already added
				final_attributes[attr_k] = attr_v unless attr_v is false and not aria
			
			for attr_k, attr_v of attr_args
				if attr_k in ["class", "className", "classes", "classNames", "classList"]
					add attr_v, to: class_names
				else if attr_k is "data"
					for data_k, data_v of attr_v
						addAttr "data-#{hyphenate data_k}", data_v
				else if attr_k is "aria"
					for aria_k, aria_v of attr_v
						addAttr "aria-#{hyphenate aria_k}", aria_v, yes
				else if attr_k.match /^data/
					addAttr (hyphenate attr_k), attr_v
				else if attr_k.match /^aria/
					addAttr (hyphenate attr_k), attr_v, yes
				else
					addAttr attr_k, attr_v
			
			if partial_selector
				unhandled = partial_selector
					.replace /\.([a-z][a-z0-9\-_]*)/gi, (m, className)->
						class_names.push className
						""
					.replace /#([a-z][a-z0-9\-_]*)/gi, (m, id)->
						final_attributes.id = id
						""
			
			if unhandled
				throw new Error "Unhandled selector fragment '#{unhandled}' in selector: '#{selector}'"
			
			final_attributes.className = class_names.join " " if class_names.length
			
		when "function"
			final_attributes = attr_args
		else
			throw new Error "Invalid first argument to ReactScript: #{element_type}"
	
	final_child_args = []
	was_dynamic = no
	for child_arg in child_args
		was_dynamic or= add child_arg, to: final_child_args
	
	if was_dynamic
		React.createElement element_type, final_attributes, final_child_args
	else
		React.createElement element_type, final_attributes, final_child_args...


if module?.exports?
	module.exports = E
else
	@ReactScript = E
