
function return_normal(event) {
    console.log("fixo");
    const sel = event.currentTarget;
    sel.classList.remove("error");
    sel.removeEventListener("click", return_normal);
}
function validation1 (event) {
    console.log("hai cliccato submit sul login");
    if(form_login.username.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=form_login] input[name=username]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
        event.preventDefault();
    }
    if(form_login.password.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=form_login] input[name=password]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
        event.preventDefault();
    }
    else {
        console.log("submit..."); /* this is not showed because the page is reloaded if the code enters this else block*/
    }
}
function validation2 (event) {
    console.log("hai cliccato submit sul signin");
    if(form_signin.code.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=form_signin] input[name=code]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
        event.preventDefault();
    }
    if(form_signin.username.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=form_signin] input[name=username]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
        event.preventDefault();
    }
    if(form_signin.password.value.length == 0){
        console.log("campo vuoto");
        const field = document.querySelector("form[name=form_signin] input[name=password]");
        field.classList.add("error");
        field.addEventListener("click", return_normal);
        event.preventDefault();
    }
    else {
        console.log("submit..."); /* this is not showed because the page is reloaded if the code enters this else block*/
    }
}
console.log("In attesa del submit...");
const form_login = document.forms['form_login'];
const form_signin = document.forms['form_signin'];
form_login.addEventListener('submit', validation1);
form_signin.addEventListener('submit', validation2);