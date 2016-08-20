
{expect} = require "chai"

describe "AudioEditor", ->
	it.skip "should load a document", ->
		# how should this work?
		# aside from getting React working and hooking stuff up,
		# am I supposed to prepolulate IndexedDB for this test?
		document_id = "mocha-test-document"
		React.render (E AudioEditor, {key: document_id, document_id, themes, set_theme}), document.body

	it.skip "should let you delete", ->
		# stuff from the selected tracks,
		# moving stuff over in time
	
	describe "clipboard support", ->
		it "should let you copy and paste"
		it "should let you cut and paste"
	
	it.skip "should let you undo", ->
		# and keep the selection
	it.skip "should let you redo", ->
		# and keep the selection
	
	it "should save automatically"
	it "should save undo/redo history"
	it "should let you clear undo/redo history"
	
	it "should let you add tracks with clips"
	it "should let you add clips to existing tracks"
	it "should let you delete tracks"
	it "should let you mute/unmute tracks"
	it "should let you pin/unpin tracks"
	
	it "should let you record from a mic"
	it "should let you precord, magically"

	it "should do scrolling good"
	it "should do zooming good"
	it "should do playback good"
	it "should do seeking well-ly"
