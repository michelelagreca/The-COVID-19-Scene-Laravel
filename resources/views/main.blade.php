<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="csrf-token" content="{{ csrf_token() }}">
        <title>@yield('titolo')</title>
        <link rel="shortcut icon" type="png" href="{{ asset('images/logo4.png') }}" />
        <link rel="stylesheet" href="{{ asset('css/home.css') }}">
        @yield('style')
        @yield('script')
        
    </head>
    <body>
        <div id="main">
            <nav id='nav_invisible'>
                <div id='container_lines'>
                    <div></div>
                    <div></div>
                    <div></div>
                </div>
            </nav>
            <nav id="nav_main">
                <div id="logo">
                    <img src="{{ asset('images/logo2.png') }}">
                </div>
                <div id="links">
                    @yield('otherLinks')
                    <a href='{{route("home")}}' id="home_button">Home</a>
                    <a href='{{ route("news") }}' id="about_nav">News</a>
                    <a href='{{ route("people") }}' id="people_nav">People</a>
                    <a href='{{ route("access") }}' id="staff_nav">Staff</a>
                </div>
            </nav>
            @yield('corpo')
            <footer>
                <div id="infos">
                    <div id="logo">
                        <img src="{{ asset('images/logo2.png') }}">
                    </div>
                    <div id="useful_links">
                        <h3>Useful Links</h3>
                        <a href='{{ route("contact") }}'>Contact</a>
                        <a href='{{ route("about") }}'>About</a>
                        <a href='{{ route("terms") }}'>Term and Conditions</a>
                    </div>
                    <div id="contact_us">
                        <h3>Contact Us</h3>
                        <a href= "mailto:michelelagreca.contact@gmail.com">Email</a>
                        <a href="https://www.linkedin.com/in/michelelagreca/">Linkedin</a>
                    </div>
                </div>
                <div id="rights">
                    Developed by Michele La Greca 
                </div>
            </footer>
        </div>
        @yield('load')
    </body>
</html>