/*jslint browser:true */
/*jslint forin:true */
/*global document, window, alert, console, require */

// var form = document.getElementById('my-form');
var inputs = document.getElementsByClassName('data');
var status_update = document.getElementById('progress');
var submit = document.getElementById('submit');

function workMagic(search) {
    "use strict";
    var form = document.createElement('form'),
        result = document.createElement('input'),
        search_term = document.createElement('input'),
        time_period = document.createElement('input'),
        masters_phd = document.createElement('input'),
        search_season = document.createElement('input');
    form.action = '/result';
    form.method = 'POST';
    result.name = 'result';
    result.type = 'hidden';
    result.value = search.responseText;
    search_term.name = 'search_term';
    search_term.type = 'hidden';
    search_term.value = inputs[0].value;
    time_period.name = 'time_period';
    time_period.type = 'hidden';
    time_period.value = inputs[1].value;
    masters_phd.name = 'masters_phd';
    masters_phd.type = 'hidden';
    masters_phd.value = inputs[2].value;
    search_season.name = 'search_season';
    search_season.type = 'hidden';
    search_season.value = inputs[3].value;
    form.appendChild(result);
    form.appendChild(search_term);
    form.appendChild(time_period);
    form.appendChild(masters_phd);
    form.appendChild(search_season);
    form.submit();
}

function processForm() {
    "use strict";
    if (inputs[0].value === '') {
        alert('Please enter a search term');
        return;
    }
    submit.disabled = true;
    var search = new XMLHttpRequest(),
        client = new Faye.Client('https://grad-cafe-visualizations.herokuapp.com/faye'),
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
        status_update.innerHTML = 'Searched ' + current_page + ' of '
            + total_pages + ' pages. <br> GradCafe is a free service, so I put'
            + ' a 2-second delay between each page search. <br> All GRE scores'
            + ' are on the new scale, the old scores have been converted to'
            + ' the new scale.';
        if (current_page === total_pages) {
            setTimeout(workMagic(search), 1100);
        }
    });
    search.onreadystatechange = function () {
        if (search.readyState === 4 && search.status === 404) {
            status_update.innerHTML = '<h3>No result found for your search!</h3>';
            submit.disabled = false;
        }
        // if (search.readyState === 4 && search.status === 200) {
        //     console.log('JAJA BLINKS!');
        //     var form = document.createElement('form'),
        //         result = document.createElement('input'),
        //         search_term = document.createElement('input'),
        //         time_period = document.createElement('input'),
        //         masters_phd = document.createElement('input'),
        //         search_season = document.createElement('input');
        //     form.action = '/result';
        //     form.method = 'POST';
        //     result.name = 'result';
        //     result.type = 'hidden';
        //     result.value = search.responseText;
        //     search_term.name = 'search_term';
        //     search_term.type = 'hidden';
        //     search_term.value = inputs[0].value;
        //     time_period.name = 'time_period';
        //     time_period.type = 'hidden';
        //     time_period.value = inputs[1].value;
        //     masters_phd.name = 'masters_phd';
        //     masters_phd.type = 'hidden';
        //     masters_phd.value = inputs[2].value;
        //     search_season.name = 'search_season';
        //     search_season.type = 'hidden';
        //     search_season.value = inputs[3].value;
        //     form.appendChild(result);
        //     form.appendChild(search_term);
        //     form.appendChild(time_period);
        //     form.appendChild(masters_phd);
        //     form.appendChild(search_season);
        //     form.submit();
        // }
    };
}

submit.addEventListener('click', processForm);
