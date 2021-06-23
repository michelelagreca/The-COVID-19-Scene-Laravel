
@extends("main")

@section('titolo', 'The Covid-19 Scene')

@section('script')
    <script type="module" src="{{ asset('js/home.js') }}" defer></script>
@stop

@section('corpo')
            <header>
                <div class="overlay"></div>
                <div id="logo_img">
                    <div id="ani"></div>
                </div>
                <div class="descriptions">
                    <div>
                        Monitoring the global COVID-19 Scene.
                    </div> 
                    <div>
                        Stay safe.
                    </div> 
                </div>
            </header>
            <article>
                <div class="overlay_stronger"></div>
                <h2>
                    Top Headlines from the Globe.
                </h2>
                <section id="news"></section>
                <section id="tweets"></section>
            </article>
@stop

@section('load')
    <div id="loading">
            <span class="loader"></span>
    </div>
@stop

