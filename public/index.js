/* jslint browser:true */
/* jslint forin:true */
/* global document, window, alert, console, require, Faye, XMLHttpRequest */

var inputs = document.getElementsByClassName('data')
var statusUpdate = document.getElementById('progress')
var submit = document.getElementById('submit')
var client = new Faye.Client('https://grad-cafe-visualizations.herokuapp.com/faye')
// var client = new Faye.Client('http://localhost:9292/faye');

function workMagic (searchResults) {
  'use strict'
  var form = document.createElement('form')
  var result = document.createElement('input')
  var searchTerm = document.createElement('input')
  var timePeriod = document.createElement('input')
  var mastersPhd = document.createElement('input')
  var searchSeason = document.createElement('input')
  var enter = document.createElement('button')
  form.action = '/result'
  form.method = 'POST'
  result.name = 'result'
  result.type = 'hidden'
  result.value = searchResults
  searchTerm.name = 'search_term'
  searchTerm.type = 'hidden'
  searchTerm.value = inputs[0].value
  timePeriod.name = 'time_period'
  timePeriod.type = 'hidden'
  timePeriod.value = inputs[1].value
  mastersPhd.name = 'masters_phd'
  mastersPhd.type = 'hidden'
  mastersPhd.value = inputs[2].value
  searchSeason.name = 'search_season'
  searchSeason.type = 'hidden'
  searchSeason.value = inputs[3].value
  enter.type = 'hidden'
  enter.value = 'Submit'
  form.appendChild(result)
  form.appendChild(searchTerm)
  form.appendChild(timePeriod)
  form.appendChild(mastersPhd)
  form.appendChild(searchSeason)
  form.appendChild(enter)
  document.body.appendChild(form)
  form.submit()
}

function processForm () {
  'use strict'
  if (inputs[0].value === '') {
    alert('Please enter a search term')
    return
  }
  submit.disabled = true
  var search = new XMLHttpRequest()
  var url
  url = '/search?search_term='.concat(
      inputs[0].value,
      '&time_period=',
      inputs[1].value,
      '&masters_phd=',
      inputs[2].value,
      '&search_season=',
      inputs[3].value,
      '&channel=',
      inputs[4].value
  )
  search.open('GET', url, true)
  search.send()
}

submit.addEventListener('click', processForm)

client.subscribe('/' + inputs[4].value, function (message) {
  'use strict'
  var parsedMessage = JSON.parse(message)
  var currentPage = parsedMessage[0]
  var totalPages = parsedMessage[1]
  var searchResults = parsedMessage[2]
  statusUpdate.innerHTML = 'Searched ' + currentPage + ' of ' +
    totalPages + ' pages. <br> GradCafe is a free service, so I put' +
    ' a 2-second delay between each page search. <br> All GRE scores' +
    ' are on the new scale, the old scores have been converted to' +
    ' the new scale.'
  if (currentPage === totalPages) {
    if (totalPages === 0) {
      statusUpdate.innerHTML = '<h3>No result found for your search!</h3>'
      submit.disabled = false
      return
    }
    setTimeout(workMagic(searchResults), 1100)
  }
})
