@extends('main')

@section('titolo', 'Staff - Access')

@section('style')
<link rel="stylesheet" href="{{ asset('css/login_staff.css') }}">
@endsection

@section('script')
    <script type="module" src="{{ asset('js/home.js') }}" defer></script>
    <script type="module" src="{{ asset('js/login_staff.js') }}" defer></script>
@endsection

@section('corpo')
            <section id='login_section'>
                <h3>
                    Enter to the platform as a COVID-19 Staff.
                </h3>
                <h3>
                    Log in
                </h3>
                <div class="overlay"></div>
                <div id="errore_log">{{Session::get('errore')}}</div>
                <form name="form_login" method='POST' action="{{ route('login') }}">
                    @csrf
                    <input type='text' placeholder='Username' name='username' value='{{ old("username") }}'>
                    <input type='password' placeholder='Password' name='password'>
                    <input type="submit" name='sub' value='Log In'>
                </form>
                <h3>
                    or Sign Up.
                </h3>
                <form name="form_signin" method='POST' action="{{ route('signin') }}">
                    @csrf
                    <input type='text' placeholder='Institutional Code' name='code'>
                    <input type='text' placeholder='Username' name='username'>
                    <input type='password' placeholder='Password' name='password'>
                    <input type="submit" name='sub' value='Sign In'>
                </form>
            </section>
@endsection
