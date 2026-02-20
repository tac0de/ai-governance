package auditffi

/*
#cgo LDFLAGS: -L${SRCDIR}/../../audit-core/rust/target/release -lrust_audit_core
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
  uint8_t* ptr;
  uintptr_t len;
} RustBuffer;

RustBuffer rac_canonicalize(const uint8_t* input_ptr, uintptr_t input_len);
char* rac_sha256_hex(const uint8_t* input_ptr, uintptr_t input_len);
bool rac_verify_checksums(
  const uint8_t* plan_ptr, uintptr_t plan_len,
  const uint8_t* result_ptr, uintptr_t result_len,
  const uint8_t* evidence_ptr, uintptr_t evidence_len,
  const char* expected_plan_ptr,
  const char* expected_result_ptr,
  const char* expected_evidence_ptr
);
void rac_free_buffer(RustBuffer buf);
void rac_free_cstring(char* s);
*/
import "C"

import "unsafe"

func bytePtr(b []byte) *C.uint8_t {
	if len(b) == 0 {
		return nil
	}
	return (*C.uint8_t)(unsafe.Pointer(&b[0]))
}

func Canonicalize(input []byte) []byte {
	buf := C.rac_canonicalize(bytePtr(input), C.uintptr_t(len(input)))
	if buf.ptr == nil || buf.len == 0 {
		return []byte{}
	}
	out := C.GoBytes(unsafe.Pointer(buf.ptr), C.int(buf.len))
	C.rac_free_buffer(buf)
	return out
}

func SHA256Hex(input []byte) string {
	ptr := C.rac_sha256_hex(bytePtr(input), C.uintptr_t(len(input)))
	if ptr == nil {
		return ""
	}
	defer C.rac_free_cstring(ptr)
	return C.GoString(ptr)
}

func VerifyChecksums(
	plan []byte,
	result []byte,
	evidence []byte,
	expectedPlan string,
	expectedResult string,
	expectedEvidence string,
) bool {
	cPlan := C.CString(expectedPlan)
	cResult := C.CString(expectedResult)
	cEvidence := C.CString(expectedEvidence)
	defer C.free(unsafe.Pointer(cPlan))
	defer C.free(unsafe.Pointer(cResult))
	defer C.free(unsafe.Pointer(cEvidence))

	ok := C.rac_verify_checksums(
		bytePtr(plan), C.uintptr_t(len(plan)),
		bytePtr(result), C.uintptr_t(len(result)),
		bytePtr(evidence), C.uintptr_t(len(evidence)),
		cPlan,
		cResult,
		cEvidence,
	)
	return bool(ok)
}
