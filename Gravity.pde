// Gravity Class
// provides physics functions for motions towards the earth
// appended to
// -Earth game object (Earth Gravity)
// -MouseController object ( Player Controllable Gravity Field)

// Currently does not feature friction due to the game's style, see Mass-Spring-Damper system for friction mechanics

class Gravity
{

    // <Class Fields>
        float gravityAcceleration;
        float influenceRange;

        boolean factoriseDistance;

        PVector center;
    // </Class Fields>

    // <Constructor>
        Gravity( PVector initCenter, float initInfluenceRange, float initAcceleration )
        {
            this.center = initCenter;
            this.influenceRange = initInfluenceRange;
            this.gravityAcceleration = initAcceleration;
        }
    // </Constructor>

    // Method that enables the factorization of the distance of the affected object to the ceneter of gravity
    // -> 0.0 - 1.0 factor for gravityAcceleration towards the center of gravity
    // used to smoothen the gravity acceleration caused by the player's gravity field
    void enableDistanceFactor()
    {
        this.factoriseDistance = true;
    }

    // Method that returns the acceleration of an object towards a center of gravity
    // used in velocity update methods of objects affected by gravity
    PVector getObjectAcceleration( PVector objectPosition )
    {
        PVector acceleration = new PVector();

        float diff = PVector.dist( this.center, objectPosition );

        float factor = 1;      // default acceleration factor is 1, so that it wont affect earth's gravity acceleration
        if ( factoriseDistance )
        {
            factor = diff / this.influenceRange;            // calculate a factor based on the distance of the object to the player's mosue pointer
        }

        if ( diff <= this.influenceRange )
        {
            // calculate the direction of the acceleration
                PVector direction = objectPosition.copy().sub( this.center ).mult( -1 );
            
            // normalize the direction and scale it up to the acceleration value, then multiply it with the distance factor if applicable
                acceleration = direction.normalize().mult( gravityAcceleration ).mult( factor );
        }

        return acceleration;
    }

}