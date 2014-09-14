// Sends DELETE to the item in the server.
// Returns server response as a callback.
//
function deleteItem(slug, callback) {
  var r = new XMLHttpRequest();
  r.open('DELETE', ('api?token=' + token + '&slug=' + slug), true);
  r.onreadystatechange = function () {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
};

// Binds to the click event of the delete icons.
// Hides the deleted item after success.
//
var count = document.getElementsByClassName('header-count')[0];
var items = document.getElementsByClassName('item-delete');
for (var i = items.length - 1; i >= 0; i--) {
  items[i].addEventListener('click', function (e) {
    var link = this;
    var slug = link.getAttribute('data-slug');
    var currentCount = parseInt(count.innerHTML, 10) - 1;
    count.innerHTML = currentCount;
    link.parentNode.parentNode.classList.toggle('is-deleted');
    deleteItem(slug, function (res) {
      if (res == 'true') {
        var isGoneCount  = items.length - document.getElementsByClassName('is-deleted').length
        if (currentCount === 0 || isGoneCount === -1) { window.location.reload(); };
      };
    });
    e.preventDefault();
  }, false);
};

// Toggles the help popup using header links.
//
var popup = document.getElementsByClassName('popup')[0];
var toggles = document.getElementsByClassName('header-link');
for (var i = toggles.length - 1; i >= 0; i--) {
  toggles[i].addEventListener('click', function (e) {
    popup.classList.toggle('is-hidden');
    history.pushState({}, document.title, this.href);
    e.preventDefault();
  }, false);
};

// Toggles the help popup using the pushState().
//
var segments = window.location.href.split('/')
if (segments[segments.length-1] == 'admin#help') {
  popup.classList.toggle('is-hidden');
};

// Makes the inputs easier to select on mobile.
//
var inputs = document.getElementsByTagName('input');
for (var i = inputs.length - 1; i >= 0; i--) {
  inputs[i].addEventListener('click', function (e) {
    this.focus();
    this.setSelectionRange(0, 9999);
  }, false);
};

// Disables links that have the class `.is-disabled`
//
var links = document.getElementsByClassName('is-disabled');
for (var i = links.length - 1; i >= 0; i--) {
  links[i].addEventListener('click', function (e) {
    e.preventDefault();
  }, false);
};

// Sets the min-height of the popup based on the body height.
//
var height = document.getElementsByTagName('body')[0].scrollHeight;
var popup = document.getElementsByClassName('popup')[0];
popup.style.minHeight = height + 'px';
