var insertionSort = require( '../../elm/InsertionSort' );
var shellSort     = require( '../../elm/ShellSort' );


export const config = {
  algorithms : [
    {
      title : "Insertion Sort",
      start : div => insertionSort.InsertionSort.embed(div)
    },
    {
      title : "Shell Sort",
      start : div => shellSort.ShellSort.embed(div)
    }
  ]
}
