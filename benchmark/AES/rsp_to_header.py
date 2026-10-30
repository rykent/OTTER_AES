#!/usr/bin/env python3
"""
Convert NIST CAVP / AESAVS .rsp response files into C header files (.h).
Supports all modes (ECB, CBC, OFB, CFB128, CFB8, CFB1) and key sizes (128, 192, 256).
Parses BOTH [ENCRYPT] and [DECRYPT] sections with ALL test vectors.
"""

import sys
import os
import re
import argparse
import glob


def hex_to_c_val(hex_str):
    """Formats a hex string into a C literal or array of 32-bit words."""
    hex_str = hex_str.lower().strip()
    if len(hex_str) <= 2:
        # 1 or 2 hex chars (byte or bit)
        return f"0x{hex_str}"

    # Split into 32-bit big-endian words (8 hex chars each)
    words = [f"0x{hex_str[i:i+8]}" for i in range(0, len(hex_str), 8)]
    return "{" + ", ".join(words) + "}"


def parse_rsp_file(rsp_path, max_vectors=None):
    """
    Parses a NIST .rsp file into (encrypt_vectors, decrypt_vectors).
    Each vector is a dict with keys: COUNT, KEY, PLAINTEXT, CIPHERTEXT, and optionally IV.
    """
    enc_vectors = []
    dec_vectors = []
    current_section = None
    current_vector = {}

    with open(rsp_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            if line.startswith('[ENCRYPT]'):
                if current_vector and current_section:
                    target = enc_vectors if current_section == 'ENCRYPT' else dec_vectors
                    target.append(current_vector)
                current_section = 'ENCRYPT'
                current_vector = {}
                continue

            if line.startswith('[DECRYPT]'):
                if current_vector and current_section:
                    target = enc_vectors if current_section == 'ENCRYPT' else dec_vectors
                    target.append(current_vector)
                current_section = 'DECRYPT'
                current_vector = {}
                continue

            match = re.match(r'^([A-Za-z]+)\s*=\s*([0-9a-fA-F]+)', line)
            if match:
                k, v = match.groups()
                k = k.upper()
                if k == 'COUNT' and current_vector:
                    if current_section == 'ENCRYPT':
                        enc_vectors.append(current_vector)
                    elif current_section == 'DECRYPT':
                        dec_vectors.append(current_vector)
                    current_vector = {}
                current_vector[k] = v

    # Commit any trailing vector
    if current_vector and current_section:
        if current_section == 'ENCRYPT':
            enc_vectors.append(current_vector)
        elif current_section == 'DECRYPT':
            dec_vectors.append(current_vector)

    if max_vectors is not None:
        enc_vectors = enc_vectors[:max_vectors]
        dec_vectors = dec_vectors[:max_vectors]

    return enc_vectors, dec_vectors


def generate_header_string(rsp_path, enc_vectors, dec_vectors):
    """Generates the full C header content as a string."""
    base_name = os.path.splitext(os.path.basename(rsp_path))[0].lower()
    guard = f"KAT_{base_name.upper()}_H"
    type_name = f"kat_{base_name}_vector_t"

    sample = (enc_vectors[0] if enc_vectors else dec_vectors[0]) if (enc_vectors or dec_vectors) else {}
    key_hex = sample.get('KEY', '')
    key_words = len(key_hex) // 8 if key_hex else 4
    has_iv = 'IV' in sample
    pt_hex = sample.get('PLAINTEXT', '')
    is_stream = len(pt_hex) <= 2 and len(pt_hex) > 0

    lines = []
    lines.append(f"// Auto-generated from {os.path.basename(rsp_path)}")
    lines.append(f"#ifndef {guard}")
    lines.append(f"#define {guard}\n")
    lines.append("#include <stdint.h>\n")

    # Struct definition
    lines.append("typedef struct {")
    lines.append("    uint32_t count;")
    lines.append(f"    uint32_t key[{key_words}];")
    if has_iv:
        lines.append("    uint32_t iv[4];")
    if is_stream:
        lines.append("    uint8_t pt;")
        lines.append("    uint8_t ct;")
    else:
        lines.append("    uint32_t pt[4];")
        lines.append("    uint32_t ct[4];")
    lines.append(f"}} {type_name};\n")

    # Sections
    sections = [("encrypt", enc_vectors), ("decrypt", dec_vectors)]
    for s_name, vecs in sections:
        num_macro = f"NUM_{base_name.upper()}_{s_name.upper()}_VECTORS"
        arr_name = f"{base_name}_{s_name}_vectors"

        lines.append(f"#define {num_macro} {len(vecs)}")
        lines.append(f"static const {type_name} {arr_name}[{num_macro}] = {{")
        for v in vecs:
            count_val = v.get('COUNT', 0)
            key_c = hex_to_c_val(v.get('KEY', '00000000'))
            pt_c = hex_to_c_val(v.get('PLAINTEXT', '00000000'))
            ct_c = hex_to_c_val(v.get('CIPHERTEXT', '00000000'))

            fields = [f".count = {count_val}", f".key = {key_c}"]
            if has_iv and 'IV' in v:
                iv_c = hex_to_c_val(v['IV'])
                fields.append(f".iv = {iv_c}")
            fields.append(f".pt = {pt_c}")
            fields.append(f".ct = {ct_c}")

            lines.append("    { " + ", ".join(fields) + " },")
        lines.append("};\n")

    lines.append(f"#endif // {guard}\n")
    return "\n".join(lines)


def process_file(rsp_path, output_path=None, max_vectors=None):
    """Processes a single .rsp file and writes output to file or stdout."""
    enc, dec = parse_rsp_file(rsp_path, max_vectors)
    content = generate_header_string(rsp_path, enc, dec)

    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Generated {output_path} ({len(enc)} enc, {len(dec)} dec vectors)")
    else:
        sys.stdout.write(content)


def main():
    parser = argparse.ArgumentParser(
        description="Convert NIST AES .rsp test vector files to C headers with full ENCRYPT and DECRYPT vectors."
    )
    parser.add_argument("files", nargs="*", help="Path to .rsp file(s) to convert")
    parser.add_argument("-o", "--output", help="Output file path (default: stdout, or <name>.h in batch mode)")
    parser.add_argument("-d", "--dir", help="Directory of .rsp files to process all files in batch")
    parser.add_argument("--out-dir", help="Output directory for batch processing (default: current directory)")
    parser.add_argument("--max-vectors", type=int, default=None, help="Limit number of vectors per section (default: all)")

    args = parser.parse_args()

    # Determine files to process
    targets = []
    if args.dir:
        targets.extend(glob.glob(os.path.join(args.dir, "*.rsp")))
    if args.files:
        for f in args.files:
            if '*' in f:
                targets.extend(glob.glob(f))
            else:
                targets.append(f)

    if not targets:
        parser.print_help()
        sys.exit(1)

    targets = sorted(list(set(targets)))

    if len(targets) == 1 and not args.out_dir and (args.output or not sys.stdout.isatty()):
        # Single file to specific output or redirected stdout
        process_file(targets[0], args.output, args.max_vectors)
    else:
        # Batch mode
        out_dir = args.out_dir if args.out_dir else "."
        os.makedirs(out_dir, exist_ok=True)
        for t in targets:
            base_name = os.path.splitext(os.path.basename(t))[0].lower() + ".h"
            out_file = os.path.join(out_dir, base_name)
            process_file(t, out_file, args.max_vectors)


if __name__ == "__main__":
    main()