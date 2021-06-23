<?php
    use Illuminate\Routing\Controller;

    class LogoutController extends Controller{
        public function logout(){
            Session::flush();
            return redirect('login');
        }
    }
?>