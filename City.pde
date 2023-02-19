// City Class
// Objects are handled in an arrayList in the Cities class which is appended to the earth game object
// handles city activity state, houses, and rendering

class City
{
    // <Class Fields>
        PVector cityVector;
        int size;
        boolean active; // if a city is active, new houses can spawn in it, the house limit is equal to its size
        ArrayList<House> houses = new ArrayList<House>();
    // </Class Fields>

    // <Constructor>
        City( PVector initCityVector )
        {
            this.active = true;
            this.cityVector = initCityVector;
            this.size = int(this.cityVector.y - this.cityVector.x);
        }
    // </Constructor>

    // Method that adds a house to this city when called
    // called by Cities.spawnUpdate()
    // !? maybe update so that each zone of a city can only have one house spawning on it ?!
    void buildHouse()
    {
        int houseZone = int( random( this.cityVector.x, this.cityVector.y ) ); // get a random zone within the city

        this.houses.add( new House( houseZone ) );  // add a house at that zone

        if ( houses.size()-1 == this.size ) this.active = false; // check if city has reached its capacity and update activity state accordingly
    }

    // Methods that destroys houses in the city after object to zone collision
    // called in Cities.destroyHouse()
    void destroyHouse( int zone )
    {
        for ( int i = 0; i < this.houses.size(); i++ )
        {
            House h = this.houses.get( i );
            if ( h.getZone() == zone ) {
                this.houses.remove( h );
                Gamestate.updateScore( 1 );
            }
        }
        if ( this.houses.size() < this.size ) this.active = true;   // reactive the city if it is lacking houses after the destruction
    }

    // Method to get whether or not a city is active
    // called in Cities.getRandomActiveCities() and Cities.countActiveCities()
    boolean isActive()
    {
        return active;
    }

    // Method to render all the houses relative to the earth object
    // called in Cities.render()
    void render( float radius, float rotationSteps )
    {
        for ( House h : houses )
        {
            h.render( radius, rotationSteps );
        }
    }

    
}