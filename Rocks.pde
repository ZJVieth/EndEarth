// Class Rocks
// handles rocks that are shot from the volcano.
// appended to main


class Rocks
{

    // <Class Fields>
        ArrayList<Rock> rockList = new ArrayList<Rock>();

        PImage img;
    // </Class Fields>

    // <Constructor>
        Rocks( String file )
        {
            this.img = loadImage( file );
        }
    // </Constructor>

    // <RockList Handling>

        // Method used to spawn new rocks when the volcano shoots
        // called in volcano.shoot()
        void addRock( PVector position, PVector velocity )
        {
            this.rockList.add( new Rock( position, velocity, this.img ) );
        }

        // Method used to remove rock objects after they have collided with another object
        // called in CollisionHandler.updateZoneRockCollision()
        void deleteRock( Rock r )
        {
            this.rockList.remove( r );
        }

    // </RockList Handling>

    // <Tick Update Methods>

        // Method used to update the velocity of all rocks according to the gravity impacting them
        // called in main.draw()
        void updatePhysics( Gravity gravity )
        {
            for ( Rock r : rockList )
            {
                r.updateVelocity( gravity );
            }
        }

        // Method used to update the position of all rocks according to their velocity after all accelerations have been added
        // called in main.draw()
        void updatePositions()
        {
            for ( Rock r : rockList )
            {
                r.updatePosition();
            }
        }

        // Method used to update the fire trail particle systems of all rocks
        // called in main.draw()
        void updateFireTrail()
        {
            for ( Rock r : this.rockList )
            {
                r.updateFireTrail();
            }
        }

    // </Tick Update Methods>

    // Render Method
    // called in main.render()
    void render()
    {
        for ( Rock r : rockList )
        {
            r.render();
        }
    }

}