// pull in CSS/SASS files
require( './styles/main.scss' );

// pull in scripts
var init = require('./init')
window.startInsertionSort = init.startInsertionSort;

// inject bundled Elm app into div#content-wrapper
var Elm = require( '../elm/Main' );
Elm.Main.embed( document.getElementById( 'content-wrapper' ) );
