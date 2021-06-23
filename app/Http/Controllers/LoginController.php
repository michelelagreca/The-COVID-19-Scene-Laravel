<?php
    use Illuminate\Routing\Controller;
    use App\Models\Staff;

    class LoginController extends Controller{
        public function login(){
            if(session('username') != null){
                $username = session('username');
                return view('services')->with('u', $username);
            }
            else{
                $old_username = Request::old('username');
                return view('access')->with('old_username', $old_username);
            }
        }

        public function checkLogin(){
            $staff = Staff::where('username', request('username'))->where('password', request('password'))->first();

            if(isset($staff)){
                Session::put('username', $staff->username);
                $username = $staff->username;
                return view('services', ['u' => $username]);
            }
            else{
                return redirect('access')->withInput()->with('errore', 'Credentials are not correct');
            }
        }
        public function logout(){
            Session::flush();
            return redirect('access');
        }
    }
?>