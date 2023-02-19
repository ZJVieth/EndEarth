// MouseController Class
// responsible for the player's controllable gravity field
// handled directly in main

class MouseController
{

    // <Class Fields>
        // Visual Force 
            ArrayList<VisualForce> visualForce = new ArrayList<VisualForce>();
            float vfSpeed;
            float vfSpawnFrequency;
            int vfSpawnTimer;
            float radius;
            float ogRadius;
            float maxHyperRadius;
            int vfRed;

        // Position and Game Mechanics
            PVector absPosition;

        // Gravity
            Gravity gravity;

        // Hyper Force Fields
            Gravity hyperForce;
            Gravity passHyperForce;
            boolean hyperForceActive;

        // Particles
            ParticleSystem gravityParticles;
            ParticleSystem hyperForceParticles;

    // </Class Fields>

    // <Constructor>
        MouseController( float initGravityAcceleration, float initRadius, float initVFSpeed, float initVFSpawnFrequency )
        {
            this.absPosition = new PVector();
            this.radius = initRadius;
            this.ogRadius = this.radius;
            this.gravity = new Gravity( this.absPosition, this.radius, initGravityAcceleration );
            this.gravity.enableDistanceFactor();
            this.vfSpeed = initVFSpeed;
            this.vfSpawnFrequency = initVFSpawnFrequency;
            this.passHyperForce = new Gravity( this.absPosition, 0, 0 );
            this.vfRed = 100;

            this.gravityParticles =
                new ParticleSystem( 15, 1, this.radius/2 )
                    .setRelativeSpawnDirection( 0, 2*PI )
                    .setParticleVelocity( 40, 50 )
                    .setColourBase( 100, 100, 100, 10 )
                    .setMotionMode( PARTICLE_MODE_GRAVITATE );
        }
    // </Constructor>

    // <Sub Constructor Methods>
        void setHyperForce( float acceleration, float influenceRange, float initMaxHyperRadius )
        {
            this.hyperForce = new Gravity( this.absPosition, influenceRange, acceleration );
            this.maxHyperRadius = initMaxHyperRadius;

            this.hyperForceParticles =
                new ParticleSystem( 30, 1, this.maxHyperRadius )
                    .setRelativeSpawnDirection( 0, 2*PI )
                    .setParticleVelocity( 80, 100 )
                    .setColourBase( 200, 50, 50, 20 )
                    .setMotionMode( PARTICLE_MODE_GRAVITATE );

            this.hyperForceParticles.deactivate();
        }
    // </Sub Constructor Methods>

    // <Get Methods>

        // Method used to pass the player's gravity field to affected objects
        // called in main.draw()
        Gravity gravity()
        {
            return this.gravity;
        }

        // Method used to pass the play's hyper force gravity field to affected objects
        // called in main.draw()
        Gravity hyperForce()
        {
            return passHyperForce;
        }

    // </Get Methods>

    // <Active Methods>

        // Method used to activate the hyper force gravity
        // called in main.mousePressed()
        void activateHyperForce()
        {
            this.passHyperForce = this.hyperForce;
            this.hyperForceActive = true;
            this.hyperForceParticles.activate();
            this.gravityParticles.deactivate();
        }

        // Method used to deactivate the hyper force gravity
        // called in main.mouseReleased()
        void deactivateHyperForce()
        {
            this.passHyperForce = new Gravity( this.absPosition, 0, 0 );
            this.hyperForceActive = false;
            this.hyperForceParticles.deactivate();
            this.gravityParticles.activate();
        }

    // </Active Methods>

    // <Tick Update Methods>

        // Method used to update gravity field position according to the mouse
        // called in main.mouseMoved()
        void updatePosition( float initX, float initY )
        {
            this.absPosition.x = initX;
            this.absPosition.y = initY;
        }

        // Method used to update visual effects of the players gravity field
        // called in main.draw()
        void updateVisualForce()
        {
            // Updating current visual force instances
            for ( int i = 0; i < this.visualForce.size(); i++ )
            {
                VisualForce vf = this.visualForce.get(i);
                vf.update( this.vfSpeed );                                          // Increase Value -> reduce radius, increase alpha
                if ( vf.getValue() > vf.maxValue() ) this.visualForce.remove( vf ); // remove instance when it reaches the center
            }

            // Spawn new vf instances based on set frequency
            float spawnDelay = 1000/vfSpawnFrequency;
            if ( DeltaTiming.millis() - this.vfSpawnTimer >= spawnDelay )
            {
                this.visualForce.add( new VisualForce( 0 ) );
                this.vfSpawnTimer = DeltaTiming.millis();
            }

            // Update Gravity Particles
            this.gravityParticles.update();
            this.hyperForceParticles.update();
        }

        // Method used to update the visual effects of the player gravity field when hyper force is activated
        // called in main.draw()
        void updateVisualHyperForce()
        {
            if ( this.hyperForceActive )
            {
                this.radius = min( this.maxHyperRadius, this.radius+1 );    // Increase radius of VF
                this.vfRed = min( 255, this.vfRed+1 );                      // Slowly turn VF red 

                Gamestate.drainHyperForce();
                if ( Gamestate.getHyperForce() <= 0 ) this.deactivateHyperForce();
            }
            else 
            {
                this.radius = max( this.ogRadius, this.radius-1 );          // Decrease radius of VF
                this.vfRed = max( 100, this.vfRed-1 );                      // Turn VF back to grey

                Gamestate.rechargeHyperForce();
            }
        }

    // </Tick Update Methods>

    // <Render Methods>
        
        // Main render method of player's gravity fields
        // called in main.draw()
        void render()
        {
            noStroke();
            pushMatrix();
                translate( this.absPosition.x, this.absPosition.y );

                for ( VisualForce vf : visualForce )
                {
                    vf.render( this.radius, this.vfRed );
                }

                this.gravityParticles.render();
                this.hyperForceParticles.render();

            popMatrix();
        }

    // </Render Methods>
}