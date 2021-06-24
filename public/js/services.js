function onJson_test (json) {
    const obj = jQuery.parseJSON(JSON.stringify(json));
    if(obj['staff']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The staff does not exist in the database';
    }
    else if(obj['patient']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The patient does not exist in the database';
    }
    else if(obj['hub']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The hub does not exist in the database';
    }
    else if(obj['id']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The same ID - Type value exists in the database';
    }
    else if(obj['data']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The date is before the creation of the test';
    }
    else if(obj['died']=='no'){
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The staff or patient is died';
    }
    else{
        const res = document.querySelector("#response");
        res.classList.remove('hidden');
        res.classList.add('ok');
        res.textContent = 'Test registered';
        document.querySelector('form[name=tests] input[name=ID]').value = '';
        document.querySelector('form[name=tests] input[name=staff]').value = '';
        document.querySelector('form[name=tests] input[name=patient]').value = '';
        document.querySelector('form[name=tests] input[name=hub]').value = '';
        document.querySelector('form[name=tests] input[name=date]').value = '';
        document.querySelector('form[name=tests] select').value = '';
    }
}
function onJson_result (json) {
    const obj = jQuery.parseJSON(JSON.stringify(json));
    console.log(obj);
    if(obj['lab']=='no'){
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The lab does not exist in the database';
    }
    else if(obj['id_2']=='no'){
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The test is not present in the database';
    }
    else if(obj['res']=='no'){
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'The value should be between 0 and 100';
    }
    else if(obj['data_yet']=='no'){
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'There is not yet test with this information';
    }
    else if(obj['data_same']=='no'){
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.remove('ok');
        res.classList.add('errore_ins');
        res.textContent = 'A result with the same date already exist';
    }
    else{
        const res = document.querySelector("#response_2");
        res.classList.remove('hidden');
        res.classList.add('ok');
        res.textContent = 'Test Result registered';
        document.querySelector('form[name=results] input[name=ID]').value = '';
        document.querySelector('form[name=results] input[name=lab').value = '';
        document.querySelector('form[name=results] input[name=res]').value = '';
        document.querySelector('form[name=results] input[name=date]').value = '';
        document.querySelector('form[name=results] select').value = '';
    }
}
function onResponse (response) {
    return response.json();
}
function onResponse2 (response) {
    return response.json();
}
function return_normal(event) {
    console.log("fixo");
    const sel = event.currentTarget;
    sel.classList.remove("error");
    sel.removeEventListener("click", return_normal);
}
function validation_t (event) {
    event.preventDefault();
    if(test.ID.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] input[name=ID]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(test.type.value === ''){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] select");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(test.staff.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] input[name=staff]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(test.patient.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] input[name=patient]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(test.hub.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] input[name=hub]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(test.date.value === ''){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=tests] input[name=date]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    else {
        const data = 
        {   ID:test.ID.value,
            Type:test.type.value,
            Staff:test.staff.value,
            Patient:test.patient.value,
            Hub:test.hub.value,
            Date:test.date.value
        };
        fetch("/services/test",{
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
                // "X-CSRF-Token": csrfToken,
                'Accept': 'application/json'
            }
        })
        .then(onResponse).then(onJson_test);
    }
}
function validation_r (event) {
    event.preventDefault();
    if(result.ID.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=results] input[name=ID]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(result.type.value === ''){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=results] select");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(result.lab.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=results] input[name=lab]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(result.date.value === ''){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=results] input[name=date]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    if(result.res.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=results] input[name=res]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
    }
    else {
        console.log("enter in else");
        const data1 = 
        {   ID:result.ID.value,
            Type:result.type.value,
            Lab:result.lab.value,
            Date:result.date.value,
            Res:result.res.value
        };
        fetch("/The Covid-19 Scene/phps/services_result.php",{
            method: 'POST',
            body: JSON.stringify(data1)
        })
        .then(onResponse2).then(onJson_result);
    }
}
const test = document.forms['tests'];
const result = document.forms['results'];
test.addEventListener('submit', validation_t);
result.addEventListener('submit', validation_r);