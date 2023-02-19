// Meteorite Class
// handles behaviour of single meteorite ( non-flocking related )
// handled by list in MeteoriteFlock class

class Meteorite
{
    // <Class Fields>
        PVector absPosition, velocity;
        int imgType;
    // </Class Fields>

    // <Constructor>
        Meteorite( PVector initPosition, PVector initVelocity, int initImgType )
        {
            this.absPosition = initPosition.copy();
            this.velocity = initVelocity.copy();
            this.imgType = initImgType;
        }
    // </Constructor>

    // Method that updates the position of the meteorite with incoming steering force from flocking behaviour
    // called in MeteoriteFlock.updateFlockBehaviour()
    void updatePhysics( PVector steer, float maxVelocity )
    {
        this.velocity.add( steer.mult( DeltaTiming.deltaFactor() ) );
        this.velocity.limit( maxVelocity );

        this.absPosition.add( this.velocity.copy().mult( DeltaTiming.deltaFactor() ) );
    }

    // Method that returns whether or not the meteorite is still within relevant screen distance
    // called in MeteoriteFlock.updateMeteoriteDeletion()
    boolean leftTheScene()
    {
        if ( this.absPosition.x < -100 ||
             this.absPosition.y < -200 ||
             this.absPosition.y > height + 200 )
            return true;
        return false;
    }

    // Method used to cause explosion particles when the meteorite hits the earth
    // called in CollisionHandler.updateMeteoriteEarthCollision()
    void explode()
    {
        GlobalParticles.applyParticles( 
            meteoriteExplosion
                .copy()
                .linkPosition( this.absPosition )
        );
    }

    // Render Method
    // called in MeteoriteFlock.render()
    void render( ArrayList<PImage> img )
    {
        stroke( 150, 120, 50 );
        fill( 170, 150, 60 );
        pushMatrix();
            translate( this.absPosition.x, this.absPosition.y );

            image( img.get( imgType ), 0, 0 );
        popMatrix();
    }

}