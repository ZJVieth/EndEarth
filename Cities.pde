// Cities Class
// appended to Earth Object
// handles city spawning and rendering

class Cities
{
    // <Class Fields>

        ArrayList<PVector> spawnZones = new ArrayList<PVector>(); // vector x: startZone, y: endZone
        ArrayList<Zone> zones; // to be passed from earth class
        ArrayList<City> cities = new ArrayList<City>();

        // Fields to limit the spawning of new cities
        int activeCities;
        int activeCityCap;

        // Fields to limit the spawning of new houses
        float spawnFrequency;
        int spawnTimer;

        PVector cityLimits; // sets the city size limitations/number of zones per city, x: min, y: max
    // </Class Fields>
    
    // <Constructor>
        Cities( int initActiveCityCap, float initSpawnFrequency, int cityLimitMin, int cityLimitMax )
        {
            this.activeCityCap = initActiveCityCap;
            this.spawnFrequency = initSpawnFrequency;
            this.cityLimits = new PVector( cityLimitMin, cityLimitMax ); 
        }
    // </Constructor>

    // Method that retrieves zones from the Earth Class and breaks them into spawnable chunks
    // called in Earth.initialZoneDetection() and Earth.updateCitySpawning()
    void passSpawnZones( ArrayList<Zone> initZones )
    {
        // Empty the spawn zone array
        for ( int i = this.spawnZones.size()-1; i >= 0; i-- )
        {
            this.spawnZones.remove( i );
        }

        this.zones = initZones; // save passed zones for use in city spawning conditions

        int loopCount = 0;

        int initI = 0;      // remembers start point of zone detection
        int startI = 0;     // remembers start point of currently detected zone
        int lastZ = initZones.get(0).getValue(); // preset comparer to avoid error on first iteration
        int i = 0;
        // iterate over all zones
        // only start detecting and passing zones once the first change in zone has been detected in order to connect "zone 0" to its full size
        // due to overlapping of the zone between the start and end of zone array
        while ( true )
        {
            int currZ = initZones.get(i).getValue();

            // if zone has changed between iterations
            if ( currZ != lastZ && startI != 0) // add the detected zone after zone detection has started
            {
                int endI = i-1;
                this.spawnZones.add( new PVector( startI, endI ) );
                startI = i;
            }
            else if ( currZ != lastZ ) // start zone detection
            {
                startI = i;
                initI = startI;
            }

            lastZ = currZ;

            // Iteration handling
            i++;
            if ( i >= initZones.size() ) i = 0;     // reset to beginning after reaching end for the first time
            if ( i == initI )                       // add last zone and exit loop after reaching start point of zone detection
            {
                int endI = i-1;
                this.spawnZones.add( new PVector( startI, endI ) );
                break;
            }

            loopCount++;
            if ( loopCount > initZones.size()*2 ) break;
        }
    }

    // <City Spawning Methods>

        // Tick update Method that handles the spawning of cities
        // called in Earth.updateCitySpawning()
        PVector spawnUpdate()
        {
            // Check which cities can currently be built in
            this.activeCities = this.countActiveCities();

            // Building Spawning
                int spawnDelay = int(1000/spawnFrequency); // calculate the spawn delay in ms based on variable frequency

                if ( DeltaTiming.millis() - this.spawnTimer > spawnDelay )
                {
                    City c = this.getRandomActiveCity(); // select a random active city to build the new house in
                    if ( c != null ) c.buildHouse();

                    spawnTimer = DeltaTiming.millis();  // reset the spawn timer
                }

            // City Spawning
                // if the city construction cap is not reached
                // spawn a new city
                if ( this.activeCities < this.activeCityCap ) 
                {
                    int citySize = int( random( cityLimits.x, cityLimits.y ) );
                    PVector cityVector = this.getSpawnVector( citySize );           // get a random spawn zone within a spawnable area

                    // as long as the new city has a valid size
                    if ( cityVector.mag() > 0 )
                    {
                        activeCities++;
                        cities.add( new City( cityVector ) );
                        return cityVector; // return a city to the earth city spawning update method, so that it can be added to the zones array
                    }
                }

            return new PVector();
        }

        // Method that calculates the spawn zone of a new city
        // called in this.spawnUpdate()
        PVector getSpawnVector( int citySize )
        {
            int loopCount = 0; // used to cap while(true) loops to remove the risk of infinity loops

            // As long as a spawn zone should be available, try to grab a random spawn zone
            while ( this.spawnAreaAvailable( citySize ) )
            {
                // get a random area
                int areaIndex = int( random( 0, this.spawnZones.size() ) );

                // retrieve limits of the area
                int zoneStart = int(this.spawnZones.get(areaIndex).x);
                int zoneEnd = int(this.spawnZones.get(areaIndex).y);

                if ( zoneEnd - zoneStart >= citySize &&          // if the zone is a not an end-to-start zone
                    this.zones.get( zoneStart ).getValue() != ZONE_CITY &&
                    this.zones.get( zoneStart ).getValue() != ZONE_SEA )  // check if a city can be spawned in that area
                {
                    // set random start and end point
                    int start = int( random( zoneStart, zoneEnd-citySize ) );

                    return new PVector( start, start+citySize ); // return vector for the new city !!OUTCOME!!
                }
                // if the zone is an end-to-start zone
                else if ( zoneStart > zoneEnd &&
                        this.zones.get( zoneStart ).getValue() != ZONE_CITY )    // check if the zone is not already a city
                {
                    int zoneLength = (this.zones.size()-1) - zoneStart + zoneEnd;
                    if ( zoneLength >= citySize )                       // check if the zone is large enough to spawn the new city
                    {
                        // set a relative start point for the new city zone within the area
                        int relStart = int( random( 0, zoneLength-citySize ) );

                        // if the new city zone would start in the beginning of the zones array
                        if ( zoneStart + relStart >= this.zones.size()-1 )
                        {
                            int start = zoneStart + relStart - this.zones.size()-1;     // calculate the start point of the city
                            return new PVector( start, start+citySize );                // return vector for the new city !!OUTCOME!!
                        }
                        // if the new city zone would start at the end of the zones array
                        else
                        {
                            int start = zoneStart + relStart;
                            int end = 0;
                            
                            // if the new city zone would end at the beginning of the zones array
                            if ( zoneStart + relStart + citySize > this.zones.size()-1 )
                            {
                                end = zoneStart + relStart + citySize - this.zones.size()-1;
                            }
                            // if the new city zone would end at the end of the zones array
                            else 
                            {
                                end = zoneStart + relStart + citySize;
                            }
                            return new PVector( start, end );   // return vector for the new city !!OUTCOME!!
                        }
                    }
                }

                // Exit loop prematurely if loop takes too longs
                loopCount++;
                if ( loopCount > 100 ) break;
            }
            return new PVector();
        }

        // Method that checks whether or not a larger enough area is available for cities to spawn on
        // called in this.getSpawnVector()
        boolean spawnAreaAvailable( int citySize )
        {
            // iterate over all spawn zones
            for ( PVector spawnZone : this.spawnZones )
            {
                if ( spawnZone.y - spawnZone.x >= citySize &&                       // if the zone is large enough
                    this.zones.get( int(spawnZone.x) ).getValue() != ZONE_CITY &&   // and is neither a city
                    this.zones.get( int(spawnZone.x) ).getValue() != ZONE_SEA )     // nor a sea
                    return true;                                                    // then there is a spawnable area available
            }
            return false;
        }

        // Method to update the class field this.activeCities
        // called in this.spawnUpdate()
        int countActiveCities()
        {
            int count = 0;
            for ( City c : this.cities )
            {
                if ( c.isActive() ) count++;
            }
            return count;
        }

        // Method to retrieve a random city to be build in
        // called in this.spawnUpdate()
        City getRandomActiveCity()
        {
            int loopCount = 0;

            // as long as there are active cities
            while( activeCities > 0 )
            {
                int cityIndex = int( random( 0, this.cities.size() ) ); // get a random city
                City c = this.cities.get( cityIndex );                  // and check if its active
                if ( c.isActive() ) return c;                           // and return it if so

                loopCount++;
                if ( loopCount > 100 ) break;
            }
            return null;
        }
        
    // </City Spawning Methods>

    // Method that passes the command to destroy houses to the individual cities
    // called in Earth.rockToZoneImpact()
    void destroyHouse( int zone )
    {
        for ( City c : this.cities )
        {
            c.destroyHouse( zone );
        }
    }

    // Method to render all cities relative to the earth object
    // called in Earth.render()
    void render( float radius, float rotationSteps )
    {
        for ( City c : cities )
        {
            c.render( radius, rotationSteps );
        }
    }

}