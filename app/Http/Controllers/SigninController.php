<?php
    use Illuminate\Routing\Controller;
    use App\Models\Staff;
    use App\Models\Operatore;

    class SigninController extends Controller{
        public function signin(){
            $request = request();
            $operatore = Operatore::where('Matricola', $request->code)->first();
            if(isset($operatore)){
                $staff_code = Staff::where('code', $request->code)->first();
                if(!isset($staff_code)){
                    $staff = Staff::where('username', $request->username2)->first();
                    if(!isset($staff)){
                        Staff::create([
                            'code' => $request->code,
                            'username' => $request->username2,
                            'password' => $request->password
                        ]);
                        return redirect('access')->with('confirm', 'Staff registered');
                    }
                    else{
                        return redirect('access')->withInput()->with('errore2', 'Username already registered');
                    }
                }
                else{
                    return redirect('access')->withInput()->with('errore2', 'The code is already registered');
                }
            }
            else{
                return redirect('access')->withInput()->with('errore2', 'The code does not exist in the database');
            }
        }
    }
?>