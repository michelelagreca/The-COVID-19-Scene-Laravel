<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TamponeCaratteristiche extends Model
{
    protected $table = "tampone";
    protected $primaryKey = "Codice";
    protected $autoIncrement = false;
    // public $incrementing = false;
    protected $keyType = "string";
    public $timestamps = false;

    protected $fillable = [
        'Codice',
        'Produttore',
        'Data_creazione'
    ];

    public function tampone(){
        return $this->hasMany("App\Models\Tampone", "Tipo_tampone", "Codice");
    }

}

?>