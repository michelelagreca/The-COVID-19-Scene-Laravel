<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tampone extends Model
{
    protected $table = "tampone_eseguito";
    protected $primaryKey = "Codice";
    protected $autoIncrement = false;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'Codice',
        'Tipo_tampone',
        'operatore',
        'paziente',
        'ente',
        'data_effettuazione'
    ];

    public function operatore(){
        return $this->belongsTo("App\Models\Operatore", "operatore", "CF");
    }
    public function paziente(){
        return $this->belongsTo("App\Models\Paziente", "paziente", "CF");
    }
    public function ente(){
        return $this->belongsTo("App\Models\Ente", "ente", "Codice");
    }
    public function caratteristiche(){
        return $this->belongsTo("App\Models\TamponeCaratteristiche", "Tipo_tampone", "Codice");
    }

}

?>