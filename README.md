gloss
=====

Gloss hides the pain of drawing simple vector graphics behind a nice
data type and a few display functions. 

* Home page and bug tracker are on a [separate site](http://gloss.ouroborus.net).

* PULL REQUESTS: If you want your pull request merged then send email to benl AT ouroborus.net. I don't pay attention to github notifications, but am happy to receive emails from people. If you have changed any internal functionality then please test that all the gloss-examples still work before submitting your pull request.

Example
-------
Getting something on the screen is as easy as:

    import Graphics.Gloss
    main = display (InWindow "Nice Window" (200, 200) (10, 10)) white (Circle 80)


Usage
-----
Once the window is open you can use the following:

* Quit            - esc-key.
* Move Viewport   - left-click drag, arrow keys.
* Rotate Viewport - right-click drag, control-left-click drag, or home/end-keys.
* Zoom Viewport   - mouse wheel, or page up/down-keys.

More
----
* Animations and simulations can be constructed similarly using the 'animate' and 'simulate' functions
* Games with user input can be constructed with the 'play' function.
* See the gloss-examples package for more.
