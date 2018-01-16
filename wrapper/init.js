function setHeader(title) {
  var header = document.getElementsByTagName('header')[0];
  var h1 = document.getElementById('algorithm-name');
  h1.textContent = title;
  header.classList.add('active');
  h1.classList.add('active');
}

function hideMenu() {
  var menu = document.getElementById('choose-algorithm');
  menu.classList.add('inactive');
  setTimeout(function () {
    menu.classList.add('hidden');
  }, 300);
}

function showMenu() {
  setTimeout(function () {
    menu.classList.remove('hidden');
    var menu = document.getElementById('choose-algorithm');
    menu.classList.remove('inactive');
  }, 300);
}

export function startAlgorithm(title, id) {
  return function (mouseEvent) {
    setHeader(title);
    hideMenu();
    var algDiv = document.getElementById(id);
    setTimeout(function () {
      algDiv.classList.remove('inactive');
    }, 400);
  }
}

function startInsertionSort() {
  startAlgorithm('Insertion Sort');
}
