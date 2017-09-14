
ReactDOM = require "react-dom"
{E} = require "./helpers.coffee"
{AudioEditor} = require "./components/AudioEditor.coffee"

if location.protocol is "http:" and location.host.match /editor|app|wavey/
	location.protocol = "https:"

window.actx = new (
	window.AudioContext ?
	window.webkitAudioContext ?
	window.mozAudioContext ?
	window.oAudioContext ?
	window.msAudioContext
)

themes = require "../themes.json"

container = document.getElementById("app")

window.render = ->
	document_id = (location.hash.match(/document=([\w\-./]*)/) ? [0, "default"])[1]
	ReactDOM.render (E AudioEditor, {key: document_id, document_id, themes, set_theme, get_theme}), container

window.addEventListener "hashchange", render
render()
