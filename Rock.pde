// Rock Class
// missile object to be shot by volcano
// handled by array in volcano class


class Rock
{

    // <Class Fields>
        PImage img;

        PVector absPosition, velocity;
        float rotation;

        ParticleSystem fireTrailPS;
        ParticleSystem rockExplosion;
    // </Class Fields>

    // <Constructor>
        Rock( PVector initPosition, PVector initVelocity, PImage initImage )
        {
            this.absPosition = initPosition;
            this.velocity = initVelocity;
            this.img = initImage;

            // Setup Particle System : Fire Trail
                // Calculate Velocity Angle
                float particleAngle = this.velocity.heading() + PI;
                float angleMargin = 0.2;

                // Create Particle System
                this.fireTrailPS = new ParticleSystem( 50, 0.5, 1 );
                    this.fireTrailPS.setColourBase( 200, 50, 50, 25 );
                    this.fireTrailPS.setRelativeSpawnDirection( particleAngle-angleMargin, particleAngle+angleMargin );
                    this.fireTrailPS.setParticleVelocity( 10, 20 );
                    this.fireTrailPS.trailVelocity( this.velocity );

                
        }
    // </Constructor>

    // <Tick Update Methods>

        // Method that calls for the updating of the fire trail particle system
        // necessary to make the fire trail behind the rock
        // called in Rocks.updateFireTrail() 
        void updateFireTrail()
        {
            this.fireTrailPS.update();
        }

        // Method that updates the velocity of the rock according to the gravity affecting it
        // called in Rocks.updatePhysics()
        void updateVelocity( Gravity gravity )
        {
            // apply gravity acceleration to the rock's velocity
            this.velocity.add( gravity.getObjectAcceleration( this.absPosition ).mult( DeltaTiming.deltaFactor() ) );
        }

        // Method that updates the position of the rock in accordance with its accumulated velocity
        // called in Rocks.updatePositions()
        void updatePosition()
        {
            PVector deltaVelocity = this.velocity.copy().mult( DeltaTiming.deltaFactor() );

            this.absPosition.add( deltaVelocity );
        }

    // </Tick Update Methods>

    // Render Method
    // called in Rocks.render()
    void render()
    {
        pushMatrix();  
            translate( this.absPosition.x, this.absPosition.y );

            this.fireTrailPS.render();

            image( this.img, 0, 0 );
        popMatrix();
    }

}