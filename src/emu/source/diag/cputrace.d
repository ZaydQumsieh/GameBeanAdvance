module cputrace;

import std.stdio;
import std.format;

import cpu;
import ringbuffer;

class CpuTrace {
    ARM7TDMI cpu;
    RingBuffer!CpuState ringbuffer;

    this(ARM7TDMI cpu, int length) {
        this.cpu        = cpu;
        this.ringbuffer = new RingBuffer!CpuState(length);
    }

    void capture() {
        ringbuffer.add(get_cpu_state(cpu));
    }

    void print_trace() {
        CpuState[] trace = ringbuffer.get();
        for (int i = 0; i < trace.length; i++) {
            if (trace[i].type == CpuType.THUMB) {
                write("THUMB     ");
                write(format("%04x | ", trace[i].opcode));
            } else {
                write("ARM   ");
                write(format("%08x | ", trace[i].opcode));
            }

            for (int j = 0; j < 16; j++)
                write(format("%08x ", trace[i].regs[j]));

            write(format(" | %08x", trace[i].mode));
            writeln();
        }
    }
}