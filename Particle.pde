// Particle Class
// visual and physical handler of single particle
// handled by list in Particle System class

class Particle
{
    // <Class Fields>
        PVector relPosition, velocity;
        float lifetime;
        color pixelColour;
    // </Class Fields>

    // <Constructor>
        Particle( color initColour, PVector initPos, PVector initVelocity, float initLifetime )
        {
            this.pixelColour = initColour;
            this.relPosition = initPos.copy();
            this.velocity = initVelocity.copy();
            this.lifetime = initLifetime;
        }
    // </Constructor>

    // <Tick Update Method>

        // Method that updates lifetime and position based on velocity
        // called in ParticleSystem.update()
        void commonUpdate()
        {
            // Increment Lifetime per tick
            this.lifetime += 1 * DeltaTiming.deltaFactor();

            // Update position
            this.relPosition.add( this.velocity.copy().mult( DeltaTiming.deltaFactor() ) );
        }

        void updateMotion( int motionMode )
        {
            switch ( motionMode )
            {
                case PARTICLE_MODE_GRAVITATE:
                    PVector direction = PVector.sub( new PVector(), this.relPosition );
                    this.velocity = direction.normalize().mult( this.velocity.mag() );
                    break;
            }
        }

        // Method that changes the direction of the particles velocity in the opposite direction of the velocity its trailing
        // called in ParticleSystem.update()
        void trailingVelocity( PVector trailingVelocity )
        {
            float directionAngle = trailingVelocity.heading() + PI;
            
            this.velocity = PVector.fromAngle( directionAngle ).mult( this.velocity.mag() );
        }

    // </Tick Update Method>

    // <Get Methods>

        // Method that returns whether or not the particle has reached its finite lifetime
        // called in ParticleSystem.update()
        boolean reachedLifetime( float maxLifetime )
        {
            return this.lifetime >= maxLifetime;
        }

    // </GetMethods>

    // Render Method
    // called in ParticleSystem.render()
    void render()
    {
        float x = this.relPosition.x;
        float y = this.relPosition.y;
        color c = this.pixelColour;

        pushMatrix();
            translate( x, y );
            noStroke();
            fill( c );

            ellipse( 0, 0, 1, 1 );
        popMatrix();
    }
}