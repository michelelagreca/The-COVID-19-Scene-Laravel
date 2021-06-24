<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ente extends Model
{
    protected $table = "ente_covid19";
    protected $primaryKey = "Codice";
    protected $autoIncrement = true;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'Codice',
        'Nome',
        'Sede',
        'indirizzo',
        'Tipo',
        'Controllore'
    ];
    public function tampone(){
        return $this->hasMany("App\Models\Tampone", "ente", "Codice");
    }
}

?>