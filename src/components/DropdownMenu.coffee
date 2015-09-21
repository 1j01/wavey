
class @DropdownMenu extends E.Component
	render: ->
		{items} = @props
		E ".menu.dropdown-menu",
			for item in items
				E ".menu-item",
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
				console.log document.body.clientWidth, linked_rect, rect
				#el.style.right = "#{document.body.clientWidth - linked_rect.left}px"
				#el.style.left = "auto"
				console.log "#{linked_rect.width - rect.width}px"
				el.style.left = "#{linked_rect.width - rect.width}px"
			else
				el.style.right = "0"
				el.style.left = "auto"
		else
			el.style.right = ""
			el.style.left = ""
