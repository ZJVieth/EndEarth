// Meteorites Class
// handels all MeteoriteFlocks
// directly handled by main


class Meteorites
{
    // <Class Fields>
        // Image Array
            ArrayList<PImage> img = new ArrayList<PImage>();

        // Meteorite Behaviour Fields ( Speed and Flocking )
            float maxForce;
            PVector velocityLimits;
            float velocityMargin;
            float directionMargin;

            float separationWeight, alignmentWeight, cohesionWeight;
            float separationDistance, neighborDistance;

        // Spawn Mechanism
            float spawnFrequency, spawnFrequencyMargin;
            int spawnTimer;
            PVector flockSizeLimits;
            PVector minSpawnArea, maxSpawnArea;
            float spawnRadiusFactor;

        // Flock Handling
            ArrayList<MeteoriteFlock> meteoriteFlocks = new ArrayList<MeteoriteFlock>();

    // </Class Fields>

    // <Constructor>
        Meteorites( int minFlockSize, int maxFlockSize, float initSpawnFrequency, float initSpawnFrequencyMargin )
        {
            this.flockSizeLimits = new PVector( minFlockSize, maxFlockSize );
            this.spawnFrequency = initSpawnFrequency;
            this.spawnFrequencyMargin = initSpawnFrequencyMargin;

            this.minSpawnArea = new PVector();
            this.maxSpawnArea = new PVector();
            this.velocityLimits = new PVector();
        }
    // </Constructor>

    // <Sub Constructor Methods>

        void setSpawnArea( float minX, float minY, float maxX, float maxY, float initSpawnRadiusFactor )
        {
            this.minSpawnArea = new PVector( minX, minY );
            this.maxSpawnArea = new PVector( maxX, maxY );
            this.spawnRadiusFactor = initSpawnRadiusFactor;
        }

        void setVelocity( float minVelocity, float maxVelocity, float initVelocityMargin, float initDirectionMargin )
        {
            this.velocityLimits = new PVector( minVelocity, maxVelocity );
            this.velocityMargin = initVelocityMargin;
            this.directionMargin = initDirectionMargin;
        }

        void setFlockingBehaviour( float initSW, float initALW, float initCW, float initSD, float initND, float initMaxForce )
        {
            this.separationWeight = initSW;
            this.alignmentWeight = initALW;
            this.cohesionWeight = initCW;
            this.separationDistance = initSD;
            this.neighborDistance = initND;
            this.maxForce = initMaxForce;
        }

        void addImage( String file )
        {
            this.img.add( loadImage( file ) );
        }

    // </Sub Constructor Methods>

    // Method that spawns new Meteorite Flocks according to a slightly randomized timer
    // called in main.draw()
    void updateSpawning()
    {
        float spawnDelay = 1000/spawnFrequency + random( 0, 1000/this.spawnFrequencyMargin );
        if ( DeltaTiming.millis() - this.spawnTimer >= spawnDelay )
        {
            this.spawnMeteoriteFlock();

            this.spawnTimer = DeltaTiming.millis();
        }
    }

    // Method handles the actual spawn process of new flocks
    // called in this.updateSpawning()
    void spawnMeteoriteFlock()
    {
        int flockSize = int( random( this.flockSizeLimits.x, this.flockSizeLimits.y ) );

        float x = random( this.minSpawnArea.x, this.maxSpawnArea.x );
        float y = random( this.minSpawnArea.y, this.maxSpawnArea.y );
        PVector spawnCenter = new PVector( x, y );

        float baseVelocity = random( this.velocityLimits.x, this.velocityLimits.y );

        this.meteoriteFlocks.add( 
            new MeteoriteFlock(
                this.img.size(),
                spawnCenter,
                flockSize,
                this.spawnRadiusFactor,
                baseVelocity,
                this.velocityMargin,
                this.directionMargin
            )
        );
    }

    // Method that causes the meteorites of a flock to behave as one, according to flocking paramters
    // called in main.draw()
    void updateFlockBehaviour()
    {
        for ( MeteoriteFlock mf : meteoriteFlocks )
        {
            mf.updateFlockBehaviour( 
                this.separationWeight,
                this.alignmentWeight,
                this.cohesionWeight,
                this.separationDistance,
                this.neighborDistance,
                this.velocityLimits.y,
                this.maxForce
            );
        }
    }

    // Method that deletes Meteorites and Flocks once they contain no more meteorites ( when they are far enough off screen )
    // called in main.draw()
    void updateObjectDeletion()
    {
        for ( int i = 0; i < this.meteoriteFlocks.size(); i++ )
        {
            MeteoriteFlock mf = this.meteoriteFlocks.get( i );
            mf.updateMeteoriteDeletion();
            if ( mf.isEmpty() ) this.meteoriteFlocks.remove( mf );
        }
    }

    // Render Method
    // called in main.draw()
    void render()
    {
        for ( MeteoriteFlock mf : meteoriteFlocks )
        {
            mf.render( this.img );
        }
    }


}