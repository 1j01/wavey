
# [![Wavey](images/wavey-logotype-medium.png)][app]

[Wavey is the audio editor of the future.][app]


### Features

* Drag and drop audio files or record from a microphone
* Always saved locally, including persistent undo/redo and selection
* Several themes, including light and dark [elementary OS][] themes via [elementary.css][], and some retro themes
* Fully scalable graphics, from the icons to the waveforms
* Export the document or a selected range as WAV or MP3


### Future Features

Note how the bar with beat markings is a track. It would become a metronome when unmuted.

Tracks can be pinned to the top,
which should easy the pain when you have many tracks with audio clips
you want to line up with some main audio track(s).
**Currently this breaks pasting, among other things.**

You will be able to "precord" up to five minutes or as long as precording has been enabled. 

MIDI is a possibility.

Embedding. Plugins. Desktop apps.

Interoperability with Audacity (exporting/importing project files).

Internationalization and improved accessibility.


### TODO

* Fix pasting, deleting behavior etc. and get back to solid editing
* Mouse-relative zooming (also preferably performant zooming)
* Effects
* Gain control and panning (maybe as effects? depends on what the effects UI will look like)
* Application Cache, because this app can work completely offline


### Contributing

Contributions and criticism welcome.
[Open up an issue][new issue] to discuss features, problems, or improvements.

This project is built with [CoffeeScript][], [React][], and [ReactScript][].


### License

The MIT License (MIT)

Copyright (c) 2015 Isaiah Odhner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[app]: https://audioeditor.ml/
[elementary OS]: https://elementary.io/
[elementary.css]: https://github.com/1j01/elementary.css/
[RTLCSS]: https://github.com/MohammadYounes/rtlcss
[CoffeeScript]: http://coffeescript.org/
[React]: https://facebook.github.io/react/
[ReactScript]: https://github.com/1j01/react-script
[new issue]: https://github.com/1j01/wavey/issues/new
