// Gamestate Class
// handles all information relevant to a single gamestate
// also handles all gui-components (HUD)


static class Gamestate
{
    // <Class Fields>
        // Sketch
            static PApplet app;

        // HUD Fields
            static PFont hudFont;
            static PFont hudFont24;
            static color hudColor;

            static PImage scoreImg;
            static PVector scorePosition;

            static PImage hyperForceImg;
            static PVector hyperForcePosition;

            static PImage highscoreImg;
            static PVector highscorePosition;

            static PImage creditsImg;
            static PVector creditsPosition;
            
        // Gamestate Fields
            static float score;
            static float highScore;
            static int volcanoCount;
            static float hyperForce;
            static float maxHyperForce;
            static float pollutionLevel;
            final static float pollutionIncrement = 0.01; // per House per Second
            final static float maxPollutionLevel = 100;
            final static float gameOverMargin = 50;

    // </Class Fields>

    // <Initial Constructor>
        Gamestate( PApplet papp )
        {
            app = papp;
        }
    // </Initial Constructor>

    // <New Game Constructor>
        Gamestate()
        {
            volcanoCount = 1;
            score = 0;
            maxHyperForce = 100;
            hyperForce = 10;
            pollutionLevel = 0;
        }
    // </New Game Constructor>

    // <Active Methods>

        // Method used to upgrade the score within the game
        // also increase the count of active volcanoes when benchmarks in score are reached
        // called in City.destroyHouse() and CollisionHandler.updateEarthMeteoriteCollision()
        static void updateScore( float increment )
        {
            score = max(0, score+increment);

            if ( score > 5 )
                volcanoCount = 2;
            if ( score > 15 )
                volcanoCount = 3;
        }

        // Method used to recharge the available hyperForce when it is not used
        // called in MouseController.updateVisualHyperForce()
        static void rechargeHyperForce()
        {
            hyperForce = min( hyperForce+0.25, maxHyperForce );
        }

        // Method used to drain the available hyperForce when it is in use
        // called in MouseController.updateVisualHyperForce()
        static void drainHyperForce()
        {
            hyperForce--;
        }

        // Method used to increase the pollution and check whether or not the game over margin has been reacher
        // called in Earth.updateEmissions()
        static void increasePollution()
        {
            pollutionLevel += pollutionIncrement * DeltaTiming.deltaFactor();

            if ( pollutionLevel >= gameOverMargin )
                gameOver();
        }

        // Method used to update the highscore after a finished game
        // called in main.resetGame()
        static void updateHighscore()
        {
            if ( score > highScore )
            {
                highScore = score;

                PrintWriter output = app.createWriter( "Data/data.hs" );
                output.print( getHighscore() );
                output.flush();
                output.close();
            }
        }

        // Method used to retrieve the current highscore from an external file when starting the program
        // called in main.setup()
        static void readInitialHighscore()
        {
            String file = "data.hs";
            String[] str = app.loadStrings( file );
            highScore = Integer.parseInt( str[0] );
        }

    // </Active Methods>

    // <Get Methods>

        static int getScore()
        {
            return int( score );
        }

        static int getHighscore()
        {
            return int( highScore );
        }

        static float getHyperForce()
        {
            return hyperForce;
        }

        static float getPollutionPercentage()
        {
            return pollutionLevel / maxPollutionLevel;
        }

    // </Get Methods>

    // <HUD Setup Methods>
        static void setHUDFont( String file, color col )
        {
            hudFont = app.createFont( file, 64 );
            hudFont24 = app.createFont( file, 48 );
            hudColor = col;
        }

        static void setScoreHUD( String file, float initX, float initY )
        {
            scoreImg = app.loadImage( file );
            scorePosition = new PVector( initX, initY );
        }

        static void setHyperForceHUD( String file, float initX, float initY )
        {
            hyperForceImg = app.loadImage( file );
            hyperForcePosition = new PVector( initX, initY );
        }

        static void setHighscoreHUD( String file, float initX, float initY )
        {
            highscoreImg = app.loadImage( file );
            highscorePosition = new PVector( initX, initY );
        }

        static void setCreditsHUD( String file, float initX, float initY )
        {
            creditsImg = app.loadImage( file );
            creditsPosition = new PVector( initX, initY );
        }
    // </HUD Setup Methods>

    // <HUD Render Methods>

        static void renderScore()
        {
            app.textAlign( RIGHT, CENTER );
            app.textAscent();
            app.textFont( hudFont );
            app.fill( hudColor );

            app.pushMatrix();
                app.translate( scorePosition.x, scorePosition.y );

                app.image( scoreImg, 0, 0 );

                app.translate( 180, -15 );
                app.text( getScore(), 0, 0 );
            app.popMatrix();
        }

        static void renderHyperForce()
        {
            float percentage = hyperForce/maxHyperForce;
            float w = percentage * (hyperForceImg.width-6);

            float stepSize = 10;
            float stepCount = maxHyperForce / stepSize;
            float stepWidth = hyperForceImg.width / stepCount;

            app.pushMatrix();
                app.translate( hyperForcePosition.x, hyperForcePosition.y );

                app.pushMatrix();
                    app.fill( 100, 0, 0 );
                    app.translate( -187, -37 );
                    app.rect( 0, 0, w, hyperForceImg.height-6 );

                    for ( int i = 0; i < stepCount; i++ )
                    {
                        app.stroke( 0 );
                        app.line( i*stepWidth, 0, i*stepWidth, hyperForceImg.height-6 );
                    }

                app.popMatrix();
                
                app.image( hyperForceImg, 0, 0 );
            app.popMatrix();
        }

        static void renderHighscore()
        {
            app.textAlign( LEFT, CENTER );
            app.textAscent();
            app.textFont( hudFont24 );
            app.fill( hudColor );

            app.pushMatrix();
                app.translate( highscorePosition.x, highscorePosition.y );

                app.image( highscoreImg, 0, 0 );

                app.translate( 85, -7 );
                app.text( getHighscore(), 0, 0 );
            app.popMatrix();
        }

        static void renderCredits()
        {
            app.pushMatrix();
                app.translate( creditsPosition.x, creditsPosition.y );

                app.image( creditsImg, 0, 0 );
            app.popMatrix();
        }
        
    // </HUD Render Methods>
}