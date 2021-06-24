<?php
    use Illuminate\Routing\Controller;
    use App\Models\Staff;
    use App\Models\Operatore;
    use App\Models\Paziente;
    use App\Models\Ente;
    use App\Models\Persona;
    use App\Models\Tampone;
    use App\Models\TamponeCaratteristiche;

    class ServiceController extends Controller{
        public function insertTest(Request $request){
            $output = array(
                "staff" => "yes",
                "patient" => "yes",
                "hub" => "yes",
                "id" => "yes",
                "data" => "yes",
                "died" => "yes"
            );
            $ID = Request::get('ID');
            $type = Request::get('Type');
            $staff = Request::get('Staff');
            $patient = Request::get('Patient');
            $hub = Request::get('Hub');
            $date = Request::get('Date');

            $operatore = Operatore::where('CF', $staff)->first();
            if(isset($operatore)){
                $paziente = Paziente::where('CF', $patient)->first();
                if(isset($paziente)){
                    $ente = Ente::where('Codice', $hub)->first();
                    if(isset($ente)){
                        $tampone = Tampone::where('Codice', $ID)->where('Tipo_tampone', $type)->first();
                        if(isset($tampone)){
                            $output['id'] = 'no';
                        }
                        else{
                            $tamponeData = TamponeCaratteristiche::select('Data_creazione')->where('Codice', $type)->get();
                            $d = new DateTime($date);
                            $t = new DateTime($tamponeData[0]->Data_creazione);
                            if($d > $t){
                                $staffData = Persona::select('data_decesso')->where('CF', $staff)->get();
                                $patData = Persona::select('data_decesso')->where('CF', $patient)->get();
                                $d1 = new DateTime($staffData[0]->data_decesso);
                                $d2 = new DateTime($patData[0]->data_decesso);
                                if(($d < $d1 || $d1 === NULL) && ($d < $d2 || $d2 === NULL)){
                                    Tampone::create([
                                        'Codice' => $ID,
                                        'Tipo_tampone' => $type,
                                        'operatore' => $staff,
                                        'paziente' => $patient,
                                        'ente' => $hub,
                                        'data_effettuazione' => $date
                                    ]);
                                }
                                else{
                                    $output['died'] = 'no';
                                }
                            }
                            else{
                                $output['data'] = 'no';
                            }
                        }
                    }
                    else{
                        $output['hub'] = 'no';
                    }
                }
                else{
                    $output['patient'] = 'no';
                }
            }
            else{
                $output['staff'] = 'no';
            }

            return $output;
        }

        public function insertResult(Request $request){

        }
    }
?>