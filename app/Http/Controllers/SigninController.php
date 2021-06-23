<?php
    use Illuminate\Routing\Controller;
    use App\Models\Staff;
    use App\Models\Operatore;

    class SigninController extends Controller{
        public function signin(){
            $request = request();
            return Staff::create([
                'code' => $request->code,
                'username' => $request->username,
                'password' => Hash::make($request->password)
            ]);
            
        }

        public function checkUsername($query){
            $exists = Staff::where('username', $query)->exists();
            return ['exists' => $exists];
        }

        public function checkCode($query){
            $exists = Operatore::where('Matricola', $query)->exists();
            return ['exists' => $exists];
        }
        
        public function index(){
            return view('access');
        }
    }
?>