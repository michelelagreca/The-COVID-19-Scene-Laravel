<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Persona extends Model
{
    protected $table = "persona";
    protected $primaryKey = "CF";
    protected $autoIncrement = true;
    // public $incrementing = true;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'CF',
        'Nome',
        'Cognome',
        'Data_nascita',
        'email',
        'Indirizzo',
        'Domicilio',
        'data_decesso',
        'decesso_COVID19'

    ];
    public function operatore(){
        return $this->hasOne("Operatore", "CF", "CF");
    }
    public function paziente(){
        return $this->hasOne("Paziente", "CF", "CF");
    }
}

?>