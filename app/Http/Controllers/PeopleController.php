<?php
    use Illuminate\Routing\Controller;

    use App\Models\Persona;
    use App\Models\Paziente;
    use App\Models\Tampone;
    use App\Models\Esito;

    class PeopleController extends Controller{
        public function getInfo(Request $request){
            $output = array(
                "person" => "yes",
                "get_info" => "no",
                "get_pat" => "no",
                "get_test" => "no",
                "get_result" => "no",
                "error" => "no",
                "dati" => []
            );
            $ID = Request::get('ID');
            $name = Request::get('Name');
            $surname = Request::get('Surname');
            $sub = Request::get('Sub');

            $persona = Persona::where('CF', $ID)->where('Nome', $name)->where('Cognome', $surname)->first();
            if(isset($persona)){
                if($sub=='Get General Information'){
                    $output['get_info'] = 'yes';
                    $persona = Persona::where('CF', $ID)->where('Nome', $name)->where('Cognome', $surname)->get();
                    $array[0]=array("ID"=>$persona[0]->CF,"Name"=>$persona[0]->Nome,"Surname"=>$persona[0]->Cognome,"Born"=>$persona[0]->Data_nascita,"Email"=>$persona[0]->email,"Address"=>$persona[0]->Indirizzo,"City"=>$persona[0]->Domicilio,"Die Date"=>$persona[0]->data_decesso,"Died"=>$persona[0]->decesso_COVID19);
                    $output['dati'] = json_encode($array);
                }
                else if($sub=='Get Patient Information'){
                    $output['get_pat'] = 'yes';
                    $paziente = Paziente::where('CF', $ID)->first();
                    if(isset($paziente)){
                        $paziente = Paziente::where('CF', $ID)->get();
                        $array[0]=array("ID"=>$paziente[0]->CF,"Condition"=>$paziente[0]->condiz_attuale,"Quarantine"=>$paziente[0]->obbligo_quarantena);
                        $output['dati'] = json_encode($array);
                    }
                }
                else if($sub=='Get All COVID19 Tests'){
                    $output['get_test'] = 'yes';
                    $tamponi = Tampone::where('paziente', $ID)->first();
                    if(isset($tamponi)){
                        $tamponi = Tampone::where('paziente', $ID)->get();
                        for($i = 0;$i < count($tamponi);$i++){
                            $array[$i]=array("ID"=>$tamponi[$i]->Codice,"Type"=>$tamponi[$i]->Tipo_tampone,"Staff"=>$tamponi[$i]->operatore,"Patient"=>$tamponi[$i]->paziente,"Hub"=>$tamponi[$i]->ente,"Date"=>$tamponi[$i]->data_effettuazione);
                        }
                        $output['dati'] = json_encode($array);
                    }
                }
                else if($sub=='Get All COVID19 Test Results'){
                    $output['get_result'] = 'yes';
                    $tamponi = Tampone::where('paziente', $ID)->first();
                    if(isset($tamponi)){
                        $tamponi = Tampone::select('Codice', 'Tipo_tampone')->where('paziente', $ID)->get();
                        $w = 0;
                        for($i = 0; $i<count($tamponi);$i++){
                            $esiti = Esito::where('Tampone', $tamponi[$i]->Codice)->where('Tipo_tampone', $tamponi[$i]->Tipo_tampone)->first();
                            if(isset($esiti)){
                                $esiti = Esito::where('Tampone', $tamponi[$i]->Codice)->where('Tipo_tampone', $tamponi[$i]->Tipo_tampone)->get();
                                for($j = 0; $j < count($esiti);$j++){
                                    $array[$w]=array("ID"=>$esiti[$j]->Tampone,"Type"=>$esiti[$j]->Tipo_tampone,"Laboratory"=>$esiti[$j]->Lab_analisi,"Date"=>$esiti[$j]->data_e,"Result"=>$esiti[$j]->Risultato);
                                    $w = $w + 1;
                                }
                            }
                        }
                        $output['dati'] = json_encode($array);
                    }
                }
            }
            else{
                $output['person'] = 'no';
            }

            return $output;
        }
    }
?>