// StarSky Class and Star Class
// renders sparkling skies over the background of the graphical window
// appended to main

// sparkling effect created by 1D noise that effects the greyscale and opacity value of star object


class StarSky
{

    // Star Array
    ArrayList<Star> stars = new ArrayList<Star>();

    StarSky( int minStars, int maxStars, float minIncrement, float maxIncrement )
    {
        int starCount = int( random( minStars, maxStars ) );

        for ( int i = 0; i < starCount; i++ )
        {
            float x = random( 0, width );
            float y = random( 0, height );
            PVector position = new PVector( x, y );
            
            float brightness = random( 0, 255 );

            float increment = random( minIncrement, maxIncrement );

            float radius = random( 1, 3 );

            stars.add( new Star( position, brightness, increment, radius ) );
        }
    }

    // called in main.draw()
    void updateSparkle()
    {
        for ( Star s : stars )
        {
            s.updateSparkle();
        }
    }

    // called in main.draw()
    void render()
    {
        for ( Star s : this.stars )
        {
            s.render();
        }
    }

    // Star innerClass
    // represents single star,a ll of which get handled by the StarSyk outer class
    class Star
    {
        PVector absPosition;
        float brightness;
        float xoff;
        float uniqueIncrement;
        float radius;

        Star( PVector initPosition, float initBrightness, float initIncrement, float initRadius )
        {
            this.uniqueIncrement = initIncrement;
            this.absPosition = initPosition;
            this.brightness = initBrightness;
            this.radius = initRadius;
        }

        void updateSparkle()
        {
            this.xoff += this.uniqueIncrement;
            this.brightness = max( 0, min( 255, noise( this.xoff ) * 255 ) );
        }

        void render()
        {
            noStroke();
            fill( this.brightness, this.brightness );
            pushMatrix();
                translate( this.absPosition.x, this.absPosition.y );

                ellipse( 0, 0, this.radius, this.radius );
            popMatrix();
        }

    }

}