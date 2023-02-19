// GlobalParticles class
// handles all particle systems that are not appended to an object, like after the destruction of an object
// get directly called to render in main.draw() with an absolute position

// ! currently missing a mechanism to delete particle systems that are done, in order to optimize performance !

// <Preset ParticleSystems>

    // called in Earth.rockToZoneImpact()
    final ParticleSystem seaExplosion = 
                            new ParticleSystem( 10, 0.2, 2 )
                                .setParticleVelocity( 30, 50 )
                                .setColourBase( 50, 50, 200, 30 )
                                .setToSingleSpawn();

    // called in Earth.rockToZoneImpact()
    final ParticleSystem rockExplosion = 
                            new ParticleSystem( 10, 0.2, 2 )
                                .setParticleVelocity( 30, 50 )
                                .setColourBase( 200, 50, 50, 30 )
                                .setToSingleSpawn();

    // called in Meteorite.explode()
    final ParticleSystem meteoriteExplosion = 
                            new ParticleSystem( 75, 0.5, 2 )
                                .setParticleVelocity( 50, 70 )
                                .setColourBase( 115, 30, 0, 20 )
                                .setRelativeSpawnDirection( 0, 2*PI )
                                .setToSingleSpawn();

// </Preset ParticleSystems>


static class GlobalParticles
{

    // Particle System Array
    static ArrayList<ParticleSystem> systems = new ArrayList<ParticleSystem>();

    // Method used to paste a preset particle system (mostly copies) into the GlobalParticles handler
    // called in Earth.rockToZoneImpact() and Meteorite.explode()
    static void applyParticles( ParticleSystem ps )
    {
        systems.add( ps );
    }

    // Method that updates the particles of all particle systems
    // called in main.draw()
    static void update()
    {
        for ( ParticleSystem ps : systems )
        {
            ps.update();
        }
    }

    // Method used to render the particles of all global particle systems
    // called in main.draw()
    static void render()
    {
        for ( ParticleSystem ps : systems )
        {
            ps.render();
        }
    }

}