/*jslint browser:true */
/*jslint forin:true */
/*global document, window, alert, console, require */

// var form = document.getElementById('my-form');
var inputs = document.getElementsByClassName('data');
var status_update = document.getElementById('progress');
var submit = document.getElementById('submit');

function processForm() {
    "use strict";
    if (inputs[0].value === '') {
        alert('Please enter a search term');
        return;
    }
    submit.disabled = true;
    var search = new XMLHttpRequest(),
        client = new Faye.Client('http://localhost:9292/faye'),
        url;
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
    );
    search.open('GET', url, true);
    search.send();
    client.subscribe('/' + inputs[4].value, function (message) {
        var parsed_message = JSON.parse(message),
            current_page = parsed_message[0],
            total_pages = parsed_message[1];
        status_update.innerHTML = 'Searched ' + current_page + ' pages out of '
            + total_pages + ' pages. <br> GradCafe is a free service, so I put'
            + ' a 2-second delay between each page search.';
    });
    search.onreadystatechange = function () {
        if (search.readyState === 4 && search.status === 404) {
            status_update.innerHTML = 'No result found for your search!';
            submit.disabled = false;
        }
        if (search.readyState === 4 && search.status === 200) {
            var form = document.createElement('form'),
                result = document.createElement('input');
            form.action = '/result';
            form.method = 'POST';
            result.name = 'result';
            result.type = 'hidden';
            result.value = search.responseText;
            form.appendChild(result);
            form.submit();
        }
    };
}

submit.addEventListener('click', processForm);
