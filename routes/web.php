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

Route::get('/news', function () {
    return view('news');
})->name('news');

Route::get('/people', function () {

})->name('people');

Route::get('/access', 'LoginController@login')->name('access');
Route::post('/login', 'LoginController@checkLogin')->name('login');
Route::post('/signin', 'RegisterController@signin')->name('signin');

Route::get('/logout', 'LoginController@logout')->name('logout');

Route::get('/services', function () {
    return view('services');
})->name('services');






Route::get('/about', function () {
    return view('about');
})->name('about');

Route::get('/contact', function () {
    return view('contact');
})->name('contact');

Route::get('/terms', function () {
    return view('terms');
})->name('terms');
