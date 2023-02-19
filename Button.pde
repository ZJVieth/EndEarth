// Button Class
// used for play and game over buttons
// handled by both main and ButtonHandler class


class Button
{
    // <Class Fields>
        PImage img, hoverImg;
        PVector absPosition;

        boolean hovered;
    // </Class Fields>

    // <Constructor>
        Button( float initX, float initY, String file, String hoverFile )
        {
            this.img = loadImage( file );
            this.hoverImg = loadImage( hoverFile );
            this.absPosition = new PVector( initX, initY );
        }
    // </Constructor>

    // Method that returns true to mouseReleased events if the button was hovered as the mouse was released
    // called in main.mouseReleased()
    boolean pressed()
    {
        return this.hovered;
    }

    // Render Method
    // called in main.draw()
    void render()
    {
        pushMatrix();
            translate( this.absPosition.x, this.absPosition.y );

            if ( this.hovered )
                image( this.hoverImg, 0, 0 );
            else
                image( this.img, 0, 0 );
        popMatrix();
    }

}