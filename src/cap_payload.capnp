@0xccc15e35dcdc69bc;

struct CPayloadFifth {
	first  @0 :Text;
	second @1 :Text;
	third  @2 :Text;
	fourth @3 :Text;
}

struct CPayload {
	first  @0 :Bool;
	second @1 :Bool;
	third  @2 :Float64;
	fourth @3 :Int32;
	fifth  @4 :List(CPayloadFifth);
	sixth  @5 :List(Int32);
}
