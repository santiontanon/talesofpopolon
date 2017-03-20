/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package music;

import java.io.File;
import java.io.PrintStream;
import java.util.List;

/**
 *
 * @author santi
 */
public class ToPMusic {
    
    
    public static void main(String args[]) throws Exception {
        String path = args[0];
        MSXSong s1 = LoPStorySong();
        PrintStream w1 = new PrintStream(new File(path+"/ToPStorySong.asm"));
        s1.convertToAssembler("ToPStorySong", w1);
        w1.close();
  
        MSXSong s2 = LoPInGameSong();
        PrintStream w2 = new PrintStream(new File(path+"/ToPInGameSong.asm"));
        s2.convertToAssembler("ToPInGameSong", w2);
        w2.close();

        MSXSong s3 = LoPBossSong();
        PrintStream w3 = new PrintStream(new File(path+"/ToPBossSong.asm"));
        s3.convertToAssembler("ToPBossSong", w3);
        w3.close();

        MSXSong s4 = LoPStartSong();
        PrintStream w4 = new PrintStream(new File(path+"/ToPStartSong.asm"));
        s4.convertToAssembler("ToPStartSong", w4);
        w4.close();

        MSXSong s5 = LoPGameOverSong();
        PrintStream w5 = new PrintStream(new File(path+"/ToPGameOverSong.asm"));
        s5.convertToAssembler("ToPGameOverSong", w5);
        w5.close();
    }   
    
    
    public static MSXSong LoPStorySong()
    {
        MSXSong song = new MSXSong();
        List<MSXNote> channel1 = song.channels[0];
        List<MSXNote> channel2 = song.channels[1];
        List<MSXNote> channel3 = song.channels[2];
        
        int ch1_instrument = MSXNote.INSTRUMENT_WIND;
        int ch2_instrument = MSXNote.INSTRUMENT_WIND;
        int ch3_instrument = MSXNote.INSTRUMENT_SQUARE_WAVE;

        // channel 1:
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        song.loopBackTime = 4;
        channel1.add(new MSXNote(4,MSXNote.DO,15,8, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.FA,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.FA,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.DO,15,8, ch1_instrument));
        
        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.RE,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.MI,15,8, ch1_instrument));
        
        channel1.add(new MSXNote(4,MSXNote.MI,15,4, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.SOL,15,4, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.RE,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(4,MSXNote.RE,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.MI,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.FA,15,12, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.LA,15,4, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.MI,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,8, ch1_instrument));

        channel1.add(new MSXNote(4));   // silence
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,4, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.DO,15,12, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,12, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,4, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.LA,15,12, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        // channel 2:
        channel2.add(new MSXNote(4));   // silence
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(3,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));

        channel2.add(new MSXNote(3,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(3,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(1,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(1,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(1,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(1,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.RE,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.SOL,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        // channel 3:
        channel3.add(new MSXNote(4));   // silence
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.FA,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.RE,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.RE,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.DO,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SOL,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.RE,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.FA,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.RE,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.MI,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SOL,15,16, ch3_instrument));
        channel3.add(new MSXNote(2,MSXNote.MI,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        
        return song;
    }
    
    
    public static MSXSong LoPBossSong()
    {
        MSXSong song = new MSXSong();
        List<MSXNote> channel1 = song.channels[0];
        List<MSXNote> channel2 = song.channels[1];
        List<MSXNote> channel3 = song.channels[2];
        
        int ch1_instrument = MSXNote.INSTRUMENT_PIANO;
        int ch2_instrument = MSXNote.INSTRUMENT_SQUARE_WAVE;
        int ch3_instrument = MSXNote.INSTRUMENT_SQUARE_WAVE;

        // channel 1:
        song.loopBackTime = 0;
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_FAArpegio(channel1, ch1_instrument);
        LopBossSong_FAArpegio(channel1, ch1_instrument);
        LopBossSong_FAArpegio(channel1, ch1_instrument);
        LopBossSong_FAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_LAArpegio(channel1, ch1_instrument);
        LopBossSong_SOLArpegio(channel1, ch1_instrument);
        LopBossSong_SOLArpegio(channel1, ch1_instrument);
        LopBossSong_SOLArpegio(channel1, ch1_instrument);
        LopBossSong_SOLArpegio(channel1, ch1_instrument);

        channel1.add(new MSXNote(4,MSXNote.LA,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.FA_SHARP,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.MI_FLAT,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));        
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.MI_FLAT,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.FA_SHARP,15,1, ch1_instrument));        
        channel1.add(new MSXNote(4,MSXNote.LA,15,1, ch1_instrument));        
        channel1.add(new MSXNote(5,MSXNote.DO,15,1, ch1_instrument));        
        channel1.add(new MSXNote(5,MSXNote.MI_FLAT,15,1, ch1_instrument));        
        channel1.add(new MSXNote(5,MSXNote.FA_SHARP,15,1, ch1_instrument));        
        channel1.add(new MSXNote(5,MSXNote.LA,15,4, ch1_instrument));        
        
        // channel 2:
        channel2.add(new MSXNote(1,MSXNote.LA,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.SOL_SHARP,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.LA,15,8, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.DO,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.SOL_SHARP,15,15, ch2_instrument));        
        channel2.add(new MSXNote(1));   // silence
        
        channel2.add(new MSXNote(1,MSXNote.LA,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.SOL_SHARP,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.LA,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.FA,15,8, ch2_instrument));        
        channel2.add(new MSXNote(1,MSXNote.MI,15,15, ch2_instrument));        
        channel2.add(new MSXNote(1));   // silence
                
        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.RE_SHARP,15,8, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.SOL,15,8, ch2_instrument));        

        channel2.add(new MSXNote(2,MSXNote.LA,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.FA_SHARP,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.MI_FLAT,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.DO,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.MI_FLAT,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.FA_SHARP,15,2, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.LA,15,4, ch2_instrument));        
        
        // channel 3:
        channel3.add(new MSXNote(0,MSXNote.LA,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.SOL_SHARP,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.LA,15,8, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.DO,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.SOL_SHARP,15,15, ch3_instrument));        
        channel3.add(new MSXNote(1));   // silence

        channel3.add(new MSXNote(0,MSXNote.LA,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.SOL_SHARP,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.LA,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.FA,15,8, ch3_instrument));        
        channel3.add(new MSXNote(0,MSXNote.MI,15,15, ch3_instrument));        
        channel3.add(new MSXNote(1));   // silence
                
        channel3.add(new MSXNote(1,MSXNote.MI,15,8, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.RE_SHARP,15,8, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.MI,15,8, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.SOL,15,8, ch3_instrument));        

        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.FA_SHARP,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.MI_FLAT,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.DO,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.MI_FLAT,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.FA_SHARP,15,2, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.LA,15,4, ch3_instrument));        
        

        return song;
    }    
    
    
    public static void LopBossSong_LAArpegio(List<MSXNote> channel, int instrument)
    {
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.MI,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.MI,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));        
    }

    
    public static void LopBossSong_FAArpegio(List<MSXNote> channel, int instrument)
    {
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.FA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.FA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.LA,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, instrument));        
    }


    public static void LopBossSong_SOLArpegio(List<MSXNote> channel, int instrument)
    {
        channel.add(new MSXNote(3,MSXNote.SI,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SI_FLAT,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SI,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SI_FLAT,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SOL,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SI,15,1, instrument));
        channel.add(new MSXNote(3,MSXNote.SI_FLAT,15,1, instrument));
    }
    
    
    public static MSXSong LoPInGameSong()
    {
        MSXSong song = new MSXSong();
        List<MSXNote> channel1 = song.channels[0];
        List<MSXNote> channel2 = song.channels[1];
        List<MSXNote> channel3 = song.channels[2];
        
        int ch1_instrument = MSXNote.INSTRUMENT_PIANO;
        int ch2_instrument = MSXNote.INSTRUMENT_PIANO;
        int ch3_instrument = MSXNote.INSTRUMENT_PIANO;
        
        // channel 1:
        channel1.add(new MSXNote(2,MSXNote.LA,15,2, ch1_instrument));

        song.loopBackTime = 2;
        channel1.add(new MSXNote(3,MSXNote.MI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.DO,15,1, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.DO,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.RE,15,3, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(2,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL,15,1, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.FA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.RE,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.MI,15,6, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,6, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));
        
        channel1.add(new MSXNote(4,MSXNote.DO,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,1, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.FA,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.MI,15,16, ch1_instrument));
        
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        
        // second part starts:
        channel1.add(new MSXNote(3,MSXNote.MI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.MI,15,3, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE_SHARP,15,2, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.MI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.DO,15,3, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.MI,15,1, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,2, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.MI,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.MI,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.FA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.MI,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(3,MSXNote.DO,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SI,15,1, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.DO,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.RE,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SI,15,1, ch1_instrument));

        channel1.add(new MSXNote(2,MSXNote.SI,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.LA,15,1, ch1_instrument));
        
        channel1.add(new MSXNote(2,MSXNote.SI,15,5, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.DO,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SI,15,1, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.LA,15,1, ch1_instrument));

        channel1.add(new MSXNote(2,MSXNote.MI,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SOL_SHARP,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(2,MSXNote.LA,15,2, ch1_instrument));

        
        for(MSXNote n:channel1) {
            n.absoluteNote+=12;
        }
        
        
        // channel 2:
        channel2.add(new MSXNote(2));   // silence
        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);
        
        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);

        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);
        
        LopInGameSong_Bass(1, MSXNote.LA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.SOL, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.FA, channel2, ch2_instrument);
        LopInGameSong_Bass(1, MSXNote.MI, channel2, ch2_instrument);
        
        // second part starts:
        channel2.add(new MSXNote(1,MSXNote.SI,15,8, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.SI,15,8, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,8, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.FA,15,2, ch2_instrument));

        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));

        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,1, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        channel2.add(new MSXNote(1,MSXNote.MI,15,2, ch2_instrument));
        
        // channel 3:
        channel3.add(new MSXNote(2));   // silence
        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        
        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        
        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence

        channel3.add(new MSXNote(0,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.SOL,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.FA,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(0,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        
        // second part starts
        channel3.add(new MSXNote(1,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(1,MSXNote.MI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence

        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(6));   // silence
                
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));

        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,1, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.SI,15,2, ch3_instrument));
        
        return song;
    }
    
    public static void LopInGameSong_Bass(int octave, int note, List<MSXNote> channel, int instrument)
    {
        channel.add(new MSXNote(octave,note,15,2, instrument));
        channel.add(new MSXNote(octave,note,15,1, instrument));
        channel.add(new MSXNote(octave,note,15,1, instrument));
        channel.add(new MSXNote(octave,note,15,2, instrument));
        channel.add(new MSXNote(octave,note,15,1, instrument));
        channel.add(new MSXNote(octave,note,15,1, instrument));
    }   
    

    public static MSXSong LoPStartSong()
    {
        MSXSong song = new MSXSong();
        List<MSXNote> channel1 = song.channels[0];
        List<MSXNote> channel2 = song.channels[1];
        List<MSXNote> channel3 = song.channels[2];
        
        int ch1_instrument = MSXNote.INSTRUMENT_PIANO;
        int ch2_instrument = MSXNote.INSTRUMENT_PIANO;
        int ch3_instrument = MSXNote.INSTRUMENT_PIANO;

        // channel 1:
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.LA,15,1, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.DO,15,2, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.MI,15,3, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.FA,15,3, ch1_instrument));
        channel1.add(new MSXNote(4,MSXNote.LA,15,6, ch1_instrument));        
        channel1.add(new MSXNote(1));   // silence
        
        // channel 2:
        channel2.add(new MSXNote(2,MSXNote.MI,15,4, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.FA,15,4, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.MI,15,3, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.FA,15,3, ch2_instrument));        
        channel2.add(new MSXNote(2,MSXNote.MI,15,6, ch2_instrument));        
        channel2.add(new MSXNote(1));   // silence

        // channel 3:
        channel3.add(new MSXNote(1,MSXNote.LA,15,4, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.SI,15,4, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.LA,15,3, ch3_instrument));        
        channel3.add(new MSXNote(1,MSXNote.SI,15,3, ch3_instrument));        
        channel3.add(new MSXNote(2,MSXNote.DO,15,6, ch3_instrument));        
        channel3.add(new MSXNote(1));   // silence
        
        return song;
    }
    
    
    public static MSXSong LoPGameOverSong()
    {
        MSXSong song = new MSXSong();
        List<MSXNote> channel1 = song.channels[0];
        List<MSXNote> channel2 = song.channels[1];
        List<MSXNote> channel3 = song.channels[2];
        
        int ch1_instrument = MSXNote.INSTRUMENT_WIND;
        int ch2_instrument = MSXNote.INSTRUMENT_SQUARE_WAVE;
        int ch3_instrument = MSXNote.INSTRUMENT_SQUARE_WAVE;

        // channel 1:
        channel1.add(new MSXNote(3,MSXNote.LA,15,2, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SI,15,2, ch1_instrument));

        channel1.add(new MSXNote(4,MSXNote.DO,15,8, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,4, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,4, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,8, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.SI,15,6, ch1_instrument));
        channel1.add(new MSXNote(3,MSXNote.SOL,15,6, ch1_instrument));

        channel1.add(new MSXNote(3,MSXNote.LA,15,12, ch1_instrument));
        channel1.add(new MSXNote(1));   // silence
        
        // channel 2:
        channel2.add(new MSXNote(4));   // silence
        channel2.add(new MSXNote(2,MSXNote.MI,15,16, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.LA,15,20, ch2_instrument));
        channel2.add(new MSXNote(2,MSXNote.MI,15,12, ch2_instrument));
        channel2.add(new MSXNote(1));   // silence

        // channel 3:
        channel3.add(new MSXNote(4));   // silence
        channel3.add(new MSXNote(1,MSXNote.LA,15,16, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.FA,15,20, ch3_instrument));
        channel3.add(new MSXNote(1,MSXNote.LA,15,12, ch3_instrument));
        channel3.add(new MSXNote(1));   // silence
        
        return song;
    }        
    
}
