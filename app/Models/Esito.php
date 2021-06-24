<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Esito extends Model
{
    protected $table = "esito";
    protected $primaryKey = "Tampone";
    protected $autoIncrement = false;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'Tampone',
        'Tipo_tampone',
        'Lab_analisi',
        'data_e',
        'Risultato'
    ];
    public function lab(){
        return $this->belongsTo("App\Models\Lab", "Lab_analisi", "codice");
    }
    public function tampone(){
        return $this->belongsToMany("App\Models\Tampone", "Tampone", "Codice");
    }

}

?>