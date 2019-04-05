struct ThriftPayloadFifth {
	1: optional string tffirst,
	2: optional string tfsecond,
	3: optional string tfthird,
	4: optional string tffourth
}

struct ThriftPayload {
	1: required bool   tfirst,
	2: required bool   tsecond,
	3: required double tthird,
	4: required i32    tfourth,
	5: optional list<ThriftPayloadFifth> tfifth,
	6: optional list<i32> tsixth
}

