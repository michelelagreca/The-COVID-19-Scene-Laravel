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
    protected $timestamps = false;

    protected $fillable = [
        'CF',
        'Matricola',
        'Qualifica',
        'anni_servizio'

    ];
    public function persona(){
        return $this->belongsTo("Persona", "CF", "CF");
    }
    public function staff(){
        return $this->hasOne("Staff", "code", "username");
    }
}

?>