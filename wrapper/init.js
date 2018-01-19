const CONTENT_WRAPPER = 'content-wrapper';
const CHOOSE_ALGORITHM = 'choose-algorithm';
const ALGORITHM_H1 = 'algorithm-name';

function setHeader(title) {
  var header = document.getElementsByTagName('header')[0];
  var h1 = document.getElementById(ALGORITHM_H1);
  var headerContent = document.getElementById('header-content');
  h1.textContent = title;
  header.classList.add('active');
  headerContent.classList.add('active');
}

function unsetHeader() {
  var header = document.getElementsByTagName('header')[0];
  var h1 = document.getElementById(ALGORITHM_H1);
  var headerContent = document.getElementById('header-content');
  h1.textContent = '';
  header.classList.remove('active');
  headerContent.classList.remove('active');
}

function hideMenu() {
  var menu = document.getElementById(CHOOSE_ALGORITHM);
  menu.classList.add('inactive');
  setTimeout(function () {
    menu.classList.add('hidden');
  }, 300);
}

function showMenu() {
  var menu = document.getElementById(CHOOSE_ALGORITHM);
  setTimeout(function () {
    menu.classList.remove('hidden');
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

export function back_to_main_menu(mouseEvent) {
  console.log('Called!');
  unsetHeader();
  showMenu();
  const children = document.querySelectorAll("#" + CONTENT_WRAPPER + " > div");
  children.forEach(function (child) {
    if (!child.classList.contains('inactive')) {
      child.classList.add('inactive');
    }
  });
}
