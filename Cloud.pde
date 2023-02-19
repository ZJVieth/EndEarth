// Cloud Class
// generates patches to form a cloud
// handled by list in Clouds Class


class Cloud
{
    // <Class Fields>
        ArrayList<CloudPatch> patches = new ArrayList<CloudPatch>();
        float lifetime;
        float alpha;

        float rotation;
    // </Class Fields>

    // <Constructor>
        Cloud( float initLifetime, float initRotation, int initSize, float gaussFactorX, float gaussFactorY )
        {
            this.lifetime = initLifetime;
            this.rotation = initRotation;
            this.alpha = 1;

            for ( int i = 0; i < initSize; i++ )
            {
                this.patches.add( new CloudPatch( gaussFactorX, gaussFactorY ) );
            }
        }
    // </Constructor>

    // Method that updates the lifetime and fading of a cloud
    // called in Clouds.updateLifetime()
    void updateFade()
    {
        if ( this.lifetime > 0 )
        {
            this.alpha = min( 255, this.alpha+1 );          // Fade In
            this.lifetime -= DeltaTiming.deltaFactor();     // Count down lifetime
        }
        else
        {
            this.alpha = max( 0, this.alpha-1 );            // Fade Out
        }
    }

    // Method that returns whether or not a cloud has faded and can be deleted
    // callled in Clouds.updateLifetime()
    boolean hasFaded()
    {
        return ( this.lifetime <= 0 && this.alpha <= 0 );
    }

    // Render Method
    // called in Clouds.render()
    void render( float radius )
    {
        noStroke();
        fill ( 255, 255, 255, this.alpha );

        pushMatrix();

            rotate( this.rotation );
            translate( radius+30, 0 );

            for ( CloudPatch cp : this.patches )
            {
                cp.render();
            }

        popMatrix();
    }

}