<?php
    use Illuminate\Routing\Controller;

    class HomeController extends Controller{
        public function news(){
            $api_key = "b312742c70974a7f9d4c7919b710d7c6";
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, "https://newsapi.org/v2/top-headlines?q=covid&apiKey=".$api_key);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1); /* the parameter 1 is saying that the call will return a string*/
            $result = curl_exec($curl);
            curl_close($curl);
            return $result;
        }

        public function tweets(){
            $api_key = "ofLC1BaB7FQ4PchA82J6vf3GI";
            $api_secret_key = "uLFkEfbucMSaIZF9gnmszxXd7HldO83oZEzvulGFMHr6ruIb7R";
            $endpoint_search = "https://api.twitter.com/2/tweets/search/recent?query=covid19&max_results=10";
            $token_request = 'https://api.twitter.com/oauth2/token';

            // Token request
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, $token_request);
            curl_setopt($curl, CURLOPT_POST, 1);
            curl_setopt($curl, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
            $headers = array("Authorization: Basic ".base64_encode($api_key.":".$api_secret_key));
            curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
            $result = curl_exec($curl);
            curl_close($curl);

            $token = json_decode($result)->access_token;
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, $endpoint_search);
            $headers = array("Authorization: Bearer ".$token);
            curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
            $result = curl_exec($curl);
            curl_close($curl);
            return $result;
        }
    }
?>