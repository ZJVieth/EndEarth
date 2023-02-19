// ButtonHandler Class
// handles hover updates for appended buttons


static class ButtonHandler
{

    // <Static Initialization>
        static PApplet app;

        ButtonHandler( PApplet papp )
        {
            app = papp;
        }
    // </Static Initialization>

    // Button Array
    static ArrayList<Button> buttons = new ArrayList<Button>();

    // Method to create and append buttons to the ButtonHandler
    // called in main.setup()
    static Button addButton( Button button )
    {
        buttons.add( button );
        return button;
    }

    // Method that updates the hovered value of individual buttons so that they can detect press events
    // called in main.mouseMoved()
    static void checkHover( PVector mouse )
    {
        for ( Button b : buttons )
        {
            float x = b.absPosition.x;
            float y = b.absPosition.y;
            float w = b.img.width;
            float h = b.img.height;

            if ( mouse.x > x-w/2 &&
                 mouse.x < x+w/2 &&
                 mouse.y > y-h/2 &&
                 mouse.y < y+h/2 )
            {
                b.hovered = true;
            }
            else {
            {
                b.hovered = false;   
            }
            }
        }
    }

}