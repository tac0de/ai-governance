use core::ffi::{c_char, c_uchar};
use serde_json::{Map, Value};
use sha2::{Digest, Sha256};
use std::ffi::{CStr, CString};

#[repr(C)]
pub struct RustBuffer {
    pub ptr: *mut c_uchar,
    pub len: usize,
}

pub fn canonicalize(input: &[u8]) -> Vec<u8> {
    match serde_json::from_slice::<Value>(input) {
        Ok(v) => {
            let normalized = normalize_value(v);
            serde_json::to_vec(&normalized).unwrap_or_else(|_| input.to_vec())
        }
        Err(_) => input.to_vec(),
    }
}

pub fn sha256_hex(input: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(input);
    let digest = hasher.finalize();
    format!("{digest:x}")
}

pub fn verify_checksums(
    plan: &[u8],
    result: &[u8],
    evidence: &[u8],
    expected_plan: &str,
    expected_result: &str,
    expected_evidence: &str,
) -> bool {
    sha256_hex(plan) == expected_plan
        && sha256_hex(result) == expected_result
        && sha256_hex(evidence) == expected_evidence
}

fn normalize_value(v: Value) -> Value {
    match v {
        Value::Object(map) => {
            let mut pairs: Vec<(String, Value)> = map.into_iter().collect();
            pairs.sort_by(|a, b| a.0.cmp(&b.0));
            let mut new_map = Map::new();
            for (k, val) in pairs {
                new_map.insert(k, normalize_value(val));
            }
            Value::Object(new_map)
        }
        Value::Array(arr) => Value::Array(arr.into_iter().map(normalize_value).collect()),
        other => other,
    }
}

#[no_mangle]
pub extern "C" fn rac_canonicalize(input_ptr: *const c_uchar, input_len: usize) -> RustBuffer {
    let input = if input_ptr.is_null() || input_len == 0 {
        &[][..]
    } else {
        unsafe { std::slice::from_raw_parts(input_ptr, input_len) }
    };

    let out = canonicalize(input);
    let mut boxed = out.into_boxed_slice();
    let ptr = boxed.as_mut_ptr();
    let len = boxed.len();
    std::mem::forget(boxed);

    RustBuffer { ptr, len }
}

#[no_mangle]
pub extern "C" fn rac_sha256_hex(input_ptr: *const c_uchar, input_len: usize) -> *mut c_char {
    let input = if input_ptr.is_null() || input_len == 0 {
        &[][..]
    } else {
        unsafe { std::slice::from_raw_parts(input_ptr, input_len) }
    };

    let s = sha256_hex(input);
    CString::new(s).map_or(std::ptr::null_mut(), CString::into_raw)
}

#[no_mangle]
pub extern "C" fn rac_verify_checksums(
    plan_ptr: *const c_uchar,
    plan_len: usize,
    result_ptr: *const c_uchar,
    result_len: usize,
    evidence_ptr: *const c_uchar,
    evidence_len: usize,
    expected_plan_ptr: *const c_char,
    expected_result_ptr: *const c_char,
    expected_evidence_ptr: *const c_char,
) -> bool {
    if expected_plan_ptr.is_null() || expected_result_ptr.is_null() || expected_evidence_ptr.is_null() {
        return false;
    }

    let plan = if plan_ptr.is_null() || plan_len == 0 {
        &[][..]
    } else {
        unsafe { std::slice::from_raw_parts(plan_ptr, plan_len) }
    };
    let result = if result_ptr.is_null() || result_len == 0 {
        &[][..]
    } else {
        unsafe { std::slice::from_raw_parts(result_ptr, result_len) }
    };
    let evidence = if evidence_ptr.is_null() || evidence_len == 0 {
        &[][..]
    } else {
        unsafe { std::slice::from_raw_parts(evidence_ptr, evidence_len) }
    };

    let expected_plan = unsafe { CStr::from_ptr(expected_plan_ptr) }.to_string_lossy();
    let expected_result = unsafe { CStr::from_ptr(expected_result_ptr) }.to_string_lossy();
    let expected_evidence = unsafe { CStr::from_ptr(expected_evidence_ptr) }.to_string_lossy();

    verify_checksums(
        plan,
        result,
        evidence,
        expected_plan.as_ref(),
        expected_result.as_ref(),
        expected_evidence.as_ref(),
    )
}

#[no_mangle]
pub extern "C" fn rac_free_buffer(buf: RustBuffer) {
    if buf.ptr.is_null() || buf.len == 0 {
        return;
    }
    unsafe {
        let _ = Vec::from_raw_parts(buf.ptr, buf.len, buf.len);
    }
}

#[no_mangle]
pub extern "C" fn rac_free_cstring(s: *mut c_char) {
    if s.is_null() {
        return;
    }
    unsafe {
        let _ = CString::from_raw(s);
    }
}
