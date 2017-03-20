/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package raycasting;

import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class GenerateTextureVerticalRateTableTable {
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
        
        System.out.println("texture_vertical_rate_table:");
        System.out.print("    dw ");
        for(int i = 32;i>1;i--) {
            if (i==32) {
                System.out.print("" + (256*256/(i*2)));
            } else {
                if (i%8==0) {
                    System.out.print("\n    dw " + (256*256/(i*2)));
                } else {
                    System.out.print(", " + (256*256/(i*2)));
                }
            }
                
        }
        System.out.println("");
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
