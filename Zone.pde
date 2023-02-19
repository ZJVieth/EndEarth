// Zone Class
// Zones represent the active surface area of the Earth with which outside objects can interact
// list handled by Earth class


class Zone
{

    // <Class Fields>
        int value;  // Determine what kind of zone it is, land/sea/city/ice
        
        PVector relPosition;
        PVector velocity;
        PVector force;

        MSDSystem waterSurfaceSystem;
    // </Class Fields>

    // <Constructor>
        Zone( int initValue )
        {
            this.value = initValue;
            this.relPosition = new PVector();
            this.velocity = new PVector();
            this.force = new PVector();

            float springConstant = 0;                           // Only make the surface react to impact
            if ( this.value == ZONE_SEA ) springConstant = 0.5; // if it's water

            this.waterSurfaceSystem = new MSDSystem( springConstant, 0.1, this.relPosition );
        }
    // </Constructor>

    // Method that changes the Zone Value
    // called in Earth.updateCitySpawning()
    void updateValue( int initValue )
    {
        this.value = initValue;
    }

    // Method that retrieves the Zone Value
    // i.e called in Cities.passSpawnZones(), Earth.rockToZoneImpact()
    int getValue()
    {
        return this.value;
    }

    // Method that applies an outside force to the Zone
    // called in Earth.rockToZoneImpact()
    void applyForce( float forceFactor )
    {
        PVector force = new PVector( 1, 0 )
            .normalize()
            .mult( -forceFactor );

        this.velocity.add( 
            force.mult( DeltaTiming.deltaFactor() )
        );
    }

    // Method applies the forces and velocities applied to the zone to its position
    // called in Earth.updateZonePhysics()
    void updatePhysics( PVector neighbourForce )
    {
        // Add force applied from the zone's neighbours
            this.force.add( 
                neighbourForce.mult( this.waterSurfaceSystem.springConstant )
            );

        // Add force applied from it's own dislocation
            this.force.add(
                this.waterSurfaceSystem.getSpringAcceleration( this.relPosition )
            );

        // Apply Forces and Friction to Velocity
            this.velocity.add(
                force.mult( DeltaTiming.deltaFactor() ) 
            );

            this.velocity = 
                this.waterSurfaceSystem.applyFriction( this.velocity );

        // Apply Velocity to Position
            this.relPosition.add( 
                this.velocity.copy().mult( DeltaTiming.deltaFactor() ) 
            );
    }

    // Method that renders the zone on the perimeter of the Earth
    // called in Earth.renderZones()
    void render( float earthRadius )
    {
        fill( ZONE_COLOR[ this.value ] );

        pushMatrix();
            translate( this.relPosition.x + earthRadius, 0 );

            ellipse( 0, 0, 3, 3 );
        popMatrix();
    }

}