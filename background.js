/*
 * Listens for the app launching then creates teh window
*/

chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('index.html', {
	id: 'main',
    'outerBounds': {
      'width': 800,
      'height': 600
    }
  });
});
