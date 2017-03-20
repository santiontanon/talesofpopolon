/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package PNGtoMSX;

import java.awt.image.BufferedImage;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class ConvertNonEmptyPatternsToAssembler { 
    
    static int PW = 8;
    static int PH = 8;
    static int MSX1Palette[][] = {{0,0,0},
                                    {0,0,0},
                                    {43,221,81},
                                    {81,255,118},
                                    {81,81,255},
                                    {118,118,255},
                                    {221,81,81},
                                    {81,255,255},
                                    {255,81,81},
                                    {255,118,118},
                                    {255,221,81},
                                    {255,255,118},
                                    {43,187,43},
                                    {221,81,187},
                                    {221,221,221},
                                    {255,255,255}};     
    
    public static void main(String args[]) throws Exception {        
        convert(args[0], "story_image1_name_table", "story_image1_pattern_data", 0, 0, 7, 3, 100, args[2], args[3], "story-image1");
        convert(args[0], "story_image2_name_table", "story_image2_pattern_data", 0, 3, 7, 6, 100, args[2], args[3], "story-image2");
        convert(args[0], "story_image3_name_table", "story_image3_pattern_data", 0, 12, 7, 15, 100, args[2], args[3], "story-image3");
    }
    
    public static void convert(String file, String label1, String label2, int x1, int y1, int x2, int y2, int startPattern, String outputFolder, String includeFolder, String outputFile) throws Exception {
        String inputFile = "/Users/santi/Dropbox/Brain/8bit-programming/MSX/talesofpopolon/graphics/story.png";
        File f = new File(inputFile);
        BufferedImage sourceImage = ImageIO.read(f);
        List<Integer> nameTable = new ArrayList<>();
        List<int []> patternList = new ArrayList<>();
        List<int []> attributeList = new ArrayList<>();
        for(int y = y1;y<y2;y++) {
            for(int x = x1;x<x2;x++) {
                int []pattern = generatePatternBitmap(x,y,sourceImage);
                int []attributes = generatePatternAttributesBitmap(x,y,sourceImage);
                boolean empty = true;
                for(int i = 0;i<pattern.length;i++) {
                    if (pattern[i]!=0 || attributes[i]!=0) empty = false;
                }
                if (!empty) {
                    nameTable.add(startPattern);
                    startPattern++;
                    patternList.add(pattern);
                    attributeList.add(attributes);
                } else {
                    nameTable.add(0);
                }
            }
        }

        FileWriter fw = new FileWriter(outputFolder + "/" + outputFile+".asm"); 
        
        fw.write("  org #0000\n");
        
        for(int []p:patternList) {
            fw.write("  db ");
            boolean first = true;
            for(int v:p) {
                if (!first) {
                    fw.write(",");
                } else {
                    first = false;
                }
                fw.write("" + v);
            }
            fw.write("\n");
        }
        for(int []p:attributeList) {
            fw.write("  db ");
            boolean first = true;
            for(int v:p) {
                if (!first) {
                    fw.write(",");
                } else {
                    first = false;
                }
                fw.write("" + v);
            }
            fw.write("\n");
        }
        fw.close();
                
        System.out.println(label1 + ":");
        System.out.print("    db ");
        for(int i = 0;i<nameTable.size();i++) {
            System.out.print(nameTable.get(i));
            if ((i+1)%(x2-x1)==0) {
                System.out.println("");
                if (i<nameTable.size()-1) System.out.print("    db ");
            } else {
                System.out.print(", ");
            }
        }        
        System.out.println(label2 + ":");
        System.out.println("  incbin \""+includeFolder+"/"+outputFile+".plt\"");
        
    }


    public static void convertBinaryFileToAssembler(String path, int bytesPerLine) throws Exception
    {
        DataInputStream is = new DataInputStream(new FileInputStream(path));
        
        List<Integer> l = new ArrayList<>();
        while(is.available()>0) {
            l.add((is.readByte() & 0xff));
        }
        
        System.out.println("; bytes read " + l.size());
        for(int i = 0;i<l.size();i++) {
            if ((i%bytesPerLine)==0) {
                System.out.print("    db ");
            }
            System.out.print(toHex8bit(l.get(i)));
            if ((i%bytesPerLine)==bytesPerLine-1 || i==l.size()-1) {
                System.out.println("");
            } else {
                System.out.print(", ");
            }
        }
    }
    
    
    public static int[] generatePatternBitmap(int x, int y, BufferedImage image) throws Exception {
        int []pattern = new int[8];
        List<Integer> differentColors = new ArrayList<>();
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image);
            differentColors.clear();
            for(int c:pixels) if (!differentColors.contains(c)) differentColors.add(c);
            Collections.sort(differentColors);
            int bitmap = 0;
            int mask = (int)Math.pow(2, PW-1);
            for(int j = 0;j<PW;j++) {
                if (pixels.get(j).equals(differentColors.get(0))) {
                    // 0
                } else {
                    // 1
                    bitmap+=mask;
                }
                mask/=2;
            }
            pattern[i] = bitmap;
        }
        return pattern;
    }    

    
    public static int[] generatePatternAttributesBitmap(int x, int y, BufferedImage image) throws Exception {
        int []pattern = new int[8];
        List<Integer> differentColors = new ArrayList<>();
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image);
            differentColors.clear();
            for(int c:pixels) if (!differentColors.contains(c)) differentColors.add(c);
            Collections.sort(differentColors);
            if (differentColors.size()==1) differentColors.add(0);
            int bitmap = differentColors.get(0) + 16*differentColors.get(1);
            pattern[i] = bitmap;
        }
        return pattern;
    }    
    
    
    public static String toHex8bit(int value) {
        char table[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
        return "#" + table[value/16] + table[value%16];
    }
    

    public static List<Integer> patternColors(int x, int y, int line, BufferedImage image) throws Exception {
        List<Integer> pixels = new ArrayList<>();
        List<Integer> differentColors = new ArrayList<>();
        for(int j = 0;j<PW;j++) {
            int image_x = x*PW + j;
            int image_y = y*PH + line;
            int color = image.getRGB(image_x, image_y);
            int r = (color & 0xff0000)>>16;
            int g = (color & 0x00ff00)>>8;
            int b = color & 0x0000ff;
            int msxColor = findMSXColor(r, g, b);
            if (msxColor==-1) throw new Exception("Undefined color at " + image_x + ", " + image_y + ": " + r + ", " + g + ", " + b);
            if (!differentColors.contains(msxColor)) differentColors.add(msxColor);
            pixels.add(msxColor);
        }
        if (differentColors.size()>2) throw new Exception("more than 2 colors in line " + x + ", " + y);
        return pixels;        
    }
    
    public static int findMSXColor(int r, int g, int b) {
        for(int i = 0;i<MSX1Palette.length;i++) {
            if (r==MSX1Palette[i][0] &&
                g==MSX1Palette[i][1] &&
                b==MSX1Palette[i][2]) {
                return i;
            }
        }
        return -1;
    }
}
