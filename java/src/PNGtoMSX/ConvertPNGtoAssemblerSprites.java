/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package PNGtoMSX;

import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class ConvertPNGtoAssemblerSprites {
    public static void main(String args[]) throws Exception {
//        convert("/Users/santi/Dropbox/Brain/8bit-programming/MSX/3dengine/graphics/python.png", 8, 2);
//        convert("/Users/santi/Dropbox/Brain/8bit-programming/MSX/3dengine/graphics/medusa.png", 4, 4);
//        convert("/Users/santi/Dropbox/Brain/8bit-programming/MSX/3dengine/graphics/keres.png", 4, 4);
        System.out.println("    org #0000");
        System.out.println("title_bg_sprites1:");
        convert(args[0], 0, 4, 3, 8);
        System.out.println("");
        System.out.println("title_bg_sprites2:");
        convert(args[0], 3, 4, 6, 8);
    }
    
    
    public static void convert(String fileName, int c0, int r0, int c1, int r1) throws Exception
    {
        File f = new File(fileName);
        BufferedImage sourceImage = ImageIO.read(f);
        for(int i = r0;i<r1;i++) {
            for(int j = c0;j<c1;j++) {
                int sprite[][] = new int[16][16];
                for(int y = 0;y<16;y++) {
                    for(int x = 0;x<16;x++) {
                        int color = sourceImage.getRGB(x+j*16, y+i*16);
                        int r = (color & 0xff0000)>>16;
                        int g = (color & 0x00ff00)>>8;
                        int b = color & 0x0000ff;
                        if (r!=0 || g!=0 || b!=0) {
                            sprite[x][y] = 1;
                        }
                    }
                }
                System.out.print("  db ");
                for(int k = 0;k<16;k++) {
                    int v = 0;
                    if (sprite[0][k]!=0) v = v|0x80;
                    if (sprite[1][k]!=0) v = v|0x40;
                    if (sprite[2][k]!=0) v = v|0x20;
                    if (sprite[3][k]!=0) v = v|0x10;
                    if (sprite[4][k]!=0) v = v|0x08;
                    if (sprite[5][k]!=0) v = v|0x04;
                    if (sprite[6][k]!=0) v = v|0x02;
                    if (sprite[7][k]!=0) v = v|0x01;
                    
                    String h = toHex8bit(v);
                    if (k!=15) {
                        System.out.print(h+", ");                    
                    } else {
                        System.out.println(h+"");
                    }
                }
                System.out.print("  db ");
                for(int k = 0;k<16;k++) {
                    int v = 0;
                    if (sprite[8][k]!=0) v = v|0x80;
                    if (sprite[9][k]!=0) v = v|0x40;
                    if (sprite[10][k]!=0) v = v|0x20;
                    if (sprite[11][k]!=0) v = v|0x10;
                    if (sprite[12][k]!=0) v = v|0x08;
                    if (sprite[13][k]!=0) v = v|0x04;
                    if (sprite[14][k]!=0) v = v|0x02;
                    if (sprite[15][k]!=0) v = v|0x01;
                    
                    String h = toHex8bit(v);
                    if (k!=15) {
                        System.out.print(h+", ");                    
                    } else {
                        System.out.println(h+"");
                    }
                }                
            }
        }
    }
    
    
    public static String toHex8bit(int value) {
        char table[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
        return "#" + table[value/16] + table[value%16];
    }
    
}
