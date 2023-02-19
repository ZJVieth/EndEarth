// DeltaTiming static class
// Class that handles system variables that are relevant to the smooth updating of game mechanics ( time-dependend rather than fps-dependend )
// initialized in main.setup()

// velocities are measured as unit/second
// the delta factor normalizes velocities to unit/tick (or unit/frame)

static class DeltaTiming
{
    static int fps;
    static int ms;
    static PApplet app;

    DeltaTiming( PApplet papp )
    {
        app = papp;
    }

    static void update()
    {
        fps = int( app.frameRate );
        ms = app.millis();
    }

    static int millis()
    {
        return ms;
    }

    static float deltaFactor()
    {
        return 1/float(fps);
    }

    static void displayFPS()
    {
        app.textSize( 16 );
        app.textAlign( LEFT, TOP );
        app.fill( 255 );
        app.text( "FPS: " + fps, 15, 15 );
    }

}