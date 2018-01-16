export function setHeader(title) {
  var header = document.getElementsByTagName('header')[0];
  var h1 = document.getElementById('algorithm-name');
  h1.textContent = title;
  header.classList.add('active');
  h1.classList.add('active');
}

export function hideMenu() {
  var menu = document.getElementById('choose-algorithm');
  menu.classList.add('inactive');
  setTimeout(function () {
    menu.classList.add('hidden');
  }, 300);
}

export function showMenu() {
  setTimeout(function () {
    menu.classList.remove('hidden');
    var menu = document.getElementById('choose-algorithm');
    menu.classList.remove('inactive');
  }, 300);
}

export function startAlgorithm(title) {
  setHeader(title);
  hideMenu();
  var contentWrapper = document.getElementById('content-wrapper');
  contentWrapper.classList.add('active');
}

export function startInsertionSort() {
  startAlgorithm('Insertion Sort');
}
