/**********************************************************************
 * Copyright (c) 2013, 2014 Pieter Wuille                             *
 * Distributed under the MIT software license, see the accompanying   *
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.*
 **********************************************************************/

#ifndef SECP256K1_ECMULT_GEN_H
#define SECP256K1_ECMULT_GEN_H

#include "scalar.h"
#include "group.h"

typedef struct {
    /* For accelerating the computation of a*G:
     * To harden against timing attacks, use the following mechanism:
     * * Break up the multiplicand into groups of PREC_B bits, called n_0, n_1, n_2, ..., n_(PREC_N-1).
     * * Compute sum(n_i * (PREC_G)^i * G + U_i, i=0 ... PREC_N-1), where:
     *   * U_i = U * 2^i, for i=0 ... PREC_N-2
     *   * U_i = U * (1-2^(PREC_N-1)), for i=PREC_N-1
     *   where U is a point with no known corresponding scalar. Note that sum(U_i, i=0 ... PREC_N-1) = 0.
     * For each i, and each of the PREC_G possible values of n_i, (n_i * (PREC_G)^i * G + U_i) is
     * precomputed (call it prec(i, n_i)). The formula now becomes sum(prec(i, n_i), i=0 ... PREC_N-1).
     * None of the resulting prec group elements have a known scalar, and neither do any of
     * the intermediate sums while computing a*G.
     */
    secp256k1_ge_storage (*prec)[64][16]; /* prec[j][i] = (PREC_G)^j * i * G + U_i */
    secp256k1_scalar blind;
    secp256k1_gej initial;
} secp256k1_ecmult_gen_context;

static const size_t SECP256K1_ECMULT_GEN_CONTEXT_PREALLOCATED_SIZE;
static void secp256k1_ecmult_gen_context_init(secp256k1_ecmult_gen_context* ctx);
static void secp256k1_ecmult_gen_context_build(secp256k1_ecmult_gen_context* ctx, void **prealloc);
static void secp256k1_ecmult_gen_context_finalize_memcpy(secp256k1_ecmult_gen_context *dst, const secp256k1_ecmult_gen_context* src);
static void secp256k1_ecmult_gen_context_clear(secp256k1_ecmult_gen_context* ctx);
static int secp256k1_ecmult_gen_context_is_built(const secp256k1_ecmult_gen_context* ctx);

/** Multiply with the generator: R = a*G */
static void secp256k1_ecmult_gen(const secp256k1_ecmult_gen_context* ctx, secp256k1_gej *r, const secp256k1_scalar *a);

static void secp256k1_ecmult_gen_blind(secp256k1_ecmult_gen_context *ctx, const unsigned char *seed32);

#endif /* SECP256K1_ECMULT_GEN_H */
