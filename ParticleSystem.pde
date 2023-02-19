// Particle System Class
// handler for collection of particles that behave in a similar way
// to be appended to game object


class ParticleSystem
{

    // <Class Fields>
        ArrayList<Particle> particles = new ArrayList<Particle>();
        
        int particleCap;
        float maxLifetime; // in seconds

        float spawnMargin;
        boolean singleSpawn;
        boolean spawning;

        PVector absPosition;
        PVector velocityLimits; // in px/s
        PVector spawnAngleLimits;

        int[] baseColour;
        int colourMargin;

        int motionMode;
        PVector trailingVelocity;
    // </Class Fields>

    // <Constructors>
        ParticleSystem( int initParticleCap, float initMaxLifetime, float initSpawnMargin )
        {
            this.particleCap = initParticleCap;
            this.maxLifetime = initMaxLifetime;
            this.spawnMargin = initSpawnMargin;

            this.baseColour = new int[3];

            this.velocityLimits = new PVector();
            this.spawnAngleLimits = new PVector();
            this.trailingVelocity = new PVector();

            this.spawning = true;

            this.absPosition = new PVector();
        }
    // </Constructor>

    // <Sub Constructor Methods>
        ParticleSystem linkPosition( PVector initPosition )
        {
            this.absPosition = initPosition;

            return this;
        }

        ParticleSystem fixPosition()
        {
            this.absPosition = this.absPosition.copy();

            return this;
        }

        ParticleSystem setRelativeSpawnDirection( float minAngle, float maxAngle )
        {
            this.spawnAngleLimits = new PVector( minAngle, maxAngle );
            return this;
        }

        ParticleSystem setParticleVelocity( float initMin, float initMax )
        {
            this.velocityLimits = new PVector( initMin, initMax );
            return this;
        }

        ParticleSystem setColourBase( int initR, int initG, int initB, int initMargin )
        {
            this.baseColour[0] = initR;
            this.baseColour[1] = initG;
            this.baseColour[2] = initB;
            this.colourMargin = initMargin;

            return this;
        }
        
        ParticleSystem setToSingleSpawn()
        {
            this.singleSpawn = true;
            return this;
        }

        ParticleSystem setMotionMode( int initMotionMode )
        {
            this.motionMode = initMotionMode;

            return this;
        }

        ParticleSystem trailVelocity( PVector initVelocity )
        {
            this.trailingVelocity = initVelocity;
            return this;
        }

    // </Sub Constructor Methods>

    ParticleSystem copy()
    {
        ParticleSystem returnPS = new ParticleSystem( this.particleCap, this.maxLifetime, this.spawnMargin );
            returnPS.setRelativeSpawnDirection( this.spawnAngleLimits.x, this.spawnAngleLimits.y );
            returnPS.setParticleVelocity( this.velocityLimits.x, this.velocityLimits.y );
            returnPS.setColourBase( this.baseColour[0], this.baseColour[1], this.baseColour[2], this.colourMargin );
            returnPS.singleSpawn = this.singleSpawn;
            returnPS.setMotionMode( this.motionMode );
            returnPS.trailVelocity( this.trailingVelocity );
            returnPS.linkPosition( this.absPosition );

        return returnPS;
    }

    // <Tick Update Methods>

        // Main Particle System Update Method
        // to be called in rel object update method
        void update()
        {
            for ( int i = 0; i < particles.size(); i++ )
            {
                Particle p = this.particles.get( i );
                p.updateMotion( this.motionMode );
                p.commonUpdate();   // Position and Lifetime updates
                if ( this.trailingVelocity.mag() != 0 ) p.trailingVelocity( this.trailingVelocity );    // if it has a velocity to trail, update trailing direction
                if ( p.reachedLifetime( this.maxLifetime ) ) this.particles.remove( p );
            }

            this.updateParticleSpawn();
        }

        // Method that Spawns new particles when necessary
        // called in this.update()
        void updateParticleSpawn()
        {
            if ( this.spawning )
            {
                for ( int i = 0; i < this.particleCap - this.particles.size(); i++ )
                {
                    // Generate Colour
                        int[] col = new int[3];
                        for ( int j = 0; j < 3; j++ ) {
                            col[j] = min( 255, int( random( this.baseColour[j] - this.colourMargin, this.baseColour[j] + this.colourMargin ) ) ); 
                        }
                        color colour = color( col[0], col[1], col[2] );

                    // Generate Position and Velocity
                        float spawnAngle = random( this.spawnAngleLimits.x, this.spawnAngleLimits.y );
                        float spawnDistance = random( 0, this.spawnMargin );
                        float velocityFactor = random( this.velocityLimits.x, this.velocityLimits.y );

                        PVector relPosition = PVector.fromAngle( spawnAngle ).mult( spawnDistance );
                        PVector velocity = PVector.fromAngle( spawnAngle ).mult( velocityFactor );

                    // Generate Initial Lifetime
                        float lifetime = random( 0, this.maxLifetime/2 );

                    // Spawn Particle
                        this.particles.add( new Particle( colour, relPosition, velocity, lifetime ) );

                    if ( this.singleSpawn && this.particles.size() >= this.particleCap ) this.spawning = false;
                }
            }
        }

    // </Tick Update Methods>

    // <Active Methods>

        void activate()
        {
            this.spawning = true;
        }

        void deactivate()
        {
            this.spawning = false;
        }

    // </Active Methods>

    // <Render Method>
        void render()
        {
            pushMatrix();
                translate( this.absPosition.x, this.absPosition.y );
                for ( Particle p : this.particles )
                {
                    p.render();
                }
            popMatrix();
        }
    // </Render Method>

}