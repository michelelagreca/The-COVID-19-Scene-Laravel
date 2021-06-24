<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Operatore extends Model
{
    protected $table = "operatore";
    protected $primaryKey = "CF";
    protected $autoIncrement = false;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'CF',
        'Matricola',
        'Qualifica',
        'anni_servizio'

    ];
    public function persona(){
        return $this->belongsTo("App\Models\Persona", "CF", "CF");
    }
    public function staff(){
        return $this->hasOne("App\Models\Staff", "code", "username");
    }
    public function tampone(){
        return $this->hasMany("App\Models\Tampone", "operatore", "CF");
    }
}

?>