// Visual Force Class
// used to visualize the players gravity fields
// handled by array in MouseController class


class VisualForce
{

    // Class Fields
        int value, maxValue;

    // <Constructor>
        VisualForce( int initValue )
        {
            this.value = initValue;
            this.maxValue = 100;
        }
    // </Constructor>

    // <Get Methods>
        // both called in MouseController.updateVisualForce()
        int getValue()
        {
            return this.value;
        }

        int maxValue()
        {
            return this.maxValue;
        }
    // </Get Methods>

    // Tick Update Method
        // called in MouseController.updateVisualForce()
        void update( float speed )
        {
            this.value += int( max( 1, speed * DeltaTiming.deltaFactor() ) );
        }

    // Render Method
        // called in MouseController.render()
        void render( float radius, int red )
        {
            float alpha = min( 255, float(this.value) / 100 * 255 );        // Calculate increasing alpha value based on increasing vf value
            float vfRadius = radius - ( float(this.value) / 100 * radius);  // calculate decreasing radius based on increasing vf value
                    
            fill( red, 100, 100, alpha );

            ellipse( 0, 0, vfRadius, vfRadius );
        }

}