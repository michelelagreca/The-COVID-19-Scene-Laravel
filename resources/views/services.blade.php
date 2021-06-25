@extends('main')

@section('titolo', 'Staff - Services')

@section('style')
    <link rel="stylesheet" href="{{ asset('css/services.css') }}">
@endsection

@section('script')
    <script type="module" src="{{ asset('js/services.js') }}" defer></script>
@endsection

@section('otherLinks')
    <span id='currentsession'>{{ $u }}</span>
    <a href='{{ route("logout") }}' id="logout">logout</a>
@endsection

@section('corpo')
            <section id='services'>
                <div class="overlay"></div>
                <div class='form_cont'>
                    <h3>
                        Insert a COVID-19 Test.
                    </h3>
                    <h3 id='response' class='hidden'></h3>
                    <form name="tests" method='POST' action="">
                        @csrf
                        <input type='text' placeholder='ID' name='ID'>
                        <select name="type">
                            <option selected disabled value="">Choose the type</option>
                            <option value="2-Plex">2-Plex</option>
                            <option value="Anti-SARS-CoV-2_NCP">Anti-SARS-CoV-2_NCP</option>
                            <option value="Lumipulse_G_SARS-CoV-2_Ag">Lumipulse_G_SARS-CoV-2_Ag</option>
                            <option value="PrimeStore_MTM">PrimeStore_MTM</option>
                            <option value="YIG-AN-0010">YIG-AN-0010</option>
                            <option value="YIG-GM-0010">YIG-GM-0010</option>
                        </select>
                        <input type='text' placeholder='Staff Member' name='staff'>
                        <input type='text' placeholder='Patient ID' name='patient'>
                        <input type='text' placeholder='Hub' name='hub'>
                        <input type='date' placeholder='Date' name='date'>
                        <input type="submit" name='sub' value='Insert Test'>
                    </form>
                </div>
                <div class='form_cont'>
                    <h3>
                        Insert a COVID-19 Test Result.
                    </h3>
                    <h3 id='response_2' class='hidden'></h3>
                    <form name="results" method='POST' action="">
                        @csrf
                        <input type='text' placeholder='ID' name='ID'>
                        <select name="type">
                            <option selected disabled value="">Choose the type</option>
                            <option value="2-Plex">2-Plex</option>
                            <option value="Anti-SARS-CoV-2_NCP">Anti-SARS-CoV-2_NCP</option>
                            <option value="Lumipulse_G_SARS-CoV-2_Ag">Lumipulse_G_SARS-CoV-2_Ag</option>
                            <option value="PrimeStore_MTM">PrimeStore_MTM</option>
                            <option value="YIG-AN-0010">YIG-AN-0010</option>
                            <option value="YIG-GM-0010">YIG-GM-0010</option>
                        </select>
                        <input type='text' placeholder='Laboratory Code' name='lab'>
                        <input type='date' placeholder='Date' name='date'>
                        <input type='text' placeholder='Result (xx.xx)' name='res'>
                        <input type="submit" name='sub' value='Insert Result'>
                    </form>
                </div>
            </section>
@endsection
