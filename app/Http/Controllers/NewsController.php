<?php
    use Illuminate\Routing\Controller;

    class NewsController extends Controller{
        public function getNews(Request $request){
            $country = Request::get('Country');
            $api_key = "b312742c70974a7f9d4c7919b710d7c6";
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, "https://newsapi.org/v2/top-headlines?q=covid&country=".$country."&apiKey=".$api_key);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1); /* the parameter 1 is saying that the call will return a string*/
            $result = curl_exec($curl);
            curl_close($curl);
            return $result;
        }
    }
?>