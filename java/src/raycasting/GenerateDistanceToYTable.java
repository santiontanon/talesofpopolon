/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package raycasting;

/**
 *
 * @author santi
 */
public class GenerateDistanceToYTable {
    static final int moveresolution = 16;
    static final int playerAngleResolution = 256;
    
    static final int HORIZONTAL_RESOLUTION = 128;
    static final int VERTICAL_RESOLUTION = 64;
    static final int angleXIncrements = HORIZONTAL_RESOLUTION*4;   // screen width*4 for a 90 degree FOV
    static final int angleYIncrements = VERTICAL_RESOLUTION/2;
    static int xoffs[][] = new int[angleXIncrements/4][angleYIncrements];
    static int yoffs[][] = new int[angleXIncrements/4][angleYIncrements];   

    public static void main(String args[]) throws Exception {
        setuprayCaster();

        // distance to y coordinate table:
        /*
        int min_distance = 0;
        int max_distance = 64*64;
        double threed_y = 64*16;
        // d = 0        -> y = 128
        // d = 16       -> y =  96
        // d = infinity -> y =  64
        System.out.print("sq_distance_to_y_table:");
        int i = 0;
        for(int sqd = min_distance;sqd<max_distance;sqd++) {
            double d = Math.sqrt(sqd);
            int y = (int)(64 + (threed_y / (16 + d)));
            if ((i%16)==0) {
                System.out.print("\n    db " + y);
            } else {
                System.out.print(", " + y);
            }
//            System.out.println("d: " + d + " -> " + y);
            i++;
        }
        System.out.println("");
        */        
        // d = 12       -> y = 128
        // d = 28       -> y =  96
        // d = infinity -> y =  64        
        System.out.println(";-----------------------------------------------");
        System.out.println("; 64x64 byte table (rows are \"y\" and columns are \"x\"), containing: the screen y position where an object");
        System.out.println("; at distance x and y from the camera should be rendered;");

        System.out.println("distance_to_y_table:");
        for(int yd = 0;yd<64;yd++) {
            System.out.print("    db ");
            for(int xd = 0;xd<64;xd++) {
                double d = Math.sqrt(xd*xd+yd*yd);
                int y = (int)(64 + (64*16 / (16 + (d-12))));
                if ((y%2)!=0) y--;  // since we have a resolution of 2x2 pixels
                if (y>=128) {
                    y = 255;
                } else {
                    y-=27;
                }
                if (xd==0) {
                    System.out.print("" + y);
                } else {
                    System.out.print(", " + y);
                }
            }
            System.out.println("");
        }
    }
    
    
    public static void setuprayCaster()
    {
        // precalculate distance tables:
        double eye_height = 5;
        for(int j = 0;j<angleXIncrements/4;j++) {
            double Xradians = (j/(double)angleXIncrements)*(Math.PI*2);
            double vx_x = Math.cos(Xradians);
            double vx_z = Math.sin(Xradians);
            for(int i = 0;i<angleYIncrements;i++) {
                double Yradians = ((i-angleYIncrements)/(double)angleXIncrements)*(Math.PI*2);
                
                double alpha = Math.PI/2 + Yradians;
                double f = eye_height/Math.cos(alpha);
                double distance = Math.sin(alpha)*f;
                
                xoffs[j][i] = (int)(vx_x*distance);
                yoffs[j][i] = (int)(vx_z*distance);
            }
        }        
    }
}
