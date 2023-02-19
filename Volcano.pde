// Volcano class
// handles rock shooting as a mechanic of the earth game object
// appended to the Earth game object


class Volcano
{

    // <Class Fields>
        PImage img, rockImg;
        PVector relPosition;
        float rotation;
        float finalX;
        float ogX;

        boolean active;

        float shootVelocityFactor;  // used as the average velocity with which the volcano shoots
        float shootVelocityMargin;  // used as the margins by which to randomize the velocity with which the volcano shoots
        PVector shotDelayLimits;    // contains the time delay limits after which the volcano will fire the next shot; x: min, y: max
        int nextShotDelay;
        int shotTimer;
    // </Class Fields>

    // <Constructor>
        Volcano( String file, float initX, float initY, float initRotation, float initShootVelocityFactor, float initShootVelocityMargin, float delayLimitX, float delayLimitY )
        {
            this.img = loadImage( file );
            this.finalX = initX;
            this.ogX = initX-20;
            this.relPosition = new PVector( this.ogX, initY );
            this.rotation = initRotation;

            this.shootVelocityFactor = initShootVelocityFactor;
            this.shootVelocityMargin = initShootVelocityMargin;
            this.shotTimer = DeltaTiming.millis();
            this.nextShotDelay = int( random( 5000, 10000 ) );
            this.shotDelayLimits = new PVector( delayLimitX*1000, delayLimitY*1000 );
        }
    // </Constructor>

    // Tick Update Method which handles the shooting of rocks and responsible timers
    // called in Earth.updateVolcanoShooting()
    void updateShooting( Rocks rockHandler, PVector earthPosition, float earthRotation )
    {
        if ( this.active )
        {
            // if timer delay is reached
            if ( DeltaTiming.millis() - this.shotTimer > this.nextShotDelay )
            {
                // cause the volcano to shoot
                this.shoot( rockHandler, earthPosition, earthRotation );

                // reset timer
                this.shotTimer = DeltaTiming.millis();

                // set a new random shot delay
                this.nextShotDelay = int( random( this.shotDelayLimits.x, this.shotDelayLimits.y ) );
            }
        }
    }

    // Method that pushes the volcano towards its position ont he earth surface once it is activated
    // called in Earth.updateVolcanoActivity()
    void updateActive()
    {
        if ( this.active )
        {
            this.relPosition.x = min( this.finalX, this.relPosition.x+0.1 );
        }
    }

    // Method used to activate a volcano
    // called in Earth.updateVolcanoActivity
    void activate()
    {
        this.active = true;
    }

    // Method that causes new rocks to spawn when the shot timer fires
    // called in this.updateShooting()
    void shoot( Rocks rockHandler, PVector earthPosition, float earthRotation )
    {
        // get the direction that the volcano is currently facing
        PVector direction = PVector.fromAngle( earthRotation + this.rotation );

        // get the absolute spawn location of the rock ( absEarthPos + relVolcanoPos )
        PVector position = earthPosition.copy().add( direction.copy().mult( this.relPosition.mag() ) );

        // get the random velocity with which the rock will be shot
        float meanF = this.shootVelocityFactor;
        float marginF = this.shootVelocityMargin;
            float force = random( meanF-marginF, meanF+marginF );

            PVector velocity = direction.copy().mult( force );

        // spawn new rock
        rockHandler.addRock( position, velocity );
    }

    // Render Method
    // called in Earth.render()
    void render()
    {
        pushMatrix();
            rotate( this.rotation );
            translate( this.relPosition.x, this.relPosition.y );

            pushMatrix();
                rotate( PI/2 );
                image( this.img, 0, 0 );
            popMatrix();
        popMatrix();
    }

}