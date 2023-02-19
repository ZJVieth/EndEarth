// Clouds Handler Class
// handles all Cloud Objects
// appended to Earth Game Object


class Clouds
{
    // <Class Fields>
        ArrayList<Cloud> cloudList = new ArrayList<Cloud>();

        float spawnFrequency;
        float spawnFrequencyMargin;
        int spawnTimer;

        PVector sizeLimits;
        PVector lifetimeLimits;

        float gaussFactorX, gaussFactorY;
    // </Class Fields>

    // <Constructor>
        Clouds( float initSpawnFrequency, float initSpawnFrequencyMargin, int minLifetime, int maxLifetime, int minSize, int maxSize, float initGaussFactorX, float initGaussFactorY )
        {
            this.spawnFrequency = initSpawnFrequency;
            this.spawnFrequencyMargin = initSpawnFrequencyMargin;
            this.lifetimeLimits = new PVector( minLifetime, maxLifetime );
            this.sizeLimits = new PVector( minSize, maxSize );
            this.gaussFactorX = initGaussFactorX;
            this.gaussFactorY = initGaussFactorY;
            this.spawnTimer = DeltaTiming.millis();
        }
    // </Constructor>

    // Method to spawn new clouds based on randomized delay
    // called in Earth.updateClouds()
    void updateSpawning()
    {
        float spawnDelay = 1000 / ( this.spawnFrequency + random( this.spawnFrequencyMargin, this.spawnFrequencyMargin ) );        
        
        if ( DeltaTiming.millis() - this.spawnTimer > spawnDelay )
        {
            this.spawnCloud();

            this.spawnTimer = DeltaTiming.millis();
        }
    }

    // Method to update the lifetime and fading of all clouds
    // called in Earth.updateClouds()
    void updateLifetime()
    {
        for ( int i = 0; i < this.cloudList.size(); i++ )
        {
            Cloud c = this.cloudList.get( i );
            c.updateFade();
            if ( c.hasFaded() ) this.cloudList.remove( c );
        }
    }

    // Method to spawn and create a new cloud object
    // called in this.updateSpawning()
    void spawnCloud()
    {
        int lifetime = int( random( this.lifetimeLimits.x, this.lifetimeLimits.y ) );

        int size = int( random( this.sizeLimits.x, this.sizeLimits.y ) );

        float rotation = random( 0, 2*PI );

        this.cloudList.add(
            new Cloud(
                lifetime, 
                rotation,
                size,
                this.gaussFactorX,
                this.gaussFactorY
            )
        );
    }

    // Render Method
    // called in Earth.render()
    void render( float radius )
    {
        for ( Cloud c : cloudList )
        {
            c.render( radius );
        }
    }

}