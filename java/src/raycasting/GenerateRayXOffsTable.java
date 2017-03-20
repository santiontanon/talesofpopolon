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
public class GenerateRayXOffsTable {
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
        System.out.println(";; xoffs/yoffs table");
        System.out.println(";; horizontal resolution (full 360 degrees): " + angleXIncrements);
        System.out.println(";; vertical resolution (45 degrees): " + angleYIncrements);
        System.out.println(";; This table corresponds to xoffs (each row is a different x horizontal angle, for the first " + (angleXIncrements/4) + " angles:");
        System.out.println(";; table size: " + xoffs.length*xoffs[0].length + " bytes");        
        System.out.println("ray_x_offs_table:");
        for(int i = 0;i<angleXIncrements/4;i++) {
            System.out.print("    db ");
            for(int j = 0;j<angleYIncrements;j++) {
                System.out.print(xoffs[i][j] + "");
                if (j<angleYIncrements-1) System.out.print(", ");
                if (j>0 && xoffs[i][j]<xoffs[i][j-1]) System.exit(1);
                if (i>0 && xoffs[i][j]>xoffs[i-1][j]) System.exit(2);
            }
            System.out.println("");
        }
        /*
        System.out.println("ray_y_offs_table:");
        for(int i = 0;i<angleXIncrements/4;i++) {
            System.out.print("    db ");
            for(int j = 0;j<angleYIncrements;j++) {
                System.out.print(yoffs[i][j] + "");
                if (j<angleYIncrements-1) System.out.print(", ");
                if (j>0 && yoffs[i][j]<yoffs[i][j-1]) System.exit(3);
                if (i>0 && yoffs[i][j]<yoffs[i-1][j]) System.exit(4);
            }
            System.out.println("");
        }*/
        System.out.println("");
        System.out.println("    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0");
        System.out.println(";; The \"ray_y_offs_table\" is basically a mirror of the \"ray_x_offs_table\", ");
        System.out.println(";; so, what I do is to subtract the offset from here, rather than add the offset");
        System.out.println("ray_y_offs_table:");

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
