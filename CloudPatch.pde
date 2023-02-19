// CloudPatch Class
// single dot as part of a cloud
// handled by list in Cloud class

class CloudPatch
{
    PVector relPosition;

    // <Constructor>
        CloudPatch( float gaussFactorX, float gaussFactorY )
        {
            float x = randomGaussian()* gaussFactorY;       // X is Y, the hight of a cloud lies on the x axis of the not rotated earth
            float y = randomGaussian()* gaussFactorX;       // Y is X, see above
            this.relPosition = new PVector( x, y );
        }
    // </Constructor>

    // Render Method
    // called in Cloud.render()
    void render()
    {
        pushMatrix();
            translate( this.relPosition.x, this.relPosition.y );

            ellipse( 0, 0, 5, 5 );
        popMatrix();
    }

}