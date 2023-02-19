
// Nebula Class
// updates the background with a 3D noise function to render red fog onto the screen
// starts an additional thread for the noise updates to save fps, gets terminated on program exit()


class Nebula implements Runnable
{
    // <Class Fields>
        // Noise Update Values
        float [][] alpha;
        float time;

        // Thread Control
        private Thread thread;
        private AtomicBoolean running = new AtomicBoolean( false );     // using ATomicBoolean to avoid concurrent modification exceptions caused by accesing noise values in both threads

    // </Class Fields>

    // <Constrcutor>
        Nebula()
        {
            alpha = new float[width][height];
        }
    // </Constructor>

    // Method used to start the thread that updates the nebula noise values
    // called in main.setup()
    void start()
    {
        thread = new Thread( this );
        thread.start();
    }

    // Method used to terminate the thread that updates the nebula noise values by letting it run out
    // called in main.exit()
    void stop()
    {
        running.set( false );
    }

    // Thread Body, loops untils being terminated by this.stop()
    void run()
    {
        running.set( true );

        while( running.get() )
        {
            float xoff = 0.001;
            float yoff = 0.0011;
            time += 0.001;

            noiseDetail( 6, 0.5 );

            for ( int i = 0; i < width; i++ )
            {
                for ( int j = 0; j < height; j++ )
                {
                    alpha[i][j] = noise( i*xoff, j*yoff, time ) * 255 - 150;
                    alpha[i][j] = min( 255, alpha[i][j] );
                    alpha[i][j] = max( 0, alpha[i][j] );
                }
            }
        }
    }

    // Render Method
    // called in main.draw()
    void render()
    {
        loadPixels();
        for ( int i = 0; i < width; i++ )
        {
            for ( int j = 0; j < height; j++ )
            {
                color col = color( alpha[i][j], 0, 0 );

                int n = j * width + i;
                pixels[n] = col;
            }
        }
        updatePixels();
    }

}