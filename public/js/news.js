function onJson (json) {
    const obj = jQuery.parseJSON(JSON.stringify(json));
    console.log(obj);
    if(document.querySelector("#form_news h3") != null){
        const part = document.querySelector("#form_news");
        const h = document.querySelector("#form_news h3");
        part.removeChild(h);
    }
    const notizie = document.querySelector("#result_news");
    notizie.innerHTML=""; /*i empty the news view because i want to upload fresh news each time*/
    notizie.classList.remove('hidden');
    let num_results = json.totalResults;
    if (num_results>9){
        num_results=9;
    }
    if(num_results==0){
        const part = document.querySelector("#form_news");
        const h2 = document.createElement('h3');
        h2.textContent = 'Currently there are not news about this country.';
        part.appendChild(h2);
    }
    else{
        for(let i = 0; i < num_results; i++){
            const doc = json.articles[i];
            const title = doc.title;
            const url = doc.url;
            if (doc.urlToImage === null){
                console.log("Image is not available. Skipping the news...");
                num_results++; // if the image is invalid, i increment the number of news so that at the end i still will have 10 news
            } else {
                const cover = doc.urlToImage;
                const notizia = document.createElement("div");
                notizia.classList.add("news_container");
                notizia.style.backgroundImage = 'url(' + cover + ')';
                notizia.style.backgroundSize = 'cover';
                notizia.style.position = "relative";
                const tit = document.createElement("a");
                tit.classList.add("news_links");
                tit.target = "_blank"; // to avoid the link will be opened in the same page
                tit.rel = "noopener noreferrer"; // same as above
                tit.textContent = title;
                tit.href = url;
                notizia.appendChild(tit);
                notizie.appendChild(notizia);
                console.log("fatto per la news "+ (i+1));
                const over = document.createElement("div");
                over.classList.add('overlay_stronger');
                notizia.appendChild(over);
            }
        }
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
function validation (event) {
    event.preventDefault();
    const form = document.querySelector("form");
    if(form.country.value === ""){
        console.log("campo vuoto");
        const select = document.querySelector("select");
        select.classList.add("error");
        select.addEventListener("click", return_normal);
    }
    else {
        const data = 
        {    Country:form.country.value
        };
        fetch("/news/getNews",{
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content'),
                'Accept': 'application/json'
            }
        })
        .then(onResponse).then(onJson);
    }
}
const s = document.querySelector("input[type=submit]");
s.addEventListener('click', validation);