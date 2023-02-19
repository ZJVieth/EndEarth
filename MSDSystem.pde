// Mass Spring Damper System Class
// used to model physical spring systems:
// - Earth Anchor Spring
// - Water Surface Modelling in Earth Zones


class MSDSystem
{

    PVector ogPosition;         // spring anchor point
    float springConstant;
    float frictionConstant;

    MSDSystem( float initSpringConstant, float initFrictionConstant, PVector initPosition )
    {
        this.springConstant = initSpringConstant;
        this.frictionConstant = initFrictionConstant;
        this.ogPosition = initPosition.copy();
    }

    // Method that returns the spring force that applies to an object connected to the spring
    PVector getSpringAcceleration( PVector objPosition )
    {
        // Calculate the distance of the connected object to the anchor point
        PVector direction =  PVector.sub( objPosition, this.ogPosition ).mult( -1 );
        float length = direction.mag();

        // Calculate force based on that distance
        PVector force = direction
                            .normalize()
                            .mult( this.springConstant * length );

        return force;
    }

    // Method that returns the velocity of an object after friction has been applied
    PVector applyFriction( PVector velocity )
    {
        return velocity.copy().mult( 1 - (frictionConstant * DeltaTiming.deltaFactor()) );
    }

}