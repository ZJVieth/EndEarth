// Earth Class
// contains all visual and game mechanics that are relative to the earth 
// handles the Earth game object


class Earth
{
    // <Class Fields>
        // Earth Positioning Fields
            PVector absPosition;
            float rotation, rotationVelocity;
            float radius;
            PVector velocity;

        // Gravity Fields
            Gravity gravity;
            
        // Visual Fields
            PImage img;

        // Volcano Fields
            ArrayList<Volcano> volcanoes = new ArrayList<Volcano>();

        // City Fields
            Cities cities;

        // Cloud Fields
            Clouds clouds;
        
        // Zone Fields
            ArrayList<Zone> zones = new ArrayList<Zone>();
            float zoneRotationSteps;
    
        // Mass Spring Damper Fields
            MSDSystem anchoredSpring;
    
    // </Class Fields>
    
    // <Constructor>
        Earth( float initRadius, float initX, float initY, float initRotVelocity )
        {
            this.radius = initRadius;
            this.absPosition = new PVector( initX, initY );
            this.rotation = 0;
            this.rotationVelocity = initRotVelocity;
            this.velocity = new PVector();
        }
    // </Constructor>

    // <Constructor Sub Methods>
        void setImage( String file )
        {
            this.img = loadImage( file );
        }

        void appendGravity( float initAcceleration, float initInfluenceRange )
        {
            this.gravity = new Gravity( this.absPosition, initInfluenceRange, initAcceleration );
        }

        void createAnchoredSpring( float springConstant, float frictionConstant )
        {
            this.anchoredSpring = new MSDSystem( springConstant, frictionConstant, this.absPosition );
        }

        void createVolcano( String file, float initX, float initY, float initRotation, float initShootVelocityFactor, float initShootVelocityMargin, float delayLimitX, float delayLimitY )
        {
            this.volcanoes.add( new Volcano( file, initX, initY, initRotation, initShootVelocityFactor, initShootVelocityMargin, delayLimitX, delayLimitY ) );
        }

        void initiateClouds( float initSpawnFrequency, float initSpawnFrequencyMargin, int minLifetime, int maxLifetime, int minSize, int maxSize, float initGaussFactorX, float initGaussFactorY )
        {
            this.clouds = new Clouds( initSpawnFrequency, initSpawnFrequencyMargin, minLifetime, maxLifetime, minSize, maxSize, initGaussFactorX, initGaussFactorY );
        }

        void initiateCities( int activeCityCap, float spawnFrequency, float rotationSteps, int cityLimitMin, int cityLimitMax )
        {
            this.zoneRotationSteps = rotationSteps;

            this.zones = initialZoneDetection();

            this.cities = new Cities( activeCityCap, spawnFrequency, cityLimitMin, cityLimitMax );
            this.cities.passSpawnZones( this.zones );
        }

        // Method that detects the start ZONE-value for all zones based on colours in the image and returns them
        // called in this.initiateCities()
        ArrayList<Zone> initialZoneDetection()
        {
            ArrayList<Zone> returnZones = new ArrayList<Zone>();
            
            this.img.loadPixels();

            int errCount = 0; // Used to count incorrectly initialized zones.
            float zoneRotation = 0;
            while ( zoneRotation < 2*PI )   // cycles through all zones based on the rotationSteps
            {
                // Retrieve the zone coordinates within the earth image file
                //      int() for future integer calculations
                //      max() and min() to ensure they lay within boundaries of the image dimensions
                //      trig to calculate x and y on the perimeter of the earth circle
                //      add half image dimensions to get x and y relative to the center of the img instead of top left corner
                int x = int(max( 0, min( this.img.width-1, (this.radius-1) * cos( zoneRotation ) + this.img.width/2 ) ));
                int y = int(max( 0, min( this.img.height-1, (this.radius-1) * sin( zoneRotation ) + this.img.height/2 ) ));

                // Calculate coordinate index within pixel array
                int n = min( this.img.width*this.img.height, y * this.img.width + x );

                // Determine ZONE-value based on pixel colour
                color col = this.img.pixels[n];
                int zoneValue = 0;
                if ( red(col) > 100 ) {
                    zoneValue = ZONE_ICE;
                } else if ( blue(col) > 100 ) {
                    zoneValue = ZONE_SEA;
                } else if ( green(col) > 100 ) {
                    zoneValue = ZONE_LAND;
                } else {
                    errCount++;
                }

                // add zone to the return handler
                returnZones.add( new Zone( zoneValue ) );

                // step to next zone
                zoneRotation += this.zoneRotationSteps;
            }

            // Debug Notification
            if ( errCount > 0 ) 
            {
                println( errCount + " zones have not been initialized correctly." );
            }

            return returnZones;
        }
    // </Constructor Sub Methods>

    // <Tick Update Methods>

        // Earth Rotation Method
        // called in main.draw()
        void updateRotation()
        {
            this.rotation += this.rotationVelocity * DeltaTiming.deltaFactor();
            if ( this.rotation >= 2*PI ) this.rotation = 0;
        }

        // Method that checks for new cities being spawned and adding them to their respective zones
        // called in main.draw()
        void updateCitySpawning()
        {
            // Retrieve newly spawned city, if any
            PVector newCity = this.cities.spawnUpdate();
            
            // If a new city has been spawned, insert it into the zones array
            if ( newCity.mag() > 0 )
            {
                // Retrieve start and end zones of new city
                int cityStart = int(newCity.x);
                int cityEnd = int(newCity.y);
                
                // QUICKFIX to bug where the city spawns outside of the zone array limitations
                if ( cityStart < 0 ) cityStart = 0;
                if ( cityEnd < 0 ) cityEnd = 0;

                // Iterate over all zones that are within new city range and update them 
                for ( int i = cityStart; i < this.zones.size(); i++ )
                {
                    this.zones.get( i ).updateValue( ZONE_CITY );

                    if ( i == cityEnd ) break;
                    if ( i == this.zones.size()-1 ) i = -1; // if the city starts at the end of zones array and ends at the beginning, reset to start when end is reached
                } 

                // Update zones in which cities can spawn with the new city inserted
                this.cities.passSpawnZones( this.zones );
            }
        }

        // Method that updates the spawning of new clouds and the lifetime of existing clouds
        // called in main.draw()
        void updateClouds()
        {
            this.clouds.updateSpawning();
            this.clouds.updateLifetime();
        }

        // Method that passes the volcano shot update class to main
        // called in main.draw()
        void updateVolcanoShooting( Rocks rockHandler )
        {
            for ( Volcano v : this.volcanoes )
                v.updateShooting( rockHandler, this.absPosition, this.rotation );
        }

        // Method used to activate volcanoes if the gamestate allows it
        // called in main.draw()
        void updateVolcanoActivity()
        {
            for ( int i = 0; i < Gamestate.volcanoCount; i++ )
            {
                Volcano v = this.volcanoes.get( i );
                v.activate();
                v.updateActive();
            }
        }

        // Method that causes the earth to accelerate towards the activated hyper force of the mouseController
        // called in main.draw()
        void updateHyperForcePhysics( Gravity hyperForce )
        {
            this.velocity.add(
                hyperForce
                    .getObjectAcceleration( this.absPosition )
                    .mult( DeltaTiming.deltaFactor() )
            );
        }

        // Method that connects the earth to its original position via the anchored spring and causes it to accelerate it towards the center should it be displaced by hyper force
        // called in main.draw()
        void updateSpringPhysics()
        {
            this.velocity.add(
                this.anchoredSpring
                    .getSpringAcceleration( this.absPosition)
                    .mult( DeltaTiming.deltaFactor() )
            );

            this.velocity = this.anchoredSpring.applyFriction( this.velocity );
        }

        // Method that updates the position of the earth according to its velocity
        // called in main.draw()
        void updatePosition()
        {
            this.absPosition.add(
                this.velocity.copy().mult( DeltaTiming.deltaFactor() )
            );
        }

        // Method that updates the Mass-Spring-Damper Physics of all Zones and connects them
        // called in main.draw()
        void updateZonePhysics()
        {
            // iterate over all zones
            for ( int i = 0; i < this.zones.size(); i++ )
            {
                Zone z = this.zones.get( i );
                PVector neighbourForce = new PVector();

                // Retrieve the spring force that the zone's neighbours apply to it
                    int belowIndex = i-1;
                    if ( belowIndex >= 0 )
                    {
                        Zone nz = this.zones.get( belowIndex );
                        PVector force = z.waterSurfaceSystem.getSpringAcceleration( nz.relPosition );
                        neighbourForce.add( force );
                    }

                    int aboveIndex = i+1;
                    if ( aboveIndex != this.zones.size() )
                    {
                        Zone nz = this.zones.get( aboveIndex );
                        PVector force = z.waterSurfaceSystem.getSpringAcceleration( nz.relPosition );
                        neighbourForce.add( force );
                    }

                // Average the force from its neighbours
                    neighbourForce.div( 2 );

                // Apply the Force to the Zone
                    z.updatePhysics( neighbourForce );
            }
        }

        // Method used to increase the pollution level by a certain increment for every house
        // called in main.draw()
        void updateEmissions()
        {
            for ( City c : this.cities.cities )
            {
                for( House h : c.houses )
                {
                    Gamestate.increasePollution();
                }
            }
        }

    // </Tick Update Methods>

    // <Active Methods>

        // Method that handles the effect of rock to zone collisions depending on the zone value
        // called in CollisionHandler.updateZoneRockCollision()
        void rockToZoneImpact( int zoneIndex, PVector impactVelocity, PVector zonePosition )
        {

            Zone z = this.zones.get( zoneIndex );
            switch( z.getValue() )
            {
                case ZONE_SEA:
                    // Apply Force to water surface
                    z.applyForce( impactVelocity.mag() );

                    // Create Water explosion particle effect
                    float waterDirection = impactVelocity.heading() + PI;
                    GlobalParticles.applyParticles( 
                        seaExplosion
                            .copy()
                            .setRelativeSpawnDirection( waterDirection-0.2, waterDirection+0.2 )
                            .linkPosition( zonePosition )
                    );
                    break;

                case ZONE_CITY:
                    cities.destroyHouse( zoneIndex );
                    
                default:
                    // create rock explosion particle effect
                    float direction = impactVelocity.heading() + PI;
                    GlobalParticles.applyParticles( 
                        rockExplosion
                            .copy()
                            .setRelativeSpawnDirection( direction-0.2, direction+0.2 )
                            .linkPosition( zonePosition )
                    );
            }
        }

    // </Active Methods>

    // <Get Methods>
        color getPollutionColour()
        {
            // Calculate alpha/opacity value of pollution overlay based on the current pollution level
            float a = Gamestate.getPollutionPercentage() * 255;
            float r = 255-a;
            float b = 0;
            float g = 255 - a;

            return color( r, g, b, a );
        }

        Gravity gravity()
        {
            return this.gravity;
        }
    //</Get Methods>

    // <Render Methods>
        // Primary Earth rendering method
        // called in main.draw()
        void render()
        {
            noStroke();

            pushMatrix();
                // Move the earth to its absolute position on the screen
                    translate( this.absPosition.x, this.absPosition.y );
                    rotate( this.rotation );

                // Draw components according to their relative positioning

                    for ( Volcano v : this.volcanoes )
                        v.render();

                    image( this.img, 0, 0 );

                    this.renderZones();

                    this.cities.render( this.radius, this.zoneRotationSteps );

                    this.clouds.render( this.radius );

                    this.renderPollution();
                  
            popMatrix();
        }

        // Pollution rendering method
        // called in this.render()
        void renderPollution()
        {
            noStroke();
            color pollutionColour = this.getPollutionColour();
            float r = red( pollutionColour );
            float g = green( pollutionColour );
            float b = blue( pollutionColour );
            float maxAlpha = alpha( pollutionColour );

            // Ensure that pollution area is larger than earth so that all components are affected
            

            for ( int i = 20; i < int(this.radius)+50; i++ )
            {
                float alpha = max( 0, maxAlpha-i );
                float diameter = i*2;

                color discColour = color( r, g, b, alpha );

                fill( discColour );
                ellipse( 0, 0, diameter, diameter );
            }

        }

        // Zone rendering method
        // renders a visual representation of the spawn perimeter zones
        // called in this.render()
        void renderZones()
        {
            noStroke();

            pushMatrix();

                // iterate over all zones
                for ( Zone z : this.zones )
                {
                    z.render( this.radius );

                    // rotate matrix to the next zone
                    rotate( this.zoneRotationSteps );
                }

            popMatrix();
        }

        // Atmosphere Rendering Method
        // renders a blue, semi translucent circle behind the earth
        // called in main.draw()
        void renderAtmosphere()
        {
            noStroke();
            pushMatrix();
                translate( this.absPosition.x, this.absPosition.y );

                for ( int i = 0; i < 20; i++ )
                {
                    float alpha = 100 - (i*4) ;
                    fill ( 0, 0, 50, alpha );
                    ellipse( 0, 0, this.radius*2+i*6, this.radius*2+i*6 );
                }
            popMatrix();
        }

    // </Render Methods>

    // <Earth Reset Method>

        // Method used to reset the cities and volcanoes of the earth game object after the game over screen
        // called in main.resetGame()
        void reset()
        {
            for ( int i = 0; i < this.cities.cities.size(); i++ )
            {
                City c = this.cities.cities.get( i );
                for ( int j = 0; j < c.houses.size(); j++ )
                {
                    House h = c.houses.get( j );
                    c.houses.remove( h );
                }
            }
            for ( int i = this.cities.cities.size()-1; i >= 0; i-- )
            {
                this.cities.cities.remove( i );
            }
            this.zones = this.initialZoneDetection();
            this.cities.passSpawnZones( this.zones );
        
            for ( Volcano v : this.volcanoes )
            {
                v.relPosition.x = v.ogX;
                v.active = false;
            }
        }

    // </Earth Reset Method>

}