<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lab extends Model
{
    protected $table = "lab_analisi";
    protected $primaryKey = "codice";
    protected $autoIncrement = true;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'codice',
        'nome',
        'indirizzo',
        'sede'
    ];
    public function esito(){
        return $this->hasMany("App\Models\Esito", "Lab_analisi", "codice");
    }

}

?>