
keys =
	tab:    9
	enter:  13
	esc:    27
	space:  32
	left:   37
	up:     38
	right:  39
	down:   40

class @DropdownMenu extends E.Component
	# @TODO: allow dragging down from the DropdownButton
	render: ->
		{items, open} = @props
		E ".menu.dropdown-menu",
			role: "menu"
			style: display: ("none" unless open)
			onKeyDown: (e)=>
				elements = Array.from React.findDOMNode(@).children
				
				go = (delta)=>
					index = elements.indexOf document.activeElement
					index = Math.max(0, Math.min(elements.length - 1, index + delta))
					elements[index].focus()
				
				switch e.keyCode
					when keys.up
						go -1
					when keys.down
						go +1
					when keys.space, keys.enter
						if document.activeElement in elements
							document.activeElement.click()
					else
						return # don't prevent default
				
				e.preventDefault()
			
			for item in items when item?
				E ".menu-item",
					key: item.label
					role: "menuitem"
					tabIndex: 0
					onClick: item.action
					item.label
	componentDidMount: -> @updateOffset()
	componentDidUpdate: -> @updateOffset()
	updateOffset: ->
		el = React.findDOMNode @
		rect = el.getBoundingClientRect()
		if rect.right >= document.body.clientWidth
			linked = el.parentElement.nextSibling
			if linked?.classList.contains "linked"
				linked_rect = linked.getBoundingClientRect()
				el.style.left = "#{linked_rect.width - rect.width}px"
			else
				el.style.left = "auto"
