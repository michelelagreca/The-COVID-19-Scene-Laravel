<?php
    use Illuminate\Routing\Controller;

    class AccessController extends Controller{
        public function access(){
            if(session('username?') != null){
                return redirect('services');
            }
            else{
                return redirect('access');
            }
        }
    }
?>