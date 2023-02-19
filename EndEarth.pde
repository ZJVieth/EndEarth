//---------------------------------------------
// "End Earth" (working title)
// v1.0
// by Zino J. Vieth
// University of Twente
// Creative Technology, Module 4
// Algorithms in Creative Technology
//---------------------------------------------

// Credits:
// All code and images by Zino J. Vieth
// with inspirations by Daniel Shiffman
// Uses the Cooper Black Font by Oswald Bruce Cooper

// Variable abbreviations:
// abs-     Absolute        :   used for absolute positioning vectors that only stand in relation to the origin point (0,0)
// rel-     Relative        :   used for relative positioning vectors that are used to calculate and render positions relative to a higher level relative or absolute vector
// err-     Error           :   used for variables that catch potential error sources
// diff-    Difference      :   used for variables that contain the difference or distance between two points
// init-    Initial         :   used for parameters that initiate a class field
// og-      Original        :   used for variables that hold an initial/original value of another variable (or start value)
// vf-      Visual Force    :   used for variables related to the visualization of gravity on the Mouse Controller object
// -PS      ParticleSystem  :   used for Particle System objects
// min-     Minimum         :   used for variables that contain the minimum value of a field
// max-     Maximum         :   used for variables that contain the maximum value of a field

// ----------------------------------------------------------------------------------------------------------------------------------------------
// Code Start

// Java Imports
import java.util.concurrent.atomic.AtomicBoolean; // used for thread handling (termination) for nebula 3d noise updates

// <Global Constants>

    // ZONE MECHANICS
    //      relevant to:
    //      Earth, Cities, City, House, CollisionHandler
    final static int ZONE_ERROR = 0;
    final static int ZONE_LAND = 1;
    final static int ZONE_SEA = 2;
    final static int ZONE_ICE = 3;
    final static int ZONE_CITY = 4;
    final color [] ZONE_COLOR = {
        color( 255, 0, 0 ),
        color( 0, 255, 0 ),
        color( 0, 0, 255 ),
        color( 255, 255, 255 ),
        color( 100, 100, 100 )
    };

    // PARTICLE MODES
        final static int PARTICLE_MODE_GRAVITATE = 1;

// </Global Constants>

// <Program Flow Variables and Buttons>

    static int programState;
    final static int STATE_MENU = 0;
    final static int STATE_PLAY = 1;
    final static int STATE_GAMEOVER = 2;

    Button playButton;
    Button gameoverButton;

// </Program Flow Variables and Buttons>

// <Game Objects>
    Earth earth;
    Rocks rocks;
    Meteorites meteorites;
    MouseController mouseController;
    StarSky starSky;
    Nebula nebula;
// </Game Objects>

// ----------------------------------------------------------------------------------------------------------------------------------------------
// On Program Load
void setup()
{
    // <Sketch Settings>
        size( 1200, 600, P2D );
            frameRate( 60 );
            noCursor();
            imageMode( CENTER );
    // </Sketch Settings>

    // <Static Initializations>
        new Gamestate( this );
        new DeltaTiming( this );
        new CollisionHandler( this );
        new ButtonHandler( this );
    // </Static Initializations>

    // <Player Mouse Controller Setup>

        mouseController = new MouseController( 100, 50, 20, 6 );
        // ( Gravitational Acceleration [px/s^2], Range of Influence [px], Visual Force Speed [%/s], Visual Force Spawn Frequency [VF/s] )

        mouseController.setHyperForce( 500, 2000, 100 );
        // ( Gravitational Acceleration [px/s^2], Range of Influence [px] )

    // </Player Mouse Controller Setup>

    // <Rock Handler Setup>
        rocks = new Rocks( "rock.png" );
    // </Rock Handler Setup>

    // <Meteorite Handler Setup>
        meteorites = new Meteorites( 10, 15, 0.1, 0.01 );                       // ( Min Flock Size, Max Flock Size, Flock Spawn Frequency [Flock/s], Spawn Frequency Randomization Margin [Flock/s])
        
        meteorites.setSpawnArea( width+100, -100, width+600, height+100, 20 );  // ( Min X, Min Y, Max X, Max Y, Spawn Radius Factor [px/Flock Size] )
        meteorites.setVelocity( 200, 300, 50, 0.1 );                            // ( Min Velocity [px/s], Max Velocity [px/s], Velocity Randomization Margin [px/s], Spawn Direction Margin [radians] )
        meteorites.setFlockingBehaviour( 5, 1, 1, 60, 100, 150 );               // ( Separation Weighting, Alignment Weighting, Cohesion Weighting, Separation Distance, Neighbour Distance, Max Steering Force )

        meteorites.addImage( "meteorite1.png" );
        meteorites.addImage( "meteorite2.png" );
        meteorites.addImage( "meteorite3.png" );
    // </Meteorite Handler Setup>

    // <Earth Object Setup>
        earth = new Earth( 100, width/4, height/2, 0.3 );                       // ( Radius [px], Anchor Position X [px], Anchor Position Y [px], Rotation Speed [radians/s] )
        
        earth.setImage( "earth.png" );
        earth.appendGravity( 80, 1000 );                                        // ( Gravitational Acceleration [px/s^2], Range of Influence [px] )
        earth.createAnchoredSpring( 4, 1 );                                     // ( Spring Constant, Friction Constant )
        earth.createVolcano( "volcano4.png", 105, 0, -PI/2, 150, 40, 3, 10 );   // ( Image File, Position x [px], Position y [px],  Rock Shooting Velocity [px/s], Shooting Velocity Margin [px/s], Min Shot Delay [s], Max Shot Delay [s] )
        earth.createVolcano( "volcano4.png", 105, 0, PI/2+0.4, 150, 40, 3, 10 );
        earth.createVolcano( "volcano4.png", 105, 0, PI-0.2, 150, 40, 3, 10 );
        earth.initiateClouds( 0.5, 0.05, 3, 6, 15, 25, 6, 1.5 );                // ( Spawn Frequency [Cloud/s], Spawn Frequency Randomization Margin [Cloud/s], Min Lifetime [s], Max Lifetime [s], Min Cloud Size [Patches], Max Cloud Size [Patches], Width Gauss Factor, Height Gauss Factor )
        earth.initiateCities( 5, 0.8, 0.03, 5, 10 );                            // ( Max Active Cities [Cities], House Spawn Frequency [Houses/s], Zone Rotation Steps [radians], Min City Size [Zones], Max City Size [Zones] )
    // </Earth Object Setup>

    // <Background Objects>
        starSky = new StarSky( 20, 40, 0.01, 0.02 );    // Min Star Count [Stars], Max Star Count [Stars], Min Brightness Noise Increment [Increment/tick], Max Brightness Noise Increment [Increment/tick]

        nebula = new Nebula();
        nebula.start();     // starts external thread for nebula noise updates
    // </Background Objects>

    // <Collision Parameters>
        CollisionHandler.setZoneRockMargin( 5 );                                // ( Collision Distance between Earth Radius and Rock Center [px] )
    // </Collision Parameters>

    // <Program State and HUD Setup>
        programState = STATE_MENU;  // sets start state
        playButton = ButtonHandler.addButton( new Button( 900, 300, "playButton.png", "playButtonHover.png" ) );
        gameoverButton = ButtonHandler.addButton( new Button( 900, 300, "gameoverButton.png", "gameoverButtonHovered.png" ) );

        Gamestate.setHUDFont( "coopbl.ttf", color( 38, 127, 0 ) );
        Gamestate.setScoreHUD( "scoreHUD.png", 990, 60 );
        Gamestate.setHyperForceHUD( "hyperForceHUD.png", 990, 540 );
        Gamestate.setHighscoreHUD( "highscoreHUD.png", 900, 100 );
        Gamestate.setCreditsHUD( "creditsHUD.png", 900, 500 );

        Gamestate.readInitialHighscore();
    // </Program State and HUD Setup>
}

// ----------------------------------------------------------------------------------------------------------------------------------------------
// Main Program Loop (Graphic Window)
void draw()
{
    // <Visual Rendering>
        background( 0 );
        nebula.render();
        starSky.render();

        earth.renderAtmosphere();
        meteorites.render();
        rocks.render();
        earth.render();
        GlobalParticles.render();
        
        switch( programState )
        {
            case STATE_MENU:
                playButton.render();
                Gamestate.renderHighscore();
                Gamestate.renderCredits();
               
                break;
            case STATE_PLAY:
                Gamestate.renderScore();
                Gamestate.renderHyperForce();
                DeltaTiming.displayFPS();

                break;
            case STATE_GAMEOVER:
                gameoverButton.render();
                Gamestate.renderScore();

                break;
        }
        
        mouseController.render();

    // </Visual Rendering>

    // <Updates>

        // Every State
            DeltaTiming.update();

            mouseController.updateVisualForce();
            mouseController.updateVisualHyperForce();

            starSky.updateSparkle();

            earth.updateRotation();
            earth.updateZonePhysics();
            earth.updateClouds();

            earth.updateHyperForcePhysics( mouseController.hyperForce() );
            earth.updateSpringPhysics();
            earth.updatePosition();

            rocks.updatePhysics( earth.gravity() );
            rocks.updatePhysics( mouseController.gravity() );
            rocks.updatePhysics( mouseController.hyperForce() );
            rocks.updatePositions();
            rocks.updateFireTrail();

            meteorites.updateFlockBehaviour();
            meteorites.updateObjectDeletion();

            GlobalParticles.update();

            CollisionHandler.updateZoneRockCollision( earth, rocks );
            CollisionHandler.updateEarthMeteoriteCollision( earth, meteorites );


        // State Specific
            switch ( programState )
            {
                case STATE_MENU:

                    break;
                case STATE_PLAY:
                    meteorites.updateSpawning();

                    earth.updateEmissions();
                    earth.updateCitySpawning();
                    earth.updateVolcanoActivity();
                    earth.updateVolcanoShooting( rocks );

                    break;
                case STATE_GAMEOVER:

                    break;
            }

    // </Updates>
}

// ----------------------------------------------------------------------------------------------------------------------------------------------
// On Exit Executions
void exit()
{
    nebula.stop(); // terminate additional thread
    super.exit();
}

// ----------------------------------------------------------------------------------------------------------------------------------------------
// <Mouse Event Handling>

    void mouseMoved()
    {
        PVector mouse = new PVector( mouseX, mouseY );
        mouseController.updatePosition( mouseX, mouseY );
        ButtonHandler.checkHover( mouse );
    }

    void mouseDragged()
    {
        mouseMoved();
    }

    void mousePressed()
    {
        switch ( programState )
        {
            case STATE_PLAY:
                mouseController.activateHyperForce();
                break;
        }
    }

    void mouseReleased()
    {
        switch ( programState )
        {
            case STATE_MENU:
                if ( playButton.pressed() ) startGame();

            case STATE_PLAY:
                mouseController.deactivateHyperForce();
                break;

            case STATE_GAMEOVER:
                if ( gameoverButton.pressed() ) resetGame();
        }
    }

// </Mouse Event Handling>

// <Program Flow Methods>

    	void startGame()
        {
            new Gamestate();
            programState = STATE_PLAY;
        }

        static void gameOver()
        {
            programState = STATE_GAMEOVER;
        }

        void resetGame()
        {
            Gamestate.updateHighscore();
            new Gamestate();
            earth.reset();
            programState = STATE_MENU;
        }

// </Program Flow Methods>