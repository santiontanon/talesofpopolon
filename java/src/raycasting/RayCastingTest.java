/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package raycasting;

import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;
import javax.swing.JFrame;
import utils.KeyboardBuffer;
import utils.Pair;

/**
 *
 * @author santi
 * 
 */
public class RayCastingTest {
    static final int NORTH = 0;
    static final int EAST = 2;
    static final int SOUTH = 1;
    static final int WEST = 3;
        
    static final int HORIZONTAL_RESOLUTION = 128;
    static final int VERTICAL_RESOLUTION = 64;

    static final int RENDER_HORIZONTAL_RESOLUTION = 512;
    static final int RENDER_VERTICAL_RESOLUTION = 256;
    
    static final int moveresolution = 16;
    static final int playerAngleResolution = 128;
    static final int angleXIncrements = HORIZONTAL_RESOLUTION*4;   // screen width*4 for a 90 degree FOV
    static final int angleYIncrements = VERTICAL_RESOLUTION/2;
    static int xoffs[] = new int[(angleXIncrements/4)*angleYIncrements];
    static int yoffs[] = new int[(angleXIncrements/4)*angleYIncrements];   

    public static void main(String args[]) throws Exception {
//        BufferedImage img = new BufferedImage(256,192,BufferedImage.TYPE_INT_ARGB);
        BufferedImage img = new BufferedImage(HORIZONTAL_RESOLUTION,VERTICAL_RESOLUTION,BufferedImage.TYPE_INT_ARGB);
        KeyboardBuffer keyboardBuffer = new KeyboardBuffer();
        
        // walls are made out of 2 blocks, one per bit in the numbers here
        int map[] = new int[] {
            1,1,1,1,1,1,1,1,
            1,0,0,0,0,0,0,1,
            1,0,1,0,0,0,0,1,
            1,0,1,0,0,0,0,1,
            1,0,1,0,0,0,0,1,
            1,0,1,1,0,1,0,1,
            1,0,0,0,0,0,0,1,
            1,1,1,1,1,1,1,1,
        };
        int walltypes[] = new int[] {
            5,5,5,5,4,4,4,5,
            5,0,0,0,0,0,0,4,
            5,0,0,0,0,0,0,4,
            5,0,0,0,0,0,0,4,
            5,0,0,0,0,0,0,5,
            5,0,0,0,0,0,0,5,
            5,0,0,0,0,0,0,5,
            5,5,5,5,5,5,5,5,
            };
        int floortypes[] = new int[] {
            6,6,6,6,6,6,6,6,
            6,6,6,6,6,6,6,6,
            6,6,2,2,2,2,6,6,
            6,6,2,2,2,2,6,6,
            6,6,2,2,2,2,6,6,
            6,6,2,2,2,2,6,6,
            6,6,6,6,6,6,6,6,
            6,6,6,6,6,6,6,6,
            };
        int ceilingtypes[] = new int[] {
            7,7,7,7,7,7,7,7,
            7,7,7,7,7,7,7,7,
            7,7,3,3,3,3,3,3,
            7,7,3,3,3,3,3,3,
            7,7,3,3,3,3,3,3,
            7,7,3,3,3,3,3,3,
            7,7,3,3,3,3,3,3,
            7,7,3,3,3,3,3,3,
            };
        
        BufferedImage textures[] = {ImageIO.read(new File("graphics/java/wall1.png")),
                                    ImageIO.read(new File("graphics/java/wall2.png")),
                                    ImageIO.read(new File("graphics/java/floor1.png")),
                                    ImageIO.read(new File("graphics/java/floor2.png")),
                                    ImageIO.read(new File("graphics/java/door1.png")),
                                    ImageIO.read(new File("graphics/java/rockwall1.png")),
                                    ImageIO.read(new File("graphics/java/rockfloor1.png")),
                                    ImageIO.read(new File("graphics/java/rockceiling1.png")),
        };
        
        int xposition = (1*moveresolution+moveresolution/2)*moveresolution;
        int yposition = (1*moveresolution+moveresolution/2)*moveresolution;
        int angle = 0;
                
        JFrame w = new JFrame() {
            @Override
            public void paint(Graphics g) {
                ((Graphics2D)g).setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
                g.drawImage(img, 20, 30, RENDER_HORIZONTAL_RESOLUTION, RENDER_VERTICAL_RESOLUTION, null);
            }
    
        };
        w.addKeyListener(keyboardBuffer);
        w.setSize(new Dimension(512+40,384+40+20));
        w.setVisible(true);
        w.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        setuprayCaster();
        
        while(true) 
        {
            Thread.sleep(100);
            if (keyboardBuffer.keyboardbuffer[KeyEvent.VK_LEFT]) angle-=6;
            if (keyboardBuffer.keyboardbuffer[KeyEvent.VK_RIGHT]) angle+=6;
            if (angle<0) angle+=playerAngleResolution;
            if (angle>=playerAngleResolution) angle-=playerAngleResolution;
            int old_x = xposition;
            int old_y = yposition;
            if (keyboardBuffer.keyboardbuffer[KeyEvent.VK_UP]) {
                double radians = (angle/(double)playerAngleResolution)*Math.PI*2;
                xposition += (moveresolution*Math.cos(radians))*moveresolution/8;
                yposition += (moveresolution*Math.sin(radians))*moveresolution/8;
            }
            if (keyboardBuffer.keyboardbuffer[KeyEvent.VK_DOWN]) {
                double radians = (angle/(double)playerAngleResolution)*Math.PI*2;
                xposition -= (moveresolution*Math.cos(radians))*moveresolution/8;
                yposition -= (moveresolution*Math.sin(radians))*moveresolution/8;
            }
            if (map[xposition/(moveresolution*moveresolution) + 
                    (yposition/(moveresolution*moveresolution))*8]!=0) {
                xposition = old_x;
                yposition = old_y;
            }
            rayCastRender(map, walltypes, floortypes, ceilingtypes, 8, 8, xposition/moveresolution, yposition/moveresolution, angle, textures, img);
            w.repaint();
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
                
                xoffs[j*angleYIncrements + i] = (int)(vx_x*distance);
                yoffs[j*angleYIncrements + i] = (int)(vx_z*distance);
            }
        }        
    }
    

    public static void rayCastRender(int []map, 
                                     int []walltypes, int []floortypes, int []ceilingtypes,
                                     int mapwidth, int mapheight, 
                                     int xposition, int yposition, int angle, 
                                     BufferedImage textures[],
                                     BufferedImage img)
    {        
        int xangle = (angle%256)*4 - 64;
                
        // render:
        for(int x = 0;x<HORIZONTAL_RESOLUTION;x++, xangle++) {

            if (xangle<0) xangle+=angleXIncrements;
            if (xangle>=angleXIncrements) xangle-=angleXIncrements;

            int previousTargetx = xposition;
            int previousTargety = yposition;
            
            for(int ytmp = 0;ytmp<64;) {
                int y = ytmp<32 ? ytmp : 63 - ytmp;
                int offs;
                int targetx;
                int targety;
                if (xangle<angleXIncrements/4) {
                    offs = xangle*32+y;
                    targetx = xposition + xoffs[offs];
                    targety = yposition + yoffs[offs];
                } else if (xangle<angleXIncrements/2) {
                    offs = (angleXIncrements/2-1-xangle)*32+y;
                    targetx = xposition - xoffs[offs];
                    targety = yposition + yoffs[offs];
                } else if (xangle<angleXIncrements*0.75) {
                    offs = (xangle-angleXIncrements/2)*32+y;
                    targetx = xposition - xoffs[offs];
                    targety = yposition - yoffs[offs];
                } else {
                    offs = (angleXIncrements-1-xangle)*32+y;
                    targetx = xposition + xoffs[offs];
                    targety = yposition - yoffs[offs];
                }
                
                if (targetx<0) targetx = 0;
                if (targetx>=mapwidth*moveresolution) targetx = mapwidth*moveresolution-1;
                if (targety<0) targety = 0;
                if (targety>=mapheight*moveresolution) targety = mapheight*moveresolution-1;
                
                int w = map[(targetx/moveresolution)+(targety/moveresolution)*mapwidth];
                if (w!=0 && ytmp<32) {
                    if (ytmp>0) {
    //                    Pair<Integer,Integer> tmp = textureAndColumn(targetx, targety, previousTargetx, previousTargety, mapwidth, map, walltypes);
                        Pair<Integer,Integer> tmp = textureAndColumnApprox(targetx, targety, previousTargetx, previousTargety, mapwidth, map, walltypes);
                        int tex_x = tmp.m_b;
                        BufferedImage texture = textures[tmp.m_a];

                        // wall:
                        for(int i = 0;i<(32-y)*2;i++, ytmp++) {
                            int tex_y = (int)(moveresolution*(((float)i)/((32-y)*2)));
                            if (tex_y<0) tex_y = 0;
                            if (tex_y>=moveresolution) tex_y = moveresolution-1;
                            int c = texture.getRGB(tex_x, tex_y);
                            img.setRGB(x,ytmp,c);
                        }
                    } else {
                        for(int i = 0;i<(32-y)*2;i++, ytmp++) {
                            img.setRGB(x,ytmp,0xff000000);
                        }
                    }
                } else {
                    BufferedImage texture = null;
                    if (ytmp<32) {
                        texture = textures[ceilingtypes[(targetx/moveresolution)+(targety/moveresolution)*mapwidth]];
                    } else {
                        texture = textures[floortypes[(targetx/moveresolution)+(targety/moveresolution)*mapwidth]];
                    }
                    int c = texture.getRGB(targetx%moveresolution, targety%moveresolution);
                    img.setRGB(x,ytmp,c);
                    ytmp++;
                }
                
                previousTargetx = targetx;
                previousTargety = targety;
            }            
        }        
    } 
    

    public static Pair<Integer,Integer> textureAndColumn(int targetx, int targety, 
                                                         int previousTargetx, int previousTargety,
                                                         int mapwidth,
                                                         int []map, 
                                                         int []walltypes)
    {
        int DeltaX = Math.abs(targetx - previousTargetx);
        int DeltaY = Math.abs(targety - previousTargety);
        int incx = (targetx>previousTargetx ? 1:-1);
        int incy = (targety>previousTargety ? 1:-1);

        if (DeltaX>DeltaY) {
            int D = 2*DeltaY - DeltaX;
            while(true) {
                int side = -1;
                previousTargetx+=incx;
                if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) side = EAST;
                if (D>0) {
                    previousTargety +=incy;
                    if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) {
                        if (side==-1) side = NORTH;
                    }
                    D-= 2*DeltaX;                    
                }
                D += 2*DeltaY;
                if (side==EAST) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargety%moveresolution);
                } else if (side==NORTH) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargetx%moveresolution);
                }
            }
        } else {
            int D = 2*DeltaX - DeltaY;
            while(true) {
                int side = -1;
                previousTargety+=incy;
                if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) {
                    side = NORTH;
                }
                if (D>0) {
                    previousTargetx +=incx;
                    if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) {
                        if (side==-1) side = EAST;
                    }
                    D-= 2*DeltaY;                    
                }
                D += 2*DeltaX;
                if (side==EAST) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargety%moveresolution);
                } else if (side==NORTH) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargetx%moveresolution);
                }
            }
        }
    }


    public static Pair<Integer,Integer> textureAndColumnApprox(int targetx, int targety, 
                                                         int previousTargetx, int previousTargety,
                                                         int mapwidth,
                                                         int []map, 
                                                         int []walltypes)
    {
        int incx = (targetx>previousTargetx ? 1:-1);
        int incy = (targety>previousTargety ? 1:-1);

        while(true) {
            if (previousTargetx!=targetx) {
                previousTargetx+=incx;
                if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargety%moveresolution);
                }
            }
            if (previousTargety!=targety) {
                previousTargety+=incy;
                if (map[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth]!=0) {
                    return new Pair<>(walltypes[(previousTargetx/moveresolution)+(previousTargety/moveresolution)*mapwidth],
                                      previousTargetx%moveresolution);
                }
            }
        }
    }
    
}
