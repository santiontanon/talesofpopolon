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
public class GenerateSinCosTables {
    
    public static void main(String args[]) throws Exception {
        double walk_speed = 12;
        
        System.out.println("sin_table:");
        for(int i = 0;i<64;) {
            System.out.print("    dw ");
            for(int j = 0;j<16;j++,i++) {
                double angle = Math.PI*(i/128.0);
                double c = Math.sin(angle)*256;
                if (j==0) {
                    System.out.print(((int)c) + "");
                } else {
                    System.out.print(", " + ((int)c));
                }
            }
            System.out.println("");
        }
        System.out.println("cos_table:");
        for(int i = 0;i<256;) {
            System.out.print("    dw ");
            for(int j = 0;j<16;j++,i++) {
                double angle = Math.PI*(i/128.0);
                double c = Math.cos(angle)*256;
                if (j==0) {
                    System.out.print(((int)c) + "");
                } else {
                    System.out.print(", " + ((int)c));
                }
            }
            System.out.println("");
        }        
        System.out.println("");
        
        System.out.println("sin_table_x"+(int)walk_speed+":");
        for(int i = 0;i<64;) {
            System.out.print("    dw ");
            for(int j = 0;j<16;j++,i++) {
                double angle = Math.PI*(i/128.0);
                double c = Math.sin(angle)*256*walk_speed;
                if (j==0) {
                    System.out.print(((int)c) + "");
                } else {
                    System.out.print(", " + ((int)c));
                }
            }
            System.out.println("");
        }
        System.out.println("cos_table_x"+(int)walk_speed+":");
        for(int i = 0;i<256;) {
            System.out.print("    dw ");
            for(int j = 0;j<16;j++,i++) {
                double angle = Math.PI*(i/128.0);
                double c = Math.cos(angle)*256*walk_speed;
                if (j==0) {
                    System.out.print(((int)c) + "");
                } else {
                    System.out.print(", " + ((int)c));
                }
            }
            System.out.println("");
        }
    }
}
