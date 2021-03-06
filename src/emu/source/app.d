import std.stdio;
import bindbc.sdl;
import host.sdl;
import gba;
import commandr;
import util;
import keyinput;
import std.conv;

version (gperf) {
	import gperftools_d.profiler;
}

void main(string[] args) {
	auto a = new Program("gamebean-emu", "0.1").summary("GameBean Advance")
			.add(new Flag("v", "verbose", "turns on more verbose output").repeating)
			.add(new Option("s", "scale", "render scale").optional.defaultValue("1"))
			.add(new Argument("rompath", "path to rom file"))
			.add(new Option("t", "cputrace", "display cpu trace on crash").optional.defaultValue("0")).parse(args);

	util.verbosity_level = a.occurencesOf("verbose");

	SDLSupport ret = loadSDL();
	if (ret != sdlSupport) {
		if (ret == SDLSupport.badLibrary) {
			stderr.writeln("bad sdl library");
		} else if (ret == SDLSupport.noLibrary) {
			stderr.writeln("no sdl library");
		}
	}
	writeln("loaded sdl2");

	auto mem = new Memory();
	writeln("init mem");

	KeyInput key_input = new KeyInput(mem);
	GBA gba = new GBA(mem, key_input);
	writeln("init gba");
	gba.load_rom(a.arg("rompath"));
	writeln("loaded rom");

	writeln("running sdl2 renderer");
	auto host = new GameBeanSDLHost(gba, to!int(a.option("scale")));
	host.init();

	int cpu_trace_length = to!int(a.option("cputrace"));
	if (cpu_trace_length != 0) {
		host.enable_cpu_tracing(cpu_trace_length);
	}

	version (gperf) {
		writeln("---- STARTED PROFILER ----");
		ProfilerStart();
	}

	host.run();

	version (gperf) {
		ProfilerStop();
		writeln("---- ENDED PROFILER ----");
	}

	scope(failure) host.print_trace();
}
