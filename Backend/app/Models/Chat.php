<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Chat extends Model
{
    protected $table = 'chat';
    protected $fillable = ['id_user','role','message','tag'];

    function user(){
        return $this->belongsTo(User::class,'id_user');
    }
}
