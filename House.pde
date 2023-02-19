

class House
{
    // <Class Fields>
        int zone;
        float height;
    // </Class Fields>

    // <Constructor>
        House( int initZone )
        {
            this.zone = initZone;
            this.height = random(5,15);
        }
    // </Constructor>

    // Method used to pass the zone this house was build on back to the city handler
    // called in City.destroyHouse()
    int getZone()
    {
        return this.zone;
    }

    // Method to render the house relative to the earth game object
    // Called in City.render()
    void render( float radius, float rotationSteps )
    {
        noStroke();
        fill( 200, 200, 200 );

        pushMatrix();

            rotate( this.zone * rotationSteps );

            rect( radius, 0, this.height, 3 );

        popMatrix();
    }
}