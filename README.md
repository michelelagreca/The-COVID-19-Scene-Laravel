# The COVID-19 Scene
This project is a website made as final project of the course of Web Programming that I followed in the Bachelor Degree of Computer Engineering with the Prof. Simone Palazzo.<br><br>
The COVID-19 Scene is a platform developed for a correct and useful approach to the new COVID-19 Pandemic. This website uses some functionalities used in another project called COVID-19 Management System. This project is available [here](https://github.com/michelelagreca/COVID-19-Management-System). The website and the database are used together to create the final platform.<br><br>
## Structure of the website
The project consists of a website developed in Laravel according to the MVC architecture. The subject of the site is the COVID-19 pandemic.
- The organization of the code respects the principles of separation of responsibilities: client side (HTML for the structure, CSS for the appearance, JavaScript for operation), server side (models for interacting with databases, routes / controllers for the logic of operation of pages, view for viewing pages).
- The layout of the pages is defined via CSS and Flexbox.
- Each page has a navigation bar, a body and a footer, where it is possible to access to information pages, such as About, Terms, Contacts, Email, and LinkedIn.
- The site must be accessible in mobile mode. In particular media queries are used to adapt dimensions and distances to the
mobile view.
- The project includes an authentication mechanism for users, and in particular the registration and login pages.
- The registration page carry out validity checks of the fields.
- The checks are performed both in JavaScript (before submitting the form) and in PHP (in
receipt of the form).
- All the pages of the site (except registration and login) interact with the server
MAINLY via REST requests.
- The site interact with two external services via REST API.
- The site data is saved in a relational database such as MySQL.
# Pages
## Home
The home page is a static page where it is possbile to access and check the last headlines of COVID-19 in the world, and the top tweets around the world about COVID-19.
## News
This page allow to search specific COVID-19 headlines regarding a county. They are going to be visualized in the same way of the home page.
## People
This page allow people to enter a name, surname, and ID and search for information about that person: general information, patient information, COVID-19 tests made by that person, tests results.
## Access
This page is a login / sign in page where staff and sanitary workers can register or access. A staff can access if it has a valid account already created. It is possible to register to this section by inserting an institutional code provided by the institution where a staff is working.
## Services
After the login, a staff can execute some services inside the platform. He can insert a COVID-19 test, or a test result. The data will be saved in a relational database. It is possible to logout by clicking the extra button in the navigation bar
