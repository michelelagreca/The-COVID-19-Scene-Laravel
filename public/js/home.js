import "https://platform.twitter.com/widgets.js";
import "https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js";

// loading page to let the tweets load
function onReady(callback) {
    var intervalId = window.setInterval(function() {
      if (document.getElementsByTagName('body')[0] !== undefined) {
        window.clearInterval(intervalId);
        callback.call(this);
      }
    }, 3000);
}
  
function setVisible(selector, visible) {
    document.querySelector(selector).style.display = visible ? 'block' : 'none';
}
  
onReady(function() {
    setVisible('#main', true);
    setVisible('#loading', false);
});


function onJson_tw (json) {
    const tweets = document.querySelector("#tweets");
    tweets.innerHTML="";
    let num_results = json.meta.result_count;
     if (num_results>9){
         num_results=9;
     }
     for(let i = 0; i < num_results; i++){
         const tweet_data = json.data[i];
         const id = tweet_data.id;
        twttr.widgets.createTweet(
            id, tweets,
            {
                theme: 'dark',
                conversation: 'none',
                width: 250
            }
          );

          }
}
function onResponse_tw (response) {
    return response.json();
}

function onJson (json) {
    console.log("im i on json");
    const notizie = document.querySelector("#news");
    notizie.innerHTML=""; /*i empty the news view because i want to upload fresh news each time*/
    let num_results = json.totalResults;
    if (num_results>9){
        num_results=9;
    }
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

function onResponse (response) {
    return response.json();
}
function onClick2(event){
    const nav = document.querySelector('#nav_main');
    nav.classList.remove('nav_appear');
    nav.style.display = 'none';
    // nav.classList.add('hidden');
    const container = document.querySelector('#container_lines');
    container.removeEventListener('click', onClick2);
    container.addEventListener('click', onClick);
}
function onClick(event){
    const nav = document.querySelector('#nav_main');
    nav.classList.add('nav_appear');
    const container = document.querySelector('#container_lines');
    container.addEventListener('click', onClick2);
    container.removeEventListener('click', onClick);
}
console.log("start");
//fetch("/home/news").then(onResponse).then(onJson);
//fetch("/home/tweets").then(onResponse_tw).then(onJson_tw);
const container = document.querySelector('#container_lines');
container.addEventListener('click', onClick);