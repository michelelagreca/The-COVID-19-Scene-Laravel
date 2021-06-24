@extends('main')

@section('titolo', 'People')

@section('style')
<link rel="stylesheet" href="{{ asset('css/people.css') }}">
<link rel="stylesheet" href="{{ asset('css/services.css') }}">
@endsection

@section('script')
    <script type="module" src="{{ asset('js/people.js') }}" defer></script>
@endsection

@section('corpo')
            <section id='people'>
                <div class="overlay"></div>
                <div class='form_cont_people'>
                    <h3>
                        Get information about a person.
                    </h3>
                    <h3 id="check_person" class="hidden"></h3>
                    <form name="info">
                        @csrf
                        <input type='text' placeholder='ID' name='ID'>
                        <input type='text' placeholder='Name' name='name'>
                        <input type='text' placeholder='Surname' name='surname'>
                        <input type="submit" name='sub' value='Get General Information'>
                        <input type="submit" name='sub' value='Get Patient Information'>
                        <input type="submit" name='sub' value='Get All COVID19 Tests'>
                        <input type="submit" name='sub' value='Get All COVID19 Test Results'>
                    </form>
                </div>
                <div id='result_query'>
                    <table id="tabella" class="hidden"></table>
                    <h3 id='specifier' class='hidden'></h3>
                </div>
            </section>
@endsection
