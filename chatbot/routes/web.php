<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware('guest')->group(function(){
    Route::get('/login',[AuthController::class,'login'])->name('login');
    Route::post('/login/proses',[AuthController::class,'loginProses']);
    Route::get('/register',[AuthController::class,'register']);
    Route::post('/register/proses',[AuthController::class,'registerProses']);
});

Route::get('/home', function(){
    return redirect('/index');
});

Route::middleware('auth')->group(function(){
    Route::get('/index',[ChatController::class,'index']);
    Route::get('/logout',[AuthController::class,'logout']);
    Route::post('/message/send',[ChatController::class,'sendMessage']);
});