//
//  field_10x26.swift
//  secp256k1
//
//  Created by pebble8888 on 2017/12/17.
//  Copyright © 2017 pebble8888. All rights reserved.
//
/**********************************************************************
 * Copyright (c) 2013, 2014 Pieter Wuille                             *
 * Distributed under the MIT software license, see the accompanying   *
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.*
 **********************************************************************/

import Foundation

//
// 体演算 26bit のlimb
//
struct secp256k1_fe {
    /* X = sum(i=0..9, elem[i]*2^26) mod n */
    // 先頭が下位
    public var n: [UInt32] // size:10
#if VERIFY
    public var magnitude: Int  //
    public var normalized: bool // 1:normalized, 0:not
#endif

    static func VERIFY_CHECK(_ a:Bool){
        assert(a);
    }
    init() {
        n = [UInt32](repeating: 0, count: 10)
    }
    
    init(_ n0:UInt32,
         _ n1:UInt32,
         _ n2:UInt32,
         _ n3:UInt32,
         _ n4:UInt32,
         _ n5:UInt32,
         _ n6:UInt32,
         _ n7:UInt32,
         _ n8:UInt32,
         _ n9:UInt32)
    {
        n = [UInt32](repeating: 0, count: 10)
        n[0] = n0
        n[1] = n1
        n[2] = n2
        n[3] = n3
        n[4] = n4
        n[5] = n5
        n[6] = n6
        n[7] = n7
        n[8] = n8
        n[9] = n9
    }
    
    func equal(_ a: secp256k1_fe) -> Bool {
        for i in 0 ..< 10 {
            if self.n[i] != a.n[i] {
                return false
            }
        }
        return true
    }
}

/* Unpacks a constant into a overlapping multi-limbed FE element. */
func SECP256K1_FE_CONST_INNER(_ d7:UInt32,
                              _ d6:UInt32,
                              _ d5:UInt32,
                              _ d4:UInt32,
                              _ d3:UInt32,
                              _ d2:UInt32,
                              _ d1:UInt32,
                              _ d0:UInt32) -> secp256k1_fe
{
    let n0 = (d0) & 0x3FFFFFF
    let n1 = (d0 >> 26) | ((d1 & 0xFFFFF) << 6)
    let n2 = (d1 >> 20) | ((d2 & 0x3FFF) << 12)
    let n3 = (d2 >> 14) | ((d3 & 0xFF) << 18)
    let n4 = (d3 >> 8) | ((d4 & 0x3) << 24)
    let n5 = (d4 >> 2) & 0x3FFFFFF
    let n6 = (d4 >> 28) | ((d5 & 0x3FFFFF) << 4)
    let n7 = (d5 >> 22) | ((d6 & 0xFFFF) << 10)
    let n8 = (d6 >> 16) | ((d7 & 0x3FF) << 16)
    let n9 = (d7 >> 10)
    return secp256k1_fe(n0, n1, n2, n3, n4, n5, n6, n7, n8, n9)
}

func SECP256K1_FE_CONST(_ d7:UInt32,
                        _ d6:UInt32,
                        _ d5:UInt32,
                        _ d4:UInt32,
                        _ d3:UInt32,
                        _ d2:UInt32,
                        _ d1:UInt32,
                        _ d0:UInt32) -> secp256k1_fe
{
    return SECP256K1_FE_CONST_INNER(d7, d6, d5, d4, d3, d2, d1, d0)
}


func SECP256K1_FE_STORAGE_CONST(_ d7:UInt32,
                                _ d6:UInt32,
                                _ d5:UInt32,
                                _ d4:UInt32,
                                _ d3:UInt32,
                                _ d2:UInt32,
                                _ d1:UInt32,
                                _ d0:UInt32) -> secp256k1_fe_storage
{
    return secp256k1_fe_storage(d0, d1, d2, d3, d4, d5, d6, d7)
}
    
struct secp256k1_fe_storage {
    var n:[UInt32] // size:8
    init(){
        n = [UInt32](repeating: 0, count: 8)
    }
    init(_ n0:UInt32,
         _ n1:UInt32,
         _ n2:UInt32,
         _ n3:UInt32,
         _ n4:UInt32,
         _ n5:UInt32,
         _ n6:UInt32,
         _ n7:UInt32)
    {
        n = [UInt32](repeating:0, count:8)
        n[0] = n0
        n[1] = n1
        n[2] = n2
        n[3] = n3
        n[4] = n4
        n[5] = n5
        n[6] = n6
        n[7] = n7
    }
    mutating func clear(){
        for i in 0..<8 {
            n[i] = 0
        }
    }
    func equal(_ a: secp256k1_fe_storage) -> Bool {
        for i in 0..<8 {
            if self.n[i] != a.n[i] {
                return false
            }
        }
        return true
    }
}


//#include "util.h"
//#include "num.h"
//#include "field.h"

#if VERIFY
// verify magnitude
func secp256k1_fe_verify(_ a: secp256k1_fe) {
    let d:UInt32 = a.n
    let m:Int = a->normalized ? 1 : 2 * a->magnitude
    let r:Int = 1
    r &= (d[0] <= 0x3FFFFFF * m)
    r &= (d[1] <= 0x3FFFFFF * m)
    r &= (d[2] <= 0x3FFFFFF * m)
    r &= (d[3] <= 0x3FFFFFF * m)
    r &= (d[4] <= 0x3FFFFFF * m)
    r &= (d[5] <= 0x3FFFFFF * m)
    r &= (d[6] <= 0x3FFFFFF * m)
    r &= (d[7] <= 0x3FFFFFF * m)
    r &= (d[8] <= 0x3FFFFFF * m)
    r &= (d[9] <= 0x03FFFFF * m)
    r &= (a->magnitude >= 0)
    r &= (a->magnitude <= 32)
    if (a->normalized) {
        r &= (a->magnitude <= 1)
        if (r && (d[9] == 0x03FFFFF)) {
            let mid:UInt32 = d[8] & d[7] & d[6] & d[5] & d[4] & d[3] & d[2]
            if (mid == 0x3FFFFFF) {
                r &= ((d[1] + 0x40 + ((d[0] + 0x3D1) >> 26)) <= 0x3FFFFFF)
            }
        }
    }
    VERIFY_CHECK(r == 1)
}
#endif

fileprivate func VERIFY_CHECK(_ cond: Bool)
{
    assert(cond)
}

// normalize
func secp256k1_fe_normalize(_ r: inout secp256k1_fe) {
    var t0:UInt32 = r.n[0]
    var t1:UInt32 = r.n[1]
    var t2:UInt32 = r.n[2]
    var t3:UInt32 = r.n[3]
    var t4:UInt32 = r.n[4]
    var t5:UInt32 = r.n[5]
    var t6:UInt32 = r.n[6]
    var t7:UInt32 = r.n[7]
    var t8:UInt32 = r.n[8]
    var t9:UInt32 = r.n[9]

    /* Reduce t9 at the start so there will be at most a single carry from the first pass */
    var m:UInt32;
    var x:UInt32 = t9 >> 22; t9 &= 0x03FFFFF

    /* The first pass ensures the magnitude is 1, ... */
    t0 += x * 0x3D1; t1 += (x << 6);
    t1 += (t0 >> 26); t0 &= 0x3FFFFFF;
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF; m = t2;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF; m &= t3;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF; m &= t4;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF; m &= t5;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF; m &= t6;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF; m &= t7;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF; m &= t8;

    /* ... except for a possible carry at bit 22 of t9 (i.e. bit 256 of the field element) */
    VERIFY_CHECK(t9 >> 23 == 0);

    //
    // strong
    //
    /* At most a single final reduction is needed; check if the value is >= the field characteristic */
    x = (t9 >> 22) | ((t9 == 0x03FFFFF ? 1 : 0) & (m == 0x3FFFFFF ? 1 : 0)
        & ((t1 + 0x40 + ((t0 + 0x3D1) >> 26)) > 0x3FFFFFF ? 1 : 0))

    /* Apply the final reduction (for constant-time behaviour, we do it always) */
    t0 += x * 0x3D1; t1 += (x << 6);
    t1 += (t0 >> 26); t0 &= 0x3FFFFFF;
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF;

    /* If t9 didn't carry to bit 22 already, then it should have after any final reduction */
    VERIFY_CHECK(t9 >> 22 == x);

    //
    // strong
    //
    /* Mask off the possible multiple of 2^256 from the final reduction */
    t9 &= 0x03FFFFF;

    r.n[0] = t0; r.n[1] = t1; r.n[2] = t2; r.n[3] = t3; r.n[4] = t4;
    r.n[5] = t5; r.n[6] = t6; r.n[7] = t7; r.n[8] = t8; r.n[9] = t9;

#if VERIFY
    r->magnitude = 1;
    r->normalized = 1;
    secp256k1_fe_verify(r);
#endif
}

func secp256k1_fe_normalize_weak(_ r:inout secp256k1_fe) {
    var t0 = r.n[0]
    var t1 = r.n[1]
    var t2 = r.n[2]
    var t3 = r.n[3]
    var t4 = r.n[4]
    var t5 = r.n[5]
    var t6 = r.n[6]
    var t7 = r.n[7]
    var t8 = r.n[8]
    var t9 = r.n[9]

    /* Reduce t9 at the start so there will be at most a single carry from the first pass */
    let x:UInt32 = t9 >> 22; t9 &= 0x03FFFFF;

    /* The first pass ensures the magnitude is 1, ... */
    t0 += x * 0x3D1; t1 += (x << 6);
    t1 += (t0 >> 26); t0 &= 0x3FFFFFF;
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF;

    /* ... except for a possible carry at bit 22 of t9 (i.e. bit 256 of the field element) */
    VERIFY_CHECK(t9 >> 23 == 0);

    r.n[0] = t0; r.n[1] = t1; r.n[2] = t2; r.n[3] = t3; r.n[4] = t4;
    r.n[5] = t5; r.n[6] = t6; r.n[7] = t7; r.n[8] = t8; r.n[9] = t9;

#if VERIFY
    r->magnitude = 1;
    secp256k1_fe_verify(r);
#endif
}

func secp256k1_fe_normalize_var(_ r:inout secp256k1_fe) {
    var t0 = r.n[0]
    var t1 = r.n[1]
    var t2 = r.n[2]
    var t3 = r.n[3]
    var t4 = r.n[4]
    var t5 = r.n[5]
    var t6 = r.n[6]
    var t7 = r.n[7]
    var t8 = r.n[8]
    var t9 = r.n[9]

    /* Reduce t9 at the start so there will be at most a single carry from the first pass */
    var m:UInt32;
    var x:UInt32 = t9 >> 22; t9 &= 0x03FFFFF;

    /* The first pass ensures the magnitude is 1, ... */
    t0 += x * 0x3D1; t1 += (x << 6);
    t1 += (t0 >> 26); t0 &= 0x3FFFFFF;
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF; m = t2;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF; m &= t3;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF; m &= t4;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF; m &= t5;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF; m &= t6;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF; m &= t7;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF; m &= t8;

    /* ... except for a possible carry at bit 22 of t9 (i.e. bit 256 of the field element) */
    VERIFY_CHECK(t9 >> 23 == 0);

    /* At most a single final reduction is needed; check if the value is >= the field characteristic */
    x = (t9 >> 22) | ((t9 == 0x03FFFFF ? 1 : 0) & (m == 0x3FFFFFF ? 1 : 0)
        & ((t1 + 0x40 + ((t0 + 0x3D1) >> 26)) > 0x3FFFFFF ? 1 : 0));

    if (x != 0) {
        t0 += 0x3D1; t1 += (x << 6);
        t1 += (t0 >> 26); t0 &= 0x3FFFFFF;
        t2 += (t1 >> 26); t1 &= 0x3FFFFFF;
        t3 += (t2 >> 26); t2 &= 0x3FFFFFF;
        t4 += (t3 >> 26); t3 &= 0x3FFFFFF;
        t5 += (t4 >> 26); t4 &= 0x3FFFFFF;
        t6 += (t5 >> 26); t5 &= 0x3FFFFFF;
        t7 += (t6 >> 26); t6 &= 0x3FFFFFF;
        t8 += (t7 >> 26); t7 &= 0x3FFFFFF;
        t9 += (t8 >> 26); t8 &= 0x3FFFFFF;

        /* If t9 didn't carry to bit 22 already, then it should have after any final reduction */
        VERIFY_CHECK(t9 >> 22 == x);

        /* Mask off the possible multiple of 2^256 from the final reduction */
        t9 &= 0x03FFFFF;
    }

    r.n[0] = t0; r.n[1] = t1; r.n[2] = t2; r.n[3] = t3; r.n[4] = t4;
    r.n[5] = t5; r.n[6] = t6; r.n[7] = t7; r.n[8] = t8; r.n[9] = t9;

#if VERIFY
    r->magnitude = 1;
    r->normalized = 1;
    secp256k1_fe_verify(r);
#endif
}

// rがmod q で 0かどうかを返す
func secp256k1_fe_normalizes_to_zero(_ r: inout secp256k1_fe) -> Bool {
    var t0 = r.n[0]
    var t1 = r.n[1]
    var t2 = r.n[2]
    var t3 = r.n[3]
    var t4 = r.n[4]
    var t5 = r.n[5]
    var t6 = r.n[6]
    var t7 = r.n[7]
    var t8 = r.n[8]
    var t9 = r.n[9]

    /* z0 tracks a possible raw value of 0, z1 tracks a possible raw value of P */
    var z0:UInt32, z1:UInt32

    /* Reduce t9 at the start so there will be at most a single carry from the first pass */
    let x:UInt32 = t9 >> 22; t9 &= 0x03FFFFF

    /* The first pass ensures the magnitude is 1, ... */
    t0 += x * 0x3D1; t1 += (x << 6);
    t1 += (t0 >> 26); t0 &= 0x3FFFFFF; z0  = t0; z1  = t0 ^ 0x3D0;
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF; z0 |= t1; z1 &= t1 ^ 0x40;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF; z0 |= t2; z1 &= t2;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF; z0 |= t3; z1 &= t3;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF; z0 |= t4; z1 &= t4;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF; z0 |= t5; z1 &= t5;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF; z0 |= t6; z1 &= t6;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF; z0 |= t7; z1 &= t7;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF; z0 |= t8; z1 &= t8;
    z0 |= t9; z1 &= t9 ^ 0x3C00000;

    /* ... except for a possible carry at bit 22 of t9 (i.e. bit 256 of the field element) */
    VERIFY_CHECK(t9 >> 23 == 0);

    return (z0 == 0) || (z1 == 0x3FFFFFF);
}

// rがmod q で 0かどうかを返す
func secp256k1_fe_normalizes_to_zero_var(_ r: inout secp256k1_fe) -> Bool {
    var t0, t1, t2, t3, t4, t5, t6, t7, t8, t9: UInt32
    var z0, z1: UInt32
    var x: UInt32

    t0 = r.n[0];
    t9 = r.n[9];

    /* Reduce t9 at the start so there will be at most a single carry from the first pass */
    x = t9 >> 22;

    /* The first pass ensures the magnitude is 1, ... */
    t0 += x * 0x3D1;

    /* z0 tracks a possible raw value of 0, z1 tracks a possible raw value of P */
    z0 = t0 & 0x3FFFFFF;
    z1 = z0 ^ 0x3D0;

    /* Fast return path should catch the majority of cases */
    if ((z0 != 0) && (z1 != 0x3FFFFFF)) {
        return false
    }

    t1 = r.n[1];
    t2 = r.n[2];
    t3 = r.n[3];
    t4 = r.n[4];
    t5 = r.n[5];
    t6 = r.n[6];
    t7 = r.n[7];
    t8 = r.n[8];

    t9 &= 0x03FFFFF;
    t1 += (x << 6);

    t1 += (t0 >> 26);
    t2 += (t1 >> 26); t1 &= 0x3FFFFFF; z0 |= t1; z1 &= t1 ^ 0x40;
    t3 += (t2 >> 26); t2 &= 0x3FFFFFF; z0 |= t2; z1 &= t2;
    t4 += (t3 >> 26); t3 &= 0x3FFFFFF; z0 |= t3; z1 &= t3;
    t5 += (t4 >> 26); t4 &= 0x3FFFFFF; z0 |= t4; z1 &= t4;
    t6 += (t5 >> 26); t5 &= 0x3FFFFFF; z0 |= t5; z1 &= t5;
    t7 += (t6 >> 26); t6 &= 0x3FFFFFF; z0 |= t6; z1 &= t6;
    t8 += (t7 >> 26); t7 &= 0x3FFFFFF; z0 |= t7; z1 &= t7;
    t9 += (t8 >> 26); t8 &= 0x3FFFFFF; z0 |= t8; z1 &= t8;
    z0 |= t9; z1 &= t9 ^ 0x3C00000;

    /* ... except for a possible carry at bit 22 of t9 (i.e. bit 256 of the field element) */
    VERIFY_CHECK(t9 >> 23 == 0);

    return (z0 == 0) || (z1 == 0x3FFFFFF);
}

// rに int aを設定する
func secp256k1_fe_set_int(_ r: inout secp256k1_fe, _ a: UInt32) {
    r.n[0] = a
    for i in 1...9 {
        r.n[i] = 0
    }
#if VERIFY
    r->magnitude = 1;
    r->normalized = 1;
    secp256k1_fe_verify(r);
#endif
}

// aが0かどうかを返す
func secp256k1_fe_is_zero(_ a: secp256k1_fe) -> Bool {
    let t = a.n
#if VERIFY
    //VERIFY_CHECK(a->normalized);
    secp256k1_fe_verify(a);
#endif
    return (t[0] | t[1] | t[2] | t[3] | t[4] | t[5] | t[6] | t[7] | t[8] | t[9]) == 0;
}

// aが奇数かどうかを返す
func secp256k1_fe_is_odd(_ a: secp256k1_fe) -> Bool {
#if VERIFY
    //VERIFY_CHECK(a->normalized);
    secp256k1_fe_verify(a);
#endif
    return (a.n[0] & 1) != 0
}

// aに0を設定する
func secp256k1_fe_clear(_ a: inout secp256k1_fe) {
#if VERIFY
    a->magnitude = 0;
    a->normalized = 1;
#endif
    for i in 0..<10 {
        a.n[i] = 0
    }
}

// ノーマライズされたa, bを比較した結果-1, 0, 1を返す
func secp256k1_fe_cmp_var(_ a:secp256k1_fe, _ b:secp256k1_fe) -> Int {
#if VERIFY
    //VERIFY_CHECK(a->normalized);
    //VERIFY_CHECK(b->normalized);
    secp256k1_fe_verify(a); // verify magnitude
    secp256k1_fe_verify(b); // verify magnitude
#endif
    for i in stride(from: 9, through: 0, by: -1) {
        if (a.n[i] > b.n[i]) {
            return 1;
        }
        if (a.n[i] < b.n[i]) {
            return -1;
        }
    }
    return 0;
}

// r = a
// r: secp256k1_fe
// a: uint8_t[32]
func secp256k1_fe_set_b32(_ r:inout secp256k1_fe, _ a:[UInt8]) -> Bool {
    assert( a.count >= 32)
    let a = a.map({return UInt32($0)})
    r.n[0] = a[31] | (a[30] << 8) | (a[29] << 16) | ((a[28] & 0x3) << 24)
    r.n[1] = ((a[28] >> 2) & 0x3f) | (a[27] << 6) | (a[26] << 14) | ((a[25] & 0xf) << 22);
    r.n[2] = ((a[25] >> 4) & 0xf) | (a[24] << 4) | (a[23] << 12) | ((a[22] & 0x3f) << 20);
    r.n[3] = ((a[22] >> 6) & 0x3) | (a[21] << 2) | (a[20] << 10) | (a[19] << 18);
    r.n[4] = a[18] | (a[17] << 8) | (a[16] << 16) | ((a[15] & 0x3) << 24);
    r.n[5] = ((a[15] >> 2) & 0x3f) | (a[14] << 6) | (a[13] << 14) | ((a[12] & 0xf) << 22);
    r.n[6] = ((a[12] >> 4) & 0xf) | (a[11] << 4) | (a[10] << 12) | ((a[9] & 0x3f) << 20);
    r.n[7] = ((a[9] >> 6) & 0x3) | (a[8] << 2) | (a[7] << 10) | (a[6] << 18);
    r.n[8] = a[5] | (a[4] << 8) | (a[3] << 16) | ((a[2] & 0x3) << 24);
    r.n[9] = ((a[2] >> 2) & 0x3f) | (a[1] << 6) | (a[0] << 14);

    if (r.n[9] == 0x3FFFFF && (r.n[8] & r.n[7] & r.n[6] & r.n[5] & r.n[4] & r.n[3] & r.n[2]) == 0x3FFFFFF && (r.n[1] + 0x40 + ((r.n[0] + 0x3D1) >> 26)) > 0x3FFFFFF) {
        return false;
    }
#if VERIFY
    r->magnitude = 1;
    r->normalized = 1;
    secp256k1_fe_verify(r);
#endif
    return true;
}

/** Convert a field element to a 32-byte big endian value. Requires the input to be normalized */
// r = a
// r: uint8_t[32]
// a: secp256k1_fe
func secp256k1_fe_get_b32(_ r:inout [UInt8], _ a:secp256k1_fe) {
#if VERIFY
    //VERIFY_CHECK(a->normalized);
    secp256k1_fe_verify(a);
#endif
    r[0] = UInt8((a.n[9] >> 14) & 0xff)
    r[1] = UInt8((a.n[9] >> 6) & 0xff)
    r[2] = UInt8(((a.n[9] & 0x3F) << 2) | ((a.n[8] >> 24) & 0x3))
    r[3] = UInt8((a.n[8] >> 16) & 0xff)
    r[4] = UInt8((a.n[8] >> 8) & 0xff);
    r[5] = UInt8(a.n[8] & 0xff);
    r[6] = UInt8((a.n[7] >> 18) & 0xff);
    r[7] = UInt8((a.n[7] >> 10) & 0xff);
    r[8] = UInt8((a.n[7] >> 2) & 0xff);
    r[9] = UInt8(((a.n[7] & 0x3) << 6) | ((a.n[6] >> 20) & 0x3f));
    r[10] = UInt8((a.n[6] >> 12) & 0xff);
    r[11] = UInt8((a.n[6] >> 4) & 0xff);
    r[12] = UInt8(((a.n[6] & 0xf) << 4) | ((a.n[5] >> 22) & 0xf));
    r[13] = UInt8((a.n[5] >> 14) & 0xff);
    r[14] = UInt8((a.n[5] >> 6) & 0xff);
    r[15] = UInt8(((a.n[5] & 0x3f) << 2) | ((a.n[4] >> 24) & 0x3));
    r[16] = UInt8((a.n[4] >> 16) & 0xff);
    r[17] = UInt8((a.n[4] >> 8) & 0xff);
    r[18] = UInt8(a.n[4] & 0xff);
    r[19] = UInt8((a.n[3] >> 18) & 0xff);
    r[20] = UInt8((a.n[3] >> 10) & 0xff);
    r[21] = UInt8((a.n[3] >> 2) & 0xff);
    r[22] = UInt8(((a.n[3] & 0x3) << 6) | ((a.n[2] >> 20) & 0x3f));
    r[23] = UInt8((a.n[2] >> 12) & 0xff);
    r[24] = UInt8((a.n[2] >> 4) & 0xff);
    r[25] = UInt8(((a.n[2] & 0xf) << 4) | ((a.n[1] >> 22) & 0xf));
    r[26] = UInt8((a.n[1] >> 14) & 0xff);
    r[27] = UInt8((a.n[1] >> 6) & 0xff);
    r[28] = UInt8(((a.n[1] & 0x3f) << 2) | ((a.n[0] >> 24) & 0x3));
    r[29] = UInt8((a.n[0] >> 16) & 0xff);
    r[30] = UInt8((a.n[0] >> 8) & 0xff);
    r[31] = UInt8(a.n[0] & 0xff);
}

// -aを計算する
// mには元々の大きさmagnitude以上の値を設定する
func secp256k1_fe_negate(_ r:inout secp256k1_fe, _ a:secp256k1_fe, _ m:UInt32) {
#if VERIFY
    //VERIFY_CHECK(a->magnitude <= m);
    secp256k1_fe_verify(a);
#endif
    r.n[0] = 0x3FFFC2F * 2 * (m + 1) - a.n[0];
    r.n[1] = 0x3FFFFBF * 2 * (m + 1) - a.n[1];
    r.n[2] = 0x3FFFFFF * 2 * (m + 1) - a.n[2];
    r.n[3] = 0x3FFFFFF * 2 * (m + 1) - a.n[3];
    r.n[4] = 0x3FFFFFF * 2 * (m + 1) - a.n[4];
    r.n[5] = 0x3FFFFFF * 2 * (m + 1) - a.n[5];
    r.n[6] = 0x3FFFFFF * 2 * (m + 1) - a.n[6];
    r.n[7] = 0x3FFFFFF * 2 * (m + 1) - a.n[7];
    r.n[8] = 0x3FFFFFF * 2 * (m + 1) - a.n[8];
    r.n[9] = 0x03FFFFF * 2 * (m + 1) - a.n[9];
#if VERIFY
    r->magnitude = m + 1;
    r->normalized = 0;
    secp256k1_fe_verify(r);
#endif
}

// r *= a
// @param r:secp256k1_fe
// @param a:int
func secp256k1_fe_mul_int(_ r:inout secp256k1_fe, _ a: UInt32) {
    for i in 0..<10 {
        r.n[i] *= a
    }
#if VERIFY
    r->magnitude *= a;
    r->normalized = 0;
    secp256k1_fe_verify(r);
#endif
}

// r += a
// @param r:secp256k1_fe
// @param a:secp256k1_fe
func secp256k1_fe_add(_ r: inout secp256k1_fe, _ a:secp256k1_fe) {
#if VERIFY
    secp256k1_fe_verify(a);
#endif
    for i in 0..<10 {
        r.n[i] += a.n[i];
    }
#if VERIFY
    r->magnitude += a->magnitude;
    r->normalized = 0;
    secp256k1_fe_verify(r);
#endif
}

func VERIFY_BITS<T:UnsignedInteger>(_ x:T, _ n:UInt){
#if VERIFY
    VERIFY_CHECK((x >> n) == 0)
#endif
}

// r = a * b
// @param r: UInt32 [10]
// @param a: UInt32 [10]
// @param b: UInt32 [10]
func secp256k1_fe_mul_inner(_ r:inout [UInt32], _ a:[UInt32], _ b:[UInt32] /* size 10 */) {
    var c, d: UInt64
    var u0, u1, u2, u3, u4, u5, u6, u7, u8: UInt64
    var t9, t1, t0, t2, t3, t4, t5, t6, t7: UInt64
    let M:UInt64 = 0x3FFFFFF
    let R0:UInt64 = 0x3D10
    let R1:UInt64 = 0x400;

    VERIFY_BITS(a[0], 30);
    VERIFY_BITS(a[1], 30);
    VERIFY_BITS(a[2], 30);
    VERIFY_BITS(a[3], 30);
    VERIFY_BITS(a[4], 30);
    VERIFY_BITS(a[5], 30);
    VERIFY_BITS(a[6], 30);
    VERIFY_BITS(a[7], 30);
    VERIFY_BITS(a[8], 30);
    VERIFY_BITS(a[9], 26);
    VERIFY_BITS(b[0], 30);
    VERIFY_BITS(b[1], 30);
    VERIFY_BITS(b[2], 30);
    VERIFY_BITS(b[3], 30);
    VERIFY_BITS(b[4], 30);
    VERIFY_BITS(b[5], 30);
    VERIFY_BITS(b[6], 30);
    VERIFY_BITS(b[7], 30);
    VERIFY_BITS(b[8], 30);
    VERIFY_BITS(b[9], 26);

    /** [... a b c] is a shorthand for ... + a<<52 + b<<26 + c<<0 mod n.
     *  px is a shorthand for sum(a[i]*b[x-i], i=0..x).
     *  Note that [x 0 0 0 0 0 0 0 0 0 0] = [x*R1 x*R0].
     */

    d = UInt64(a[0]) * UInt64(b[9])
    d += UInt64(a[1]) * UInt64(b[8])
    d += UInt64(a[2]) * UInt64(b[7])
    d += UInt64(a[3]) * UInt64(b[6])
    d += UInt64(a[4]) * UInt64(b[5])
    d += UInt64(a[5]) * UInt64(b[4])
    d += UInt64(a[6]) * UInt64(b[3])
    d += UInt64(a[7]) * UInt64(b[2])
    d += UInt64(a[8]) * UInt64(b[1])
    d += UInt64(a[9]) * UInt64(b[0])
    /* VERIFY_BITS(d, 64); */
    /* [d 0 0 0 0 0 0 0 0 0] = [p9 0 0 0 0 0 0 0 0 0] */
    t9 = d & M; d >>= 26;
    VERIFY_BITS(t9, 26);
    VERIFY_BITS(d, 38);
    /* [d t9 0 0 0 0 0 0 0 0 0] = [p9 0 0 0 0 0 0 0 0 0] */

    c  = UInt64(a[0]) * UInt64(b[0])
    VERIFY_BITS(c, 60);
    /* [d t9 0 0 0 0 0 0 0 0 c] = [p9 0 0 0 0 0 0 0 0 p0] */
    d += UInt64(a[1]) * UInt64(b[9])
    d += UInt64(a[2]) * UInt64(b[8])
    d += UInt64(a[3]) * UInt64(b[7])
    d += UInt64(a[4]) * UInt64(b[6])
    d += UInt64(a[5]) * UInt64(b[5])
    d += UInt64(a[6]) * UInt64(b[4])
    d += UInt64(a[7]) * UInt64(b[3])
    d += UInt64(a[8]) * UInt64(b[2])
    d += UInt64(a[9]) * UInt64(b[1])
    VERIFY_BITS(d, 63);
    /* [d t9 0 0 0 0 0 0 0 0 c] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    u0 = d & M; d >>= 26; c += u0 * R0;
    VERIFY_BITS(u0, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 61);
    /* [d u0 t9 0 0 0 0 0 0 0 0 c-u0*R0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    t0 = c & M; c >>= 26; c += u0 * R1;
    VERIFY_BITS(t0, 26);
    VERIFY_BITS(c, 37);
    /* [d u0 t9 0 0 0 0 0 0 0 c-u0*R1 t0-u0*R0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */

    c += UInt64(a[0]) * UInt64(b[1])
        + UInt64(a[1]) * UInt64(b[0])
    VERIFY_BITS(c, 62);
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p10 p9 0 0 0 0 0 0 0 p1 p0] */
    d += UInt64(a[2]) * UInt64(b[9])
    d += UInt64(a[3]) * UInt64(b[8])
    d += UInt64(a[4]) * UInt64(b[7])
    d += UInt64(a[5]) * UInt64(b[6])
    d += UInt64(a[6]) * UInt64(b[5])
    d += UInt64(a[7]) * UInt64(b[4])
    d += UInt64(a[8]) * UInt64(b[3])
    d += UInt64(a[9]) * UInt64(b[2])
    VERIFY_BITS(d, 63);
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    u1 = d & M; d >>= 26; c += u1 * R0;
    VERIFY_BITS(u1, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 63);
    /* [d u1 0 t9 0 0 0 0 0 0 0 c-u1*R0 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    t1 = c & M; c >>= 26; c += u1 * R1;
    VERIFY_BITS(t1, 26);
    VERIFY_BITS(c, 38);
    /* [d u1 0 t9 0 0 0 0 0 0 c-u1*R1 t1-u1*R0 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[2])
        + UInt64(a[1]) * UInt64(b[1])
        + UInt64(a[2]) * UInt64(b[0]);
    VERIFY_BITS(c, 62);
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    d += UInt64(a[3]) * UInt64(b[9])
    d += UInt64(a[4]) * UInt64(b[8])
    d += UInt64(a[5]) * UInt64(b[7])
    d += UInt64(a[6]) * UInt64(b[6])
    d += UInt64(a[7]) * UInt64(b[5])
    d += UInt64(a[8]) * UInt64(b[4])
    d += UInt64(a[9]) * UInt64(b[3]);
    VERIFY_BITS(d, 63);
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    u2 = d & M; d >>= 26; c += u2 * R0;
    VERIFY_BITS(u2, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 63);
    /* [d u2 0 0 t9 0 0 0 0 0 0 c-u2*R0 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    t2 = c & M; c >>= 26; c += u2 * R1;
    VERIFY_BITS(t2, 26);
    VERIFY_BITS(c, 38);
    /* [d u2 0 0 t9 0 0 0 0 0 c-u2*R1 t2-u2*R0 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[3])
        + UInt64(a[1]) * UInt64(b[2])
        + UInt64(a[2]) * UInt64(b[1])
        + UInt64(a[3]) * UInt64(b[0]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    d += UInt64(a[4]) * UInt64(b[9])
    d += UInt64(a[5]) * UInt64(b[8])
    d += UInt64(a[6]) * UInt64(b[7])
    d += UInt64(a[7]) * UInt64(b[6])
    d += UInt64(a[8]) * UInt64(b[5])
    d += UInt64(a[9]) * UInt64(b[4]);
    VERIFY_BITS(d, 63);
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    u3 = d & M; d >>= 26; c += u3 * R0;
    VERIFY_BITS(u3, 26);
    VERIFY_BITS(d, 37);
    /* VERIFY_BITS(c, 64); */
    /* [d u3 0 0 0 t9 0 0 0 0 0 c-u3*R0 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    t3 = c & M; c >>= 26; c += u3 * R1;
    VERIFY_BITS(t3, 26);
    VERIFY_BITS(c, 39);
    /* [d u3 0 0 0 t9 0 0 0 0 c-u3*R1 t3-u3*R0 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[4])
    c += UInt64(a[1]) * UInt64(b[3])
    c += UInt64(a[2]) * UInt64(b[2])
    c += UInt64(a[3]) * UInt64(b[1])
    c += UInt64(a[4]) * UInt64(b[0]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    d += UInt64(a[5]) * UInt64(b[9])
        + UInt64(a[6]) * UInt64(b[8])
        + UInt64(a[7]) * UInt64(b[7])
        + UInt64(a[8]) * UInt64(b[6])
        + UInt64(a[9]) * UInt64(b[5])
    VERIFY_BITS(d, 62);
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    u4 = d & M; d >>= 26; c += u4 * R0;
    VERIFY_BITS(u4, 26);
    VERIFY_BITS(d, 36);
    /* VERIFY_BITS(c, 64); */
    /* [d u4 0 0 0 0 t9 0 0 0 0 c-u4*R0 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    t4 = c & M; c >>= 26; c += u4 * R1;
    VERIFY_BITS(t4, 26);
    VERIFY_BITS(c, 39);
    /* [d u4 0 0 0 0 t9 0 0 0 c-u4*R1 t4-u4*R0 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[5])
    c += UInt64(a[1]) * UInt64(b[4])
    c += UInt64(a[2]) * UInt64(b[3])
    c += UInt64(a[3]) * UInt64(b[2])
    c += UInt64(a[4]) * UInt64(b[1])
    c += UInt64(a[5]) * UInt64(b[0]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[6]) * UInt64(b[9])
    d += UInt64(a[7]) * UInt64(b[8])
    d += UInt64(a[8]) * UInt64(b[7])
    d += UInt64(a[9]) * UInt64(b[6]);
    VERIFY_BITS(d, 62);
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    u5 = d & M; d >>= 26; c += u5 * R0;
    VERIFY_BITS(u5, 26);
    VERIFY_BITS(d, 36);
    /* VERIFY_BITS(c, 64); */
    /* [d u5 0 0 0 0 0 t9 0 0 0 c-u5*R0 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    t5 = c & M; c >>= 26; c += u5 * R1;
    VERIFY_BITS(t5, 26);
    VERIFY_BITS(c, 39);
    /* [d u5 0 0 0 0 0 t9 0 0 c-u5*R1 t5-u5*R0 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[6])
    c += UInt64(a[1]) * UInt64(b[5])
    c += UInt64(a[2]) * UInt64(b[4])
    c += UInt64(a[3]) * UInt64(b[3])
    c += UInt64(a[4]) * UInt64(b[2])
    c += UInt64(a[5]) * UInt64(b[1])
    c += UInt64(a[6]) * UInt64(b[0]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[7]) * UInt64(b[9])
        + UInt64(a[8]) * UInt64(b[8])
        + UInt64(a[9]) * UInt64(b[7]);
    VERIFY_BITS(d, 61);
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    u6 = d & M; d >>= 26; c += u6 * R0;
    VERIFY_BITS(u6, 26);
    VERIFY_BITS(d, 35);
    /* VERIFY_BITS(c, 64); */
    /* [d u6 0 0 0 0 0 0 t9 0 0 c-u6*R0 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    t6 = c & M; c >>= 26; c += u6 * R1;
    VERIFY_BITS(t6, 26);
    VERIFY_BITS(c, 39);
    /* [d u6 0 0 0 0 0 0 t9 0 c-u6*R1 t6-u6*R0 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[7])
    c += UInt64(a[1]) * UInt64(b[6])
    c += UInt64(a[2]) * UInt64(b[5])
    c += UInt64(a[3]) * UInt64(b[4])
    c += UInt64(a[4]) * UInt64(b[3])
    c += UInt64(a[5]) * UInt64(b[2])
    c += UInt64(a[6]) * UInt64(b[1])
    c += UInt64(a[7]) * UInt64(b[0]);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x8000_007C_0000_0007 as UInt64);
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[8]) * UInt64(b[9])
        + UInt64(a[9]) * UInt64(b[8]);
    VERIFY_BITS(d, 58);
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    u7 = d & M; d >>= 26; c += u7 * R0;
    VERIFY_BITS(u7, 26);
    VERIFY_BITS(d, 32);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x8000_0170_3FFF_C2F7 as UInt64)
    /* [d u7 0 0 0 0 0 0 0 t9 0 c-u7*R0 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    t7 = c & M; c >>= 26; c += u7 * R1;
    VERIFY_BITS(t7, 26);
    VERIFY_BITS(c, 38);
    /* [d u7 0 0 0 0 0 0 0 t9 c-u7*R1 t7-u7*R0 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * UInt64(b[8])
    c += UInt64(a[1]) * UInt64(b[7])
    c += UInt64(a[2]) * UInt64(b[6])
    c += UInt64(a[3]) * UInt64(b[5])
    c += UInt64(a[4]) * UInt64(b[4])
    c += UInt64(a[5]) * UInt64(b[3])
    c += UInt64(a[6]) * UInt64(b[2])
    c += UInt64(a[7]) * UInt64(b[1])
    c += UInt64(a[8]) * UInt64(b[0]);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x9000_007B_8000_0008 as UInt64)
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[9]) * UInt64(b[9]);
    VERIFY_BITS(d, 57);
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    u8 = d & M; d >>= 26; c += u8 * R0;
    VERIFY_BITS(u8, 26);
    VERIFY_BITS(d, 31);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x9000_016F_BFFF_C2F8 as UInt64)
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 t4 t3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    r[3] = UInt32(t3);
    VERIFY_BITS(r[3], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 t4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[4] = UInt32(t4);
    VERIFY_BITS(r[4], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[5] = UInt32(t5);
    VERIFY_BITS(r[5], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[6] = UInt32(t6);
    VERIFY_BITS(r[6], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[7] = UInt32(t7);
    VERIFY_BITS(r[7], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    r[8] = UInt32(c & M); c >>= 26; c += u8 * R1;
    VERIFY_BITS(r[8], 26);
    VERIFY_BITS(c, 39);
    /* [d u8 0 0 0 0 0 0 0 0 t9+c-u8*R1 r8-u8*R0 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 0 0 t9+c r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    c   += d * R0 + t9;
    VERIFY_BITS(c, 45);
    /* [d 0 0 0 0 0 0 0 0 0 c-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[9] = UInt32(c & (M >> 4)); c >>= 22; c += d * (R1 << 4);
    VERIFY_BITS(r[9], 22);
    VERIFY_BITS(c, 46);
    /* [d 0 0 0 0 0 0 0 0 r9+((c-d*R1<<4)<<22)-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 -d*R1 r9+(c<<22)-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    d    = c * (R0 >> 4) + t0;
    VERIFY_BITS(d, 56);
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1 d-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[0] = UInt32(d & M); d >>= 26;
    VERIFY_BITS(r[0], 26);
    VERIFY_BITS(d, 30);
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1+d r0-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d   += c * (R1 >> 4) + t1;
    VERIFY_BITS(d, 53);
    VERIFY_CHECK(d <= 0x10000003FFFFBF)
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 d-c*R1>>4 r0-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [r9 r8 r7 r6 r5 r4 r3 t2 d r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[1] = UInt32(d & M); d >>= 26;
    VERIFY_BITS(r[1], 26);
    VERIFY_BITS(d, 27);
    VERIFY_CHECK(d <= 0x4000000)
    /* [r9 r8 r7 r6 r5 r4 r3 t2+d r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d   += t2;
    VERIFY_BITS(d, 27);
    /* [r9 r8 r7 r6 r5 r4 r3 d r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[2] = UInt32(d);
    VERIFY_BITS(r[2], 27);
    /* [r9 r8 r7 r6 r5 r4 r3 r2 r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
}

// r = root a
// 平方剰余
// r:uint32_t[10]
// a:uint32_t[10]
func secp256k1_fe_sqr_inner(_ r:inout [UInt32], _ a:[UInt32]) {
    var c, d:UInt64
    var u0, u1, u2, u3, u4, u5, u6, u7, u8:UInt64
    var t9, t0, t1, t2, t3, t4, t5, t6, t7:UInt32
    let M:UInt64 = 0x3FFFFFF
    let R0:UInt64 = 0x3D10
    let R1:UInt64 = 0x400;

    VERIFY_BITS(a[0], 30);
    VERIFY_BITS(a[1], 30);
    VERIFY_BITS(a[2], 30);
    VERIFY_BITS(a[3], 30);
    VERIFY_BITS(a[4], 30);
    VERIFY_BITS(a[5], 30);
    VERIFY_BITS(a[6], 30);
    VERIFY_BITS(a[7], 30);
    VERIFY_BITS(a[8], 30);
    VERIFY_BITS(a[9], 26);

    /** [... a b c] is a shorthand for ... + a<<52 + b<<26 + c<<0 mod n.
     *  px is a shorthand for sum(a[i]*a[x-i], i=0..x).
     *  Note that [x 0 0 0 0 0 0 0 0 0 0] = [x*R1 x*R0].
     */

    d  = UInt64(a[0]) * 2 * UInt64(a[9])
    d += UInt64(a[1]) * 2 * UInt64(a[8])
    d += UInt64(a[2]) * 2 * UInt64(a[7])
    d += UInt64(a[3]) * 2 * UInt64(a[6])
    d += UInt64(a[4]) * 2 * UInt64(a[5])
    /* VERIFY_BITS(d, 64); */
    /* [d 0 0 0 0 0 0 0 0 0] = [p9 0 0 0 0 0 0 0 0 0] */
    t9 = UInt32(d & M); d >>= 26;
    VERIFY_BITS(t9, 26);
    VERIFY_BITS(d, 38);
    /* [d t9 0 0 0 0 0 0 0 0 0] = [p9 0 0 0 0 0 0 0 0 0] */

    c  = UInt64(a[0]) * UInt64(a[0])
    VERIFY_BITS(c, 60);
    /* [d t9 0 0 0 0 0 0 0 0 c] = [p9 0 0 0 0 0 0 0 0 p0] */
    d += UInt64(a[1]) * 2 * UInt64(a[9])
    d += UInt64(a[2]) * 2 * UInt64(a[8])
    d += UInt64(a[3]) * 2 * UInt64(a[7])
    d += UInt64(a[4]) * 2 * UInt64(a[6])
    d += UInt64(a[5]) * UInt64(a[5])
    VERIFY_BITS(d, 63)
    /* [d t9 0 0 0 0 0 0 0 0 c] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    u0 = d & M; d >>= 26; c += u0 * R0;
    VERIFY_BITS(u0, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 61);
    /* [d u0 t9 0 0 0 0 0 0 0 0 c-u0*R0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    t0 = UInt32(c & M); c >>= 26; c += u0 * R1;
    VERIFY_BITS(t0, 26);
    VERIFY_BITS(c, 37);
    /* [d u0 t9 0 0 0 0 0 0 0 c-u0*R1 t0-u0*R0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p10 p9 0 0 0 0 0 0 0 0 p0] */

    c += UInt64(a[0]*2) * UInt64(a[1]);
    VERIFY_BITS(c, 62);
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p10 p9 0 0 0 0 0 0 0 p1 p0] */
    d += UInt64(a[2]) * 2 * UInt64(a[9])
    d += UInt64(a[3]) * 2 * UInt64(a[8])
    d += UInt64(a[4]) * 2 * UInt64(a[7])
    d += UInt64(a[5]) * 2 * UInt64(a[6])
    VERIFY_BITS(d, 63);
    /* [d 0 t9 0 0 0 0 0 0 0 c t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    u1 = d & M; d >>= 26; c += u1 * R0;
    VERIFY_BITS(u1, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 63);
    /* [d u1 0 t9 0 0 0 0 0 0 0 c-u1*R0 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    t1 = UInt32(c & M); c >>= 26; c += u1 * R1;
    VERIFY_BITS(t1, 26);
    VERIFY_BITS(c, 38);
    /* [d u1 0 t9 0 0 0 0 0 0 c-u1*R1 t1-u1*R0 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p11 p10 p9 0 0 0 0 0 0 0 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[2])
    + UInt64(a[1]) * UInt64(a[1]);
    VERIFY_BITS(c, 62);
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    d += UInt64(a[3]) * 2 * UInt64(a[9])
    d += UInt64(a[4]) * 2 * UInt64(a[8])
    d += UInt64(a[5]) * 2 * UInt64(a[7])
    d += UInt64(a[6]) * UInt64(a[6]);
    VERIFY_BITS(d, 63);
    /* [d 0 0 t9 0 0 0 0 0 0 c t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    u2 = d & M; d >>= 26; c += u2 * R0;
    VERIFY_BITS(u2, 26);
    VERIFY_BITS(d, 37);
    VERIFY_BITS(c, 63);
    /* [d u2 0 0 t9 0 0 0 0 0 0 c-u2*R0 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    t2 = UInt32(c & M); c >>= 26; c += u2 * R1;
    VERIFY_BITS(t2, 26);
    VERIFY_BITS(c, 38);
    /* [d u2 0 0 t9 0 0 0 0 0 c-u2*R1 t2-u2*R0 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 0 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[3])
    c += UInt64(a[1]) * 2 * UInt64(a[2]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    d += UInt64(a[4]) * 2 * UInt64(a[9])
    d += UInt64(a[5]) * 2 * UInt64(a[8])
    d += UInt64(a[6]) * 2 * UInt64(a[7])
    VERIFY_BITS(d, 63);
    /* [d 0 0 0 t9 0 0 0 0 0 c t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    u3 = d & M; d >>= 26; c += u3 * R0;
    VERIFY_BITS(u3, 26);
    VERIFY_BITS(d, 37);
    /* VERIFY_BITS(c, 64); */
    /* [d u3 0 0 0 t9 0 0 0 0 0 c-u3*R0 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    t3 = UInt32(c & M); c >>= 26; c += u3 * R1;
    VERIFY_BITS(t3, 26);
    VERIFY_BITS(c, 39);
    /* [d u3 0 0 0 t9 0 0 0 0 c-u3*R1 t3-u3*R0 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 0 p3 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[4])
    c += UInt64(a[1]) * 2 * UInt64(a[3])
    c += UInt64(a[2]) * UInt64(a[2]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    d += UInt64(a[5]) * 2 * UInt64(a[9])
    d += UInt64(a[6]) * 2 * UInt64(a[8])
    d += UInt64(a[7]) * UInt64(a[7]);
    VERIFY_BITS(d, 62);
    /* [d 0 0 0 0 t9 0 0 0 0 c t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    u4 = d & M; d >>= 26; c += u4 * R0;
    VERIFY_BITS(u4, 26);
    VERIFY_BITS(d, 36);
    /* VERIFY_BITS(c, 64); */
    /* [d u4 0 0 0 0 t9 0 0 0 0 c-u4*R0 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    t4 = UInt32(c & M); c >>= 26; c += u4 * R1;
    VERIFY_BITS(t4, 26);
    VERIFY_BITS(c, 39);
    /* [d u4 0 0 0 0 t9 0 0 0 c-u4*R1 t4-u4*R0 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 0 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[5])
    c += UInt64(a[1]) * 2 * UInt64(a[4])
    c += UInt64(a[2]) * 2 * UInt64(a[3]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[6]*2) * UInt64(a[9])
        + UInt64(a[7]*2) * UInt64(a[8]);
    VERIFY_BITS(d, 62);
    /* [d 0 0 0 0 0 t9 0 0 0 c t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    u5 = d & M; d >>= 26; c += u5 * R0;
    VERIFY_BITS(u5, 26);
    VERIFY_BITS(d, 36);
    /* VERIFY_BITS(c, 64); */
    /* [d u5 0 0 0 0 0 t9 0 0 0 c-u5*R0 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    t5 = UInt32(c & M); c >>= 26; c += u5 * R1;
    VERIFY_BITS(t5, 26);
    VERIFY_BITS(c, 39);
    /* [d u5 0 0 0 0 0 t9 0 0 c-u5*R1 t5-u5*R0 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 0 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[6])
        + UInt64(a[1]) * 2 * UInt64(a[5])
        + UInt64(a[2]) * 2 * UInt64(a[4])
        + UInt64(a[3]) * UInt64(a[3]);
    VERIFY_BITS(c, 63);
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[7]) * 2 * UInt64(a[9])
        + UInt64(a[8]) * UInt64(a[8]);
    VERIFY_BITS(d, 61);
    /* [d 0 0 0 0 0 0 t9 0 0 c t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    u6 = d & M; d >>= 26; c += u6 * R0;
    VERIFY_BITS(u6, 26);
    VERIFY_BITS(d, 35);
    /* VERIFY_BITS(c, 64); */
    /* [d u6 0 0 0 0 0 0 t9 0 0 c-u6*R0 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    t6 = UInt32(c & M); c >>= 26; c += u6 * R1;
    VERIFY_BITS(t6, 26);
    VERIFY_BITS(c, 39);
    /* [d u6 0 0 0 0 0 0 t9 0 c-u6*R1 t6-u6*R0 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 0 p6 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[7])
    c += UInt64(a[1]) * 2 * UInt64(a[6])
    c += UInt64(a[2]) * 2 * UInt64(a[5])
    c += UInt64(a[3]) * 2 * UInt64(a[4]);
    VERIFY_BITS(c, 64)
    VERIFY_CHECK(c <= 0x8000_007C_0000_0007 as UInt64)
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[8]*2) * UInt64(a[9]);
    VERIFY_BITS(d, 58);
    /* [d 0 0 0 0 0 0 0 t9 0 c t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    u7 = d & M; d >>= 26; c += u7 * R0;
    VERIFY_BITS(u7, 26);
    VERIFY_BITS(d, 32);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x8000_0170_3FFF_C2F7 as UInt64)
    /* [d u7 0 0 0 0 0 0 0 t9 0 c-u7*R0 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    t7 = UInt32(c & M); c >>= 26; c += u7 * R1;
    VERIFY_BITS(t7, 26);
    VERIFY_BITS(c, 38);
    /* [d u7 0 0 0 0 0 0 0 t9 c-u7*R1 t7-u7*R0 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 0 p7 p6 p5 p4 p3 p2 p1 p0] */

    c += UInt64(a[0]) * 2 * UInt64(a[8])
    c += UInt64(a[1]) * 2 * UInt64(a[7])
    c += UInt64(a[2]) * 2 * UInt64(a[6])
    c += UInt64(a[3]) * 2 * UInt64(a[5])
    c += UInt64(a[4]) * UInt64(a[4]);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x9000_007B_8000_0008 as UInt64)
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d += UInt64(a[9]) * UInt64(a[9]);
    VERIFY_BITS(d, 57);
    /* [d 0 0 0 0 0 0 0 0 t9 c t7 t6 t5 t4 t3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    u8 = d & M; d >>= 26; c += u8 * R0;
    VERIFY_BITS(u8, 26);
    VERIFY_BITS(d, 31);
    VERIFY_BITS(c, 64);
    VERIFY_CHECK(c <= 0x9000_016F_BFFF_C2F8 as UInt64)
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 t4 t3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    r[3] = t3;
    VERIFY_BITS(r[3], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 t4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[4] = t4;
    VERIFY_BITS(r[4], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 t5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[5] = t5;
    VERIFY_BITS(r[5], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 t6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[6] = t6;
    VERIFY_BITS(r[6], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 t7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[7] = t7;
    VERIFY_BITS(r[7], 26);
    /* [d u8 0 0 0 0 0 0 0 0 t9 c-u8*R0 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    r[8] = UInt32(c & M); c >>= 26; c += u8 * R1;
    VERIFY_BITS(r[8], 26);
    VERIFY_BITS(c, 39);
    /* [d u8 0 0 0 0 0 0 0 0 t9+c-u8*R1 r8-u8*R0 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 0 0 t9+c r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    c   += d * R0 + UInt64(t9);
    VERIFY_BITS(c, 45);
    /* [d 0 0 0 0 0 0 0 0 0 c-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[9] = UInt32(c & (M >> 4)); c >>= 22; c += d * (R1 << 4);
    VERIFY_BITS(r[9], 22);
    VERIFY_BITS(c, 46);
    /* [d 0 0 0 0 0 0 0 0 r9+((c-d*R1<<4)<<22)-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [d 0 0 0 0 0 0 0 -d*R1 r9+(c<<22)-d*R0 r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1 t0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */

    d    = c * (R0 >> 4) + UInt64(t0);
    VERIFY_BITS(d, 56);
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1 d-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[0] = UInt32(d & M); d >>= 26;
    VERIFY_BITS(r[0], 26);
    VERIFY_BITS(d, 30);
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 t1+d r0-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d   += c * (R1 >> 4) + UInt64(t1);
    VERIFY_BITS(d, 53);
    VERIFY_CHECK(d <= 0x10000003FFFFBF)
    /* [r9+(c<<22) r8 r7 r6 r5 r4 r3 t2 d-c*R1>>4 r0-c*R0>>4] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    /* [r9 r8 r7 r6 r5 r4 r3 t2 d r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[1] = UInt32(d & M); d >>= 26;
    VERIFY_BITS(r[1], 26);
    VERIFY_BITS(d, 27);
    VERIFY_CHECK(d <= 0x4000000)
    /* [r9 r8 r7 r6 r5 r4 r3 t2+d r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    d   += UInt64(t2);
    VERIFY_BITS(d, 27);
    /* [r9 r8 r7 r6 r5 r4 r3 d r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
    r[2] = UInt32(d);
    VERIFY_BITS(r[2], 27);
    /* [r9 r8 r7 r6 r5 r4 r3 r2 r1 r0] = [p18 p17 p16 p15 p14 p13 p12 p11 p10 p9 p8 p7 p6 p5 p4 p3 p2 p1 p0] */
}

// r = a * b
// @param r:secp256k1_fe
// @param a:secp256k1_fe
// @param b:secp256k1_fe
func secp256k1_fe_mul(_ r:inout secp256k1_fe, _ a:secp256k1_fe, _ b:secp256k1_fe) {
#if VERIFY
    //VERIFY_CHECK(a->magnitude <= 8);
    //VERIFY_CHECK(b->magnitude <= 8);
    secp256k1_fe_verify(a);
    secp256k1_fe_verify(b);
    VERIFY_CHECK(r != b)
#endif
    secp256k1_fe_mul_inner(&r.n, a.n, b.n);
#if VERIFY
    r->magnitude = 1;
    r->normalized = 0;
    secp256k1_fe_verify(r);
#endif
}

// r = square root a
// @param [out] r:secp256k1_fe
// @param [in]  a:secp256k1_fe
func secp256k1_fe_sqr(_ r:inout secp256k1_fe, _ a:secp256k1_fe) {
#if VERIFY
    //VERIFY_CHECK(a->magnitude <= 8);
    secp256k1_fe_verify(a);
#endif
    secp256k1_fe_sqr_inner(&r.n, a.n);
#if VERIFY
    r->magnitude = 1;
    r->normalized = 0;
    secp256k1_fe_verify(r);
#endif
}

// if flag is true, r = a
// if not, r leave it
func secp256k1_fe_cmov(_ r:inout secp256k1_fe, _ a:secp256k1_fe, _ flag:Bool) {
    var mask0, mask1:UInt32
    mask0 = flag ? 1 : 0 + UInt32.max
    mask1 = ~mask0
    for i in 0..<10 {
        r.n[i] = (r.n[i] & mask0) | (a.n[i] & mask1)
    }
#if VERIFY
    if (a->magnitude > r->magnitude) {
        r->magnitude = a->magnitude
    }
    r->normalized &= a->normalized
#endif
}

// if flag is true, r = a
// if not, r leave it
// r : secp256k1_fe_storage
// a : secp256k1_fe_storage
// flag : int
func secp256k1_fe_storage_cmov(_ r:inout secp256k1_fe_storage, _ a:secp256k1_fe_storage, _ flag:Bool) {
    var mask0, mask1:UInt32;
    mask0 = flag ? 1 : 0 + ~(UInt32(0));
    mask1 = ~mask0;
    for i in 0..<8 {
        r.n[i] = (r.n[i] & mask0) | (a.n[i] & mask1);
    }
}

// r = a
// @param r:secp256k1_fe_storage
// @param a:secp256k1_fe
func secp256k1_fe_to_storage(_ r:inout secp256k1_fe_storage, _ a:secp256k1_fe) {
#if VERIFY
    VERIFY_CHECK(a->normalized)
#endif
    r.n[0] = a.n[0] | a.n[1] << 26;
    r.n[1] = a.n[1] >> 6 | a.n[2] << 20;
    r.n[2] = a.n[2] >> 12 | a.n[3] << 14;
    r.n[3] = a.n[3] >> 18 | a.n[4] << 8;
    r.n[4] = a.n[4] >> 24 | a.n[5] << 2 | a.n[6] << 28;
    r.n[5] = a.n[6] >> 4 | a.n[7] << 22;
    r.n[6] = a.n[7] >> 10 | a.n[8] << 16;
    r.n[7] = a.n[8] >> 16 | a.n[9] << 10;
}

// r = a
// @param r:secp256k1_fe
// @param a:secp256k1_fe_storage
func secp256k1_fe_from_storage(_ r:inout secp256k1_fe, _ a:secp256k1_fe_storage) {
    r.n[0] = a.n[0] & 0x3FFFFFF;
    r.n[1] = a.n[0] >> 26 | ((a.n[1] << 6) & 0x3FFFFFF);
    r.n[2] = a.n[1] >> 20 | ((a.n[2] << 12) & 0x3FFFFFF);
    r.n[3] = a.n[2] >> 14 | ((a.n[3] << 18) & 0x3FFFFFF);
    r.n[4] = a.n[3] >> 8 | ((a.n[4] << 24) & 0x3FFFFFF);
    r.n[5] = (a.n[4] >> 2) & 0x3FFFFFF;
    r.n[6] = a.n[4] >> 28 | ((a.n[5] << 4) & 0x3FFFFFF);
    r.n[7] = a.n[5] >> 22 | ((a.n[6] << 10) & 0x3FFFFFF);
    r.n[8] = a.n[6] >> 16 | ((a.n[7] << 16) & 0x3FFFFFF);
    r.n[9] = a.n[7] >> 10;
#if VERIFY
    r.magnitude = 1;
    r.normalized = 1;
#endif
}