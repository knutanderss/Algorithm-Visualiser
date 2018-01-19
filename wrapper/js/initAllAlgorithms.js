const algorithms = require('./config.js').config.algorithms;

const wrapper = document.getElementById('content-wrapper');
const buttons = document.getElementById('choose-algorithm');

for (var i=0; i < algorithms.length; i++) {
  const title = algorithms[i].title;
  const id = title.replace(' ', '');

  const algDiv = document.createElement('div');
  algDiv.id = id;
  algDiv.classList = ['inactive'];
  wrapper.appendChild(algDiv);

  const algButton = document.createElement('button');
  algButton.textContent = title;
  algButton.name = 'button';
  algButton.onclick = require('../init.js').startAlgorithm(title, id);
  buttons.appendChild(algButton);

  algorithms[i].start(document.getElementById(id));
}
