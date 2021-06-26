import "https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js";

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

const container = document.querySelector('#container_lines');
container.addEventListener('click', onClick);