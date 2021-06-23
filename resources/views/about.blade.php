
@extends("main")

@section('titolo', 'About')

@section('style')
    <link rel="stylesheet" href="{{ asset('css/text.css') }}">
@stop

@section('corpo')
            <section id='text'>
                <div class="overlay"></div>
                <p>
                    Coronavirus disease (COVID-19) is an infectious disease caused by a newly discovered coronavirus.<br><br>

                    Most people infected with the COVID-19 virus will experience mild to moderate respiratory illness and recover without requiring special treatment.  
                    Older people, and those with underlying medical problems like cardiovascular disease, diabetes, chronic respiratory disease, 
                    and cancer are more likely to develop serious illness.<br><br>

                    The best way to prevent and slow down transmission is to be well informed about the COVID-19 virus, the disease it causes and how it spreads. 
                    Protect yourself and others from infection by washing your hands or using an alcohol based rub frequently and not touching your face. <br><br>

                    The COVID-19 virus spreads primarily through droplets of saliva or discharge from the nose when an infected person coughs or sneezes, 
                    so it’s important that you also practice respiratory etiquette (for example, by coughing into a flexed elbow).<br><br>
                </p>
                <p>
                    The COVID-19 Scene is a platform developed for the correct and useful approach to the new COVID-19 Pandemic.<br><br>

                    Firstly, in the Home page it is possible to find the Top Headlines form the globe about COVID-19, plus some tweets realted to this topic.<br><br>

                    In the News page it is possible to select a country and get the earliest news about COVID-19 in that country.<br><br>

                    The most important functionalities are in the People and Staff section.<br><br>

                    The people section has been developed to allow people to search the condition of a person in the database. It is possible to get the main information of a person,
                    the clinic and health situation, the information about all the COVID-19 test that a person has been made, and get all the result of those tests. This is possible by filling
                    the form with the ID person, name and surname.<br><br>

                    In the Staff section, it is possible to log in if a user has a valid account, or sign up using the institutional code that a person has to work with a healthy organizzation.
                    Once logged in, a staff can insert a COVID-19 test by adding all its information, or add a test result in the same way.<br><br>

                    Since the database that is connected to this platform has more functionalities, it will be possible to extend the functions of this platform, handling, for instance, vaccination,
                    developing of new type of COVID-19 test or vaccines, and so on.<br><br>
                </p>
            </section>
@stop

