<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Paziente extends Model
{
    protected $table = "paziente";
    protected $primaryKey = "CF";
    protected $autoIncrement = false;
    // public $incrementing = false;
    protected $keyType = "integer";
    public $timestamps = false;

    protected $fillable = [
        'CF',
        'condiz_attuale',
        'obbligo_quarantena'

    ];
    public function persona(){
        return $this->belongsTo("Persona", "CF", "CF");
    }
    public function tampone(){
        return $this->hasMany("App\Models\Tampone", "paziente", "CF");
    }
}

?>