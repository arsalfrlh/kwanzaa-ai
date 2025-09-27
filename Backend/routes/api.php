<?php

use App\Http\Controllers\AuthApiController;
use App\Http\Controllers\ChatApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/login',[AuthApiController::class,'login']);
Route::post('/register',[AuthApiController::class,'register']);

Route::middleware('auth:sanctum')->group(function(){
    Route::get('/message',[ChatApiController::class,'index']);
    Route::post('/message/send',[ChatApiController::class,'create']);
    Route::post('/logout',[AuthApiController::class,'logout']);
});