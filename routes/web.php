<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


Route::get('/', function () {
    return view('home');;
})->name('home');

Route::get('/home/news', 'HomeController@news')->name('newsHome');
Route::get('/home/tweets', 'HomeController@tweets')->name('tweetsHome');

Route::get('/news', function () {
    return view('news');
})->name('news');

Route::post('/news/getNews', 'NewsController@getNews')->name('getNews');

Route::get('/people', function () {
    return view('people');
})->name('people');

Route::post('/people/info', 'PeopleController@getInfo')->name('getInfo');

Route::get('/access', 'LoginController@login')->name('access');
Route::post('/login', 'LoginController@checkLogin')->name('login');
Route::post('/signin', 'SigninController@signin')->name('signin');
Route::get('/logout', 'LoginController@logout')->name('logout');

Route::get('/services', function () {
    return view('services');
})->name('services');

Route::post('/services/test', 'ServiceController@insertTest')->name('test');
Route::post('/services/result', 'ServiceController@insertResult')->name('result');

Route::get('/about', function () {
    return view('about');
})->name('about');

Route::get('/contact', function () {
    return view('contact');
})->name('contact');

Route::get('/terms', function () {
    return view('terms');
})->name('terms');
