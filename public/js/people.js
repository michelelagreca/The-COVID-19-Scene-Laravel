function onJson_check (json) {
    const obj = jQuery.parseJSON(JSON.stringify(json));
    console.log(obj);
    if(document.querySelector('#tabella')!=null){
        const t = document.querySelector('#tabella');
        t.innerHTML='';
    }
    const res = document.querySelector("#check_person");
    res.classList.add('hidden');
    res.classList.remove('errore_ins');
    if(document.querySelector('#specifier') != null){
        const s = document.querySelector('#specifier');
        s.innerHTML='';
    }
    if(obj['person']=='yes'){
        const t = document.querySelector('#tabella');
        if(obj['dati'].length > 0){
            const res = document.querySelector("#check_person");
            res.classList.add('hidden');
            res.classList.remove('errore_ins');
            t.classList.remove('hidden');
            t.classList.add('showing');
            const array = JSON.parse(obj['dati']);
            const r1 = document.createElement('tr');
            r1.classList.add('first');
            for (var key in array[0]) {
                const c = document.createElement('th');
                c.textContent = key;
                r1.appendChild(c);
            }
            t.appendChild(r1);
            for (var i = 0; i < array.length; i++){
                const r = document.createElement('tr');
                for (var key in array[i]) {
                    const c = document.createElement('td');
                    c.textContent = array[i][key];
                    r.appendChild(c);
                }
                t.appendChild(r);
            }
        }
        else{
            const s = document.querySelector('#specifier');
            s.classList.remove('hidden');
            s.classList.add('showing');
            if(obj['get_pat']=='yes'){
                s.textContent = 'The person has not patient information';
            }
            else if(obj['get_test']=='yes'){
                s.textContent = 'The person has not made any test';
            }
            else if(obj['get_result']=='yes'){
                s.textContent = 'The person has not received any test result';
            }
        }
        document.querySelector('form[name=info] input[name=ID]').value = '';
        document.querySelector('form[name=info] input[name=name').value = '';
        document.querySelector('form[name=info] input[name=surname]').value = '';
    }
    else{
        const res = document.querySelector("#check_person");
        res.classList.remove('hidden');
        res.classList.add('errore_ins');
        res.textContent = 'The person is not present in the database';
    }
}
function onResponse (response) {
    return response.json();
}
function return_normal(event) {
    console.log("fixo");
    const sel = event.currentTarget;
    sel.classList.remove("error");
    sel.removeEventListener("click", return_normal);
}
function validation(event) {
    event.preventDefault();
    const s = event.submitter;
    if(info.ID.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=info] input[name=ID]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(info.name.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=info] input[name=name]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(info.surname.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=info] input[name=surname]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    else {
        const data =
        {   ID:info.ID.value,
            Name:info.name.value,
            Surname:info.surname.value,
            Sub:s.value
        };
        fetch("/people/info",{
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
                // "X-CSRF-Token": csrfToken,
                'Accept': 'application/json'
            }
        })
        .then(onResponse).then(onJson_check);
    }
}

const info = document.forms['info'];
info.addEventListener('submit', validation);