// Collision Hander static class
// handles collisions between different objects that are not relative to each other
// initiated in main.setup()


static class CollisionHandler
{

    // <Setup>
        static PApplet app;
        CollisionHandler( PApplet papp )
        {
            app = papp;
        }
    // </Setup>

    // <Rock to Zone Collision>

        // "marginZoneRock": Value that determines the min distance the rock and zone have to be to each other to collide
        // directly influences rock to earth collision proximity
        // scales up slightly for rock to zone collision for larger impact area
        // initiated in main.setup()
        static float marginZoneRock = 0; 
        static void setZoneRockMargin( float initMargin )
        {
            marginZoneRock = initMargin;
        }

        // Method that handles collisions between rocks and the earth perimeter -> zone impact
        // called in main.draw()
        static void updateZoneRockCollision( Earth earth, Rocks rockHandler )
        {
            // Iterate over all rocks
            for ( int j = 0; j < rockHandler.rockList.size(); j++ )
            {
                Rock r = rockHandler.rockList.get( j );
                
                // Check if the rock is moving towards the earth
                PVector pr1 = r.absPosition.copy().sub( earth.absPosition );    // get current position normalized around null vector
                PVector pr2 = pr1.copy().add( r.velocity.copy().normalize() );  // get next tick position normalized around null vector

                if ( pr2.mag() < pr1.mag() )    // if the distance to 0 of the next tick position is smaller than the current position, the rock is moving towards earth
                {

                    // Get Rock to Earth proximity for collision distance
                    float diffEarthRock = PVector.dist( earth.absPosition, r.absPosition );
                    
                    if ( diffEarthRock <= earth.radius + marginZoneRock  )
                    {
                        // if the rock is hitting the earth perimeter, check which zones it will impact
                        // so iterate over all zones
                        for ( int i = 0; i < earth.zones.size(); i++ )
                        {
                            // get the absolute position of the zone
                                float zoneRotation = earth.rotation - ( 2*PI - i*earth.zoneRotationSteps );

                                float x = earth.radius * cos( zoneRotation ) + earth.absPosition.x;
                                float y = earth.radius * sin( zoneRotation ) + earth.absPosition.y;

                                PVector absZonePosition = new PVector( x, y );

                            // compare it with the absolute position of the rock to check for the collision    
                                float diffRockZone = PVector.dist( absZonePosition, r.absPosition );

                                if ( diffRockZone <= marginZoneRock*1.5 )
                                {
                                    // pass impact notification to earth object with information about impacted zones
                                    earth.rockToZoneImpact( i, r.velocity, absZonePosition );
                                }
                        }

                        // delete rock object after impact
                        rockHandler.deleteRock( r );
                    }
                }
                
            }
        }

    // </Rock to Zone Collision>

    // <Meteorite to Earth Collision>

        // Method that handles collisions between Meteorites and the earth surface
        // called in main.draw()
        static void updateEarthMeteoriteCollision( Earth earth, Meteorites meteoriteHandler )
        {
            // Iterate over all Meteorite Flocks
            for ( MeteoriteFlock mf : meteoriteHandler.meteoriteFlocks )
            {
                // Iterate over all Meteorites
                for ( int i = 0; i < mf.meteoriteList.size() ; i++ )
                {
                    Meteorite m = mf.meteoriteList.get( i );

                    // Get Rock to Earth proximity for collision distance
                    float diff = PVector.dist( earth.absPosition, m.absPosition );

                    float collisionDistance = earth.radius + 20 - m.imgType;

                    if ( diff <= collisionDistance )
                    {
                        // Create Particle Explosion
                        m.explode();

                        Gamestate.updateScore( -0.5 );

                        // Remove Meteorite on Collision
                        mf.meteoriteList.remove( m );
                    }
                }
            }
        }

    // </Meteorite to Earth Collision>

}