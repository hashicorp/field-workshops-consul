remark.macros.scale = function (percentage) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + percentage + '" />';
};

// Place all of your files here
sourceUrls = [
  '0.md',
  '1.md'
  ]

var xmlhttp = new XMLHttpRequest();

var source = ""

for (var i = 0; i < sourceUrls.length; i++) {
  xmlhttp.open('GET', sourceUrls[i], false);
  xmlhttp.send();

  source += xmlhttp.responseText;

  // Files shouldn't have --- at the head or foot
  // It is added automatically here
  if (i + 1 < sourceUrls.length) {
    source += "\n---\n"
  }
};

var slideshow = remark.create({
  ratio: '4:3',
  highlightStyle: 'tomorrow-night-bright',
  highlightLines: 'true',
  source: source
});
