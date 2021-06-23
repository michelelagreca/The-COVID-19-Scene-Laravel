<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Staff extends Model
{
    protected $table = "staff";
    protected $primaryKey = "username";
    protected $autoIncrement = false;
    protected $keyType = "string";
    public $timestamps = false;

    protected $fillable = [
        'code',
        'username',
        'password',
    ];

    
    protected $hidden = [
        'password'
    ];
    public function operatore(){
        return $this->belongsTo("App\Models\Operatore", "code", "matricola");
    }
}

?>