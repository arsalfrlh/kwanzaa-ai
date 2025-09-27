<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(){
        return view('main.login');
    }

    public function loginProses(Request $request){
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $login = [
            'email' => $request->email,
            'password' => $request->password,
        ];

        if(Auth::attempt($login)){
            return redirect('/index')->with("success", Auth::user()->name . ' Selamat datang Anda berhasil login');
        }else{
            return redirect('/login')->with('error', 'Email atau Password Anda salah');
        }
    }

    public function register(){
        return view('main.register');
    }

    public function registerProses(Request $request){
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required',
        ]);

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        Auth::attempt([
            'email' => $request->email,
            'password' => $request->password,
        ]);

        return redirect('/index')->with('success', Auth::user()->name . ' Selamat Datang Anda berhasil register');
    }

    public function logout(){
        Auth::logout();
        return redirect('/login')->with('error', 'Anda telah logout');
    }
}
