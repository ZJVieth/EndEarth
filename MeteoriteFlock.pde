// Meteorite Flock Class
// handles all meteorites of one flock
// handled by Meteorites Class


class MeteoriteFlock
{
    // <Class Fields>
        ArrayList<Meteorite> meteoriteList = new ArrayList<Meteorite>();

        float maxVelocity;
    // </Class Fields>

    // <Constructor>
        MeteoriteFlock( int imgCount, PVector initCenter, int initSize, float spawnRadiusFactor, float baseVelocity, float velocityMargin, float directionMargin )
        {
            float flockDirectionAngle = random( 3*PI/4, 5*PI/4 );

            for ( int i = 0; i < initSize; i++ )
            {
                int imgType = int( random( 0, imgCount ) );

                float spawnX = initCenter.x + random( -initSize*spawnRadiusFactor, initSize*spawnRadiusFactor );
                float spawnY = initCenter.y + random( -initSize*spawnRadiusFactor/3, initSize*spawnRadiusFactor/3 );
                PVector spawnPosition = new PVector( spawnX, spawnY );

                float directionAngle = flockDirectionAngle + random( -directionMargin, directionMargin );
                float velocityFactor = baseVelocity + random( -velocityMargin, velocityMargin );

                PVector velocity = PVector.fromAngle( directionAngle ).mult( velocityFactor );

                meteoriteList.add( new Meteorite( spawnPosition, velocity, imgType ) );
            }
        }
    // </Constructor>

    // <Meteorite Deletion Methods>

        // Method that deletes meteorites that have left the screen
        // called in Meteorites.updateObjectDeletion()
        void updateMeteoriteDeletion()
        {
            for ( int i = 0; i < this.meteoriteList.size(); i++ )
            {
                Meteorite m = this.meteoriteList.get( i );
                if ( m.leftTheScene() ) this.meteoriteList.remove( m );
            }
        }

        // Method that returns if all meteorites of this flock have been deleted
        // called in Meteorites.updateObjectDeletion()
        boolean isEmpty()
        {
            return this.meteoriteList.size() <= 0;
        }

    // </Meteorite Deletion Methods>

    // Method that calculates the steering force based on flocking behaviour and applies it to the meteorite
    // called in Meteorites.updateFlockBehaviour()
        // Abbreviated Parameters:
        // sw: separationWeighting
        // aw: alignmentWeighting
        // cw: cohesionWeighting
        // sd: separationDistance
        // nd: neighbourDistance
    void updateFlockBehaviour( float sw, float aw, float cw, float sd, float nd, float maxVelocity, float maxForce )
    {
        for ( Meteorite m : this.meteoriteList )
        {
            PVector steer = new PVector();

            for ( Meteorite n : this.meteoriteList )
            {
                if ( m != n )
                {
                    float d = PVector.dist( m.absPosition, n.absPosition );
                    steer.add( this.separation( d, m, n, sd, maxVelocity, maxForce ).mult( sw ) );   // apply principle of separation and factor it with its weighting
                    steer.add( this.alignment( d, m, n, nd, maxVelocity, maxForce ).mult( aw ) );    // apply principle of alignment and factor it with its weighting
                    steer.add( this.cohesion( d, m, n, nd, maxVelocity, maxForce ).mult( cw ) );     // apply principle of cohesion and factor it with its weighting
                }
            }

            // Get the average steering force ( steer.z represents the count of steering forces )
                if ( steer.z > 0 ) steer.div( steer.z );
                steer.z = 0;    // remove counter so that it won't steering force magnitude

            // Apply steering force
            m.updatePhysics( steer, maxVelocity );
        }
    }

    // <Flocking Principle Methods>
        // All called in this.updateFlockBehaviour

        // Principle of Separation
        // causes the meteorites to push each other away when they come to close
        PVector separation( float distance, Meteorite mActive, Meteorite mPassive, float sd, float maxVelocity, float maxForce )
        {
            PVector steer = new PVector();

            // If the two meteorites are too close to each other
            if ( distance < sd )
            {
                PVector diff = PVector.sub( mActive.absPosition, mPassive.absPosition );    // Create a Vector that points in the opposite direction
                diff.normalize();               // set magnitude to one
                diff.div( distance );           // factor the magnitude by the distance
                steer.add( diff );              

                steer = this.limitSteering( steer, mActive, maxVelocity, maxForce );

                steer.add( new PVector( 0, 0, 1 ) );    // Increment steering counter
            }

            return steer;
        }

        // Principle of Alignment
        // causes the meteorites to adapt to each other's direction of motion
        PVector alignment( float distance, Meteorite mActive, Meteorite mPassive, float nd, float maxVelocity, float maxForce )
        {
            PVector steer = new PVector();

            // If the two meteorites are considered neighbours
            if ( distance < nd )
            {
                // steer in the direction the other is heading
                steer.add( mPassive.velocity );

                steer = this.limitSteering( steer, mActive, maxVelocity, maxForce );

                steer.add( new PVector( 0, 0, 1 ) );    // Increment steering counter
            }

            return steer;
        }

        // Principle of Cohesion
        // causes the meteorites to move towards its neighbor meteorites
        PVector cohesion( float distance, Meteorite mActive, Meteorite mPassive, float nd, float maxVelocity, float maxForce )
        {
            PVector steer = new PVector();
            
            // if the two meteorites are considered neighbours
            if ( distance < nd )
            {  
                // steer towards the other
                steer = PVector.sub( mPassive.absPosition, mActive.absPosition );

                steer = this.limitSteering( steer, mActive, maxVelocity, maxForce );

                steer.add( new PVector( 0, 0, 1 ) );    // Increment steering counter
            }

            return steer;
        }

        // Method that limits the steering force to a preset maxForce
        // called in the three principle methods
        PVector limitSteering( PVector steer, Meteorite m, float maxVelocity, float maxForce )
        {
            if ( steer.mag() > 0 )
            {
                steer.normalize();
                steer.mult( maxVelocity );
                steer.sub( m.velocity );
                steer.limit( maxForce );
            }
            return steer;
        }

    // </Flocking Principle Methods>

    // Render Method
    // called in Meteorites.render()
    void render( ArrayList<PImage> img )
    {
        for ( Meteorite m : meteoriteList )
        {
            m.render( img );
        }
    }

}