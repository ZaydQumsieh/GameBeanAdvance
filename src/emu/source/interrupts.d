module interrupts;

import std.stdio;

// set up the possible interrupts
enum Interrupt {
    LCD_VBLANK           = 1,
    LCD_HBLANK           = 2,
    LCD_VCOUNTER_MATCH   = 4,
    TIMER_0_OVERFLOW     = 8,
    TIMER_1_OVERFLOW     = 16,
    TIMER_2_OVERFLOW     = 32,
    TIMER_3_OVERFLOW     = 64,
    SERIAL_COMMUNICATION = 128,
    DMA_0                = 256,
    DMA_1                = 512,
    DMA_2                = 1024,
    DMA_3                = 2048,
    KEYPAD               = 4096,
    GAMEPAK              = 8192
}

class InterruptManager {
    this(bool delegate() interrupt_cpu) {
        this.interrupt_cpu = interrupt_cpu;
    }

    // interrupt_code must be one-hot
    void interrupt(uint interrupt_code) {
        if (!(interrupt_master_enable & 0x1)) return; // if interrupts are disabled globally, ignore.

        // is this specific interrupt enabled
        if (interrupt_enable & interrupt_code) {
            interrupt_request |= interrupt_code;
            interrupt_cpu();
        }
    }

private:
    bool delegate() interrupt_cpu;

// .......................................................................................................................
// .RRRRRRRRRRR...EEEEEEEEEEEE....GGGGGGGGG....IIII...SSSSSSSSS...TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRR....SSSSSSSSS....
// .RRRRRRRRRRRR..EEEEEEEEEEEE...GGGGGGGGGGG...IIII..SSSSSSSSSSS..TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSS...
// .RRRRRRRRRRRRR.EEEEEEEEEEEE..GGGGGGGGGGGGG..IIII..SSSSSSSSSSSS.TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEE..........GGGGG....GGGG..IIII..SSSS....SSSS.....TTTT......EEEE..........RRR.....RRRRR.SSSS....SSSS..
// .RRRR.....RRRR.EEEE.........GGGGG......GGG..IIII..SSSS.............TTTT......EEEE..........RRR......RRRR.SSSSS.........
// .RRRR....RRRRR.EEEEEEEEEEEE.GGGG............IIII..SSSSSSSS.........TTTT......EEEEEEEEEEEE..RRR.....RRRR..SSSSSSSS......
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR...SSSSSSSSSS...
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII....SSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR....SSSSSSSSSS..
// .RRRRRRRRRRR...EEEE.........GGGG....GGGGGGG.IIII........SSSSSS.....TTTT......EEEE..........RRRRRRRRRR..........SSSSSS..
// .RRRR..RRRRR...EEEE.........GGGGG......GGGG.IIII...SS.....SSSS.....TTTT......EEEE..........RRR...RRRRR....SS.....SSSS..
// .RRRR...RRRR...EEEE..........GGGGG....GGGGG.IIII.ISSSS....SSSS.....TTTT......EEEE..........RRR....RRRR...SSSS....SSSS..
// .RRRR...RRRRR..EEEEEEEEEEEEE.GGGGGGGGGGGGGG.IIII.ISSSSSSSSSSSS.....TTTT......EEEEEEEEEEEEE.RRR....RRRRR..SSSSSSSSSSSS..
// .RRRR....RRRRR.EEEEEEEEEEEEE..GGGGGGGGGGGG..IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR.SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEEEEEEEEEEE...GGGGGGGGG....IIII...SSSSSSSSS.......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR..SSSSSSSSSS...

private:
    bool   interrupt_master_enable;
    ushort interrupt_enable;
    ushort interrupt_request;

public:
    void write_IF(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0: interrupt_request &= (0xFF00) | ((~data) << 0); break;
            case 0b1: interrupt_request &= (0x00FF) | ((~data) << 8); break;
        }
    }

    void write_IE(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0: interrupt_enable = (interrupt_enable & 0xFF00) | (data << 0); break;
            case 0b1: interrupt_enable = (interrupt_enable & 0x00FF) | (data << 8); break;
        }
    }

    void write_IME(int target_byte, ubyte data) {
        // writefln("Setting IME to %x %x", data, target_byte);
        final switch (target_byte) {
            case 0b0: interrupt_master_enable = data & 1; break;
            case 0b1: break;
        }
    }

    ubyte read_IF(int target_byte) {
        final switch (target_byte) {
            case 0b0: return (interrupt_request & 0x00FF) >> 0;
            case 0b1: return (interrupt_request & 0xFF00) >> 8;
        }
    }

    ubyte read_IE(int target_byte) {
        final switch (target_byte) {
            case 0b0: return (interrupt_enable & 0x00FF) >> 0;
            case 0b1: return (interrupt_enable & 0xFF00) >> 8;
        }
    }

    ubyte read_IME(int target_byte) {
        final switch (target_byte) {
            case 0b0: return interrupt_master_enable;
            case 0b1: return 0;
        }
    }
}