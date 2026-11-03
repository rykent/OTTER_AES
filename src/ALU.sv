`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/16/2023 10:00:44 PM
// Design Name: ALU
// Module Name: ALU
// Target Devices: Basys3 
// Description: Arithmetic Logic Unit for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] ALU_FUN,
    input [1:0] bs,
    input aes_func,
    output logic [31:0] RESULT
    );

    //
    //AES Encrypt Zkne
    //
    logic [7:0] si;
    assign si = srcB >> {bs, 3'b000};

    logic [7:0] so;
    logic [31:0] esi_res;
    
    //AES Forward S-BOX Lookup Table:
    always_comb begin
        case (si)
            8'h00: so = 8'h63; 8'h01: so = 8'h7c; 8'h02: so = 8'h77; 8'h03: so = 8'h7b;
            8'h04: so = 8'hf2; 8'h05: so = 8'h6b; 8'h06: so = 8'h6f; 8'h07: so = 8'hc5;
            8'h08: so = 8'h30; 8'h09: so = 8'h01; 8'h0a: so = 8'h67; 8'h0b: so = 8'h2b;
            8'h0c: so = 8'hfe; 8'h0d: so = 8'hd7; 8'h0e: so = 8'hab; 8'h0f: so = 8'h76;
            8'h10: so = 8'hca; 8'h11: so = 8'h82; 8'h12: so = 8'hc9; 8'h13: so = 8'h7d;
            8'h14: so = 8'hfa; 8'h15: so = 8'h59; 8'h16: so = 8'h47; 8'h17: so = 8'hf0;
            8'h18: so = 8'had; 8'h19: so = 8'hd4; 8'h1a: so = 8'ha2; 8'h1b: so = 8'haf;
            8'h1c: so = 8'h9c; 8'h1d: so = 8'ha4; 8'h1e: so = 8'h72; 8'h1f: so = 8'hc0;
            8'h20: so = 8'hb7; 8'h21: so = 8'hfd; 8'h22: so = 8'h93; 8'h23: so = 8'h26;
            8'h24: so = 8'h36; 8'h25: so = 8'h3f; 8'h26: so = 8'hf7; 8'h27: so = 8'hcc;
            8'h28: so = 8'h34; 8'h29: so = 8'ha5; 8'h2a: so = 8'he5; 8'h2b: so = 8'hf1;
            8'h2c: so = 8'h71; 8'h2d: so = 8'hd8; 8'h2e: so = 8'h31; 8'h2f: so = 8'h15;
            8'h30: so = 8'h04; 8'h31: so = 8'hc7; 8'h32: so = 8'h23; 8'h33: so = 8'hc3;
            8'h34: so = 8'h18; 8'h35: so = 8'h96; 8'h36: so = 8'h05; 8'h37: so = 8'h9a;
            8'h38: so = 8'h07; 8'h39: so = 8'h12; 8'h3a: so = 8'h80; 8'h3b: so = 8'he2;
            8'h3c: so = 8'heb; 8'h3d: so = 8'h27; 8'h3e: so = 8'hb2; 8'h3f: so = 8'h75;
            8'h40: so = 8'h09; 8'h41: so = 8'h83; 8'h42: so = 8'h2c; 8'h43: so = 8'h1a;
            8'h44: so = 8'h1b; 8'h45: so = 8'h6e; 8'h46: so = 8'h5a; 8'h47: so = 8'ha0;
            8'h48: so = 8'h52; 8'h49: so = 8'h3b; 8'h4a: so = 8'hd6; 8'h4b: so = 8'hb3;
            8'h4c: so = 8'h29; 8'h4d: so = 8'he3; 8'h4e: so = 8'h2f; 8'h4f: so = 8'h84;
            8'h50: so = 8'h53; 8'h51: so = 8'hd1; 8'h52: so = 8'h00; 8'h53: so = 8'hed;
            8'h54: so = 8'h20; 8'h55: so = 8'hfc; 8'h56: so = 8'hb1; 8'h57: so = 8'h5b;
            8'h58: so = 8'h6a; 8'h59: so = 8'hcb; 8'h5a: so = 8'hbe; 8'h5b: so = 8'h39;
            8'h5c: so = 8'h4a; 8'h5d: so = 8'h4c; 8'h5e: so = 8'h58; 8'h5f: so = 8'hcf;
            8'h60: so = 8'hd0; 8'h61: so = 8'hef; 8'h62: so = 8'haa; 8'h63: so = 8'hfb;
            8'h64: so = 8'h43; 8'h65: so = 8'h4d; 8'h66: so = 8'h33; 8'h67: so = 8'h85;
            8'h68: so = 8'h45; 8'h69: so = 8'hf9; 8'h6a: so = 8'h02; 8'h6b: so = 8'h7f;
            8'h6c: so = 8'h50; 8'h6d: so = 8'h3c; 8'h6e: so = 8'h9f; 8'h6f: so = 8'ha8;
            8'h70: so = 8'h51; 8'h71: so = 8'ha3; 8'h72: so = 8'h40; 8'h73: so = 8'h8f;
            8'h74: so = 8'h92; 8'h75: so = 8'h9d; 8'h76: so = 8'h38; 8'h77: so = 8'hf5;
            8'h78: so = 8'hbc; 8'h79: so = 8'hb6; 8'h7a: so = 8'hda; 8'h7b: so = 8'h21;
            8'h7c: so = 8'h10; 8'h7d: so = 8'hff; 8'h7e: so = 8'hf3; 8'h7f: so = 8'hd2;
            8'h80: so = 8'hcd; 8'h81: so = 8'h0c; 8'h82: so = 8'h13; 8'h83: so = 8'hec;
            8'h84: so = 8'h5f; 8'h85: so = 8'h97; 8'h86: so = 8'h44; 8'h87: so = 8'h17;
            8'h88: so = 8'hc4; 8'h89: so = 8'ha7; 8'h8a: so = 8'h7e; 8'h8b: so = 8'h3d;
            8'h8c: so = 8'h64; 8'h8d: so = 8'h5d; 8'h8e: so = 8'h19; 8'h8f: so = 8'h73;
            8'h90: so = 8'h60; 8'h91: so = 8'h81; 8'h92: so = 8'h4f; 8'h93: so = 8'hdc;
            8'h94: so = 8'h22; 8'h95: so = 8'h2a; 8'h96: so = 8'h90; 8'h97: so = 8'h88;
            8'h98: so = 8'h46; 8'h99: so = 8'hee; 8'h9a: so = 8'hb8; 8'h9b: so = 8'h14;
            8'h9c: so = 8'hde; 8'h9d: so = 8'h5e; 8'h9e: so = 8'h0b; 8'h9f: so = 8'hdb;
            8'ha0: so = 8'he0; 8'ha1: so = 8'h32; 8'ha2: so = 8'h3a; 8'ha3: so = 8'h0a;
            8'ha4: so = 8'h49; 8'ha5: so = 8'h06; 8'ha6: so = 8'h24; 8'ha7: so = 8'h5c;
            8'ha8: so = 8'hc2; 8'ha9: so = 8'hd3; 8'haa: so = 8'hac; 8'hab: so = 8'h62;
            8'hac: so = 8'h91; 8'had: so = 8'h95; 8'hae: so = 8'he4; 8'haf: so = 8'h79;
            8'hb0: so = 8'he7; 8'hb1: so = 8'hc8; 8'hb2: so = 8'h37; 8'hb3: so = 8'h6d;
            8'hb4: so = 8'h8d; 8'hb5: so = 8'hd5; 8'hb6: so = 8'h4e; 8'hb7: so = 8'ha9;
            8'hb8: so = 8'h6c; 8'hb9: so = 8'h56; 8'hba: so = 8'hf4; 8'hbb: so = 8'hea;
            8'hbc: so = 8'h65; 8'hbd: so = 8'h7a; 8'hbe: so = 8'hae; 8'hbf: so = 8'h08;
            8'hc0: so = 8'hba; 8'hc1: so = 8'h78; 8'hc2: so = 8'h25; 8'hc3: so = 8'h2e;
            8'hc4: so = 8'h1c; 8'hc5: so = 8'ha6; 8'hc6: so = 8'hb4; 8'hc7: so = 8'hc6;
            8'hc8: so = 8'he8; 8'hc9: so = 8'hdd; 8'hca: so = 8'h74; 8'hcb: so = 8'h1f;
            8'hcc: so = 8'h4b; 8'hcd: so = 8'hbd; 8'hce: so = 8'h8b; 8'hcf: so = 8'h8a;
            8'hd0: so = 8'h70; 8'hd1: so = 8'h3e; 8'hd2: so = 8'hb5; 8'hd3: so = 8'h66;
            8'hd4: so = 8'h48; 8'hd5: so = 8'h03; 8'hd6: so = 8'hf6; 8'hd7: so = 8'h0e;
            8'hd8: so = 8'h61; 8'hd9: so = 8'h35; 8'hda: so = 8'h57; 8'hdb: so = 8'hb9;
            8'hdc: so = 8'h86; 8'hdd: so = 8'hc1; 8'hde: so = 8'h1d; 8'hdf: so = 8'h9e;
            8'he0: so = 8'he1; 8'he1: so = 8'hf8; 8'he2: so = 8'h98; 8'he3: so = 8'h11;
            8'he4: so = 8'h69; 8'he5: so = 8'hd9; 8'he6: so = 8'h8e; 8'he7: so = 8'h94;
            8'he8: so = 8'h9b; 8'he9: so = 8'h1e; 8'hea: so = 8'h87; 8'heb: so = 8'he9;
            8'hec: so = 8'hce; 8'hed: so = 8'h55; 8'hee: so = 8'h28; 8'hef: so = 8'hdf;
            8'hf0: so = 8'h8c; 8'hf1: so = 8'ha1; 8'hf2: so = 8'h89; 8'hf3: so = 8'h0d;
            8'hf4: so = 8'hbf; 8'hf5: so = 8'he6; 8'hf6: so = 8'h42; 8'hf7: so = 8'h68;
            8'hf8: so = 8'h41; 8'hf9: so = 8'h99; 8'hfa: so = 8'h2d; 8'hfb: so = 8'h0f;
            8'hfc: so = 8'hb0; 8'hfd: so = 8'h54; 8'hfe: so = 8'hbb; 8'hff: so = 8'h16;
            default: so = 8'h00;
        endcase
    end

    //Mix Columns
    logic [7:0] so_x2;
    assign so_x2 = {so[6:0], 1'b0} ^ (so[7] ? 8'h1b : 8'h00);

    logic [31:0] mix_col = {so_x2 ^ so, so, so, so_x2};
    logic [31:0] esmi_res;

    always_comb begin
        case (bs) 
            0: esmi_res = mix_col;
            1: esmi_res = {mix_col[23:0], mix_col[31:24]};
            2: esmi_res = {mix_col[15:0], mix_col[31:16]};
            3: esmi_res = {mix_col[7:0], mix_col[31:8]};
            default: esmi_res = mix_col;
        endcase
    end

    assign esi_res = so << {bs, 3'b000};

    //
    // AES Decrypt Zknd
    //

    logic [7:0] dso;
    logic [31:0] dsmi_res;
    logic [31:0] dsi_res; 
    logic [31:0] inv_mix_col;  

    // Inverse SBox Lookup table
    always_comb begin
        case (si)
            8'h00: dso = 8'h52; 8'h01: dso = 8'h09; 8'h02: dso = 8'h6a; 8'h03: dso = 8'hd5;
            8'h04: dso = 8'h30; 8'h05: dso = 8'h36; 8'h06: dso = 8'ha5; 8'h07: dso = 8'h38;
            8'h08: dso = 8'hbf; 8'h09: dso = 8'h40; 8'h0a: dso = 8'ha3; 8'h0b: dso = 8'h9e;
            8'h0c: dso = 8'h81; 8'h0d: dso = 8'hf3; 8'h0e: dso = 8'hd7; 8'h0f: dso = 8'hfb;
            8'h10: dso = 8'h7c; 8'h11: dso = 8'he3; 8'h12: dso = 8'h39; 8'h13: dso = 8'h82;
            8'h14: dso = 8'h9b; 8'h15: dso = 8'h2f; 8'h16: dso = 8'hff; 8'h17: dso = 8'h87;
            8'h18: dso = 8'h34; 8'h19: dso = 8'h8e; 8'h1a: dso = 8'h43; 8'h1b: dso = 8'h44;
            8'h1c: dso = 8'hc4; 8'h1d: dso = 8'hde; 8'h1e: dso = 8'he9; 8'h1f: dso = 8'hcb;
            8'h20: dso = 8'h54; 8'h21: dso = 8'h7b; 8'h22: dso = 8'h94; 8'h23: dso = 8'h32;
            8'h24: dso = 8'ha6; 8'h25: dso = 8'hc2; 8'h26: dso = 8'h23; 8'h27: dso = 8'h3d;
            8'h28: dso = 8'hee; 8'h29: dso = 8'h4c; 8'h2a: dso = 8'h95; 8'h2b: dso = 8'h0b;
            8'h2c: dso = 8'h42; 8'h2d: dso = 8'hfa; 8'h2e: dso = 8'hc3; 8'h2f: dso = 8'h4e;
            8'h30: dso = 8'h08; 8'h31: dso = 8'h2e; 8'h32: dso = 8'ha1; 8'h33: dso = 8'h66;
            8'h34: dso = 8'h28; 8'h35: dso = 8'hd9; 8'h36: dso = 8'h24; 8'h37: dso = 8'hb2;
            8'h38: dso = 8'h76; 8'h39: dso = 8'h5b; 8'h3a: dso = 8'ha2; 8'h3b: dso = 8'h49;
            8'h3c: dso = 8'h6d; 8'h3d: dso = 8'h8b; 8'h3e: dso = 8'hd1; 8'h3f: dso = 8'h25;
            8'h40: dso = 8'h72; 8'h41: dso = 8'hf8; 8'h42: dso = 8'hf6; 8'h43: dso = 8'h64;
            8'h44: dso = 8'h86; 8'h45: dso = 8'h68; 8'h46: dso = 8'h98; 8'h47: dso = 8'h16;
            8'h48: dso = 8'hd4; 8'h49: dso = 8'ha4; 8'h4a: dso = 8'h5c; 8'h4b: dso = 8'hcc;
            8'h4c: dso = 8'h5d; 8'h4d: dso = 8'h65; 8'h4e: dso = 8'hb6; 8'h4f: dso = 8'h92;
            8'h50: dso = 8'h6c; 8'h51: dso = 8'h70; 8'h52: dso = 8'h48; 8'h53: dso = 8'h50;
            8'h54: dso = 8'hfd; 8'h55: dso = 8'hed; 8'h56: dso = 8'hb9; 8'h57: dso = 8'hda;
            8'h58: dso = 8'h5e; 8'h59: dso = 8'h15; 8'h5a: dso = 8'h46; 8'h5b: dso = 8'h57;
            8'h5c: dso = 8'ha7; 8'h5d: dso = 8'h8d; 8'h5e: dso = 8'h9d; 8'h5f: dso = 8'h84;
            8'h60: dso = 8'h90; 8'h61: dso = 8'hd8; 8'h62: dso = 8'hab; 8'h63: dso = 8'h00;
            8'h64: dso = 8'h8c; 8'h65: dso = 8'hbc; 8'h66: dso = 8'hd3; 8'h67: dso = 8'h0a;
            8'h68: dso = 8'hf7; 8'h69: dso = 8'he4; 8'h6a: dso = 8'h58; 8'h6b: dso = 8'h05;
            8'h6c: dso = 8'hb8; 8'h6d: dso = 8'hb3; 8'h6e: dso = 8'h45; 8'h6f: dso = 8'h06;
            8'h70: dso = 8'hd0; 8'h71: dso = 8'h2c; 8'h72: dso = 8'h1e; 8'h73: dso = 8'h8f;
            8'h74: dso = 8'hca; 8'h75: dso = 8'h3f; 8'h76: dso = 8'h0f; 8'h77: dso = 8'h02;
            8'h78: dso = 8'hc1; 8'h79: dso = 8'haf; 8'h7a: dso = 8'hbd; 8'h7b: dso = 8'h03;
            8'h7c: dso = 8'h01; 8'h7d: dso = 8'h13; 8'h7e: dso = 8'h8a; 8'h7f: dso = 8'h6b;
            8'h80: dso = 8'h3a; 8'h81: dso = 8'h91; 8'h82: dso = 8'h11; 8'h83: dso = 8'h41;
            8'h84: dso = 8'h4f; 8'h85: dso = 8'h67; 8'h86: dso = 8'hdc; 8'h87: dso = 8'hea;
            8'h88: dso = 8'h97; 8'h89: dso = 8'hf2; 8'h8a: dso = 8'hcf; 8'h8b: dso = 8'hce;
            8'h8c: dso = 8'hf0; 8'h8d: dso = 8'hb4; 8'h8e: dso = 8'he6; 8'h8f: dso = 8'h73;
            8'h90: dso = 8'h96; 8'h91: dso = 8'hac; 8'h92: dso = 8'h74; 8'h93: dso = 8'h22;
            8'h94: dso = 8'he7; 8'h95: dso = 8'had; 8'h96: dso = 8'h35; 8'h97: dso = 8'h85;
            8'h98: dso = 8'he2; 8'h99: dso = 8'hf9; 8'h9a: dso = 8'h37; 8'h9b: dso = 8'he8;
            8'h9c: dso = 8'h1c; 8'h9d: dso = 8'h75; 8'h9e: dso = 8'hdf; 8'h9f: dso = 8'h6e;
            8'ha0: dso = 8'h47; 8'ha1: dso = 8'hf1; 8'ha2: dso = 8'h1a; 8'ha3: dso = 8'h71;
            8'ha4: dso = 8'h1d; 8'ha5: dso = 8'h29; 8'ha6: dso = 8'hc5; 8'ha7: dso = 8'h89;
            8'ha8: dso = 8'h6f; 8'ha9: dso = 8'hb7; 8'haa: dso = 8'h62; 8'hab: dso = 8'h0e;
            8'hac: dso = 8'haa; 8'had: dso = 8'h18; 8'hae: dso = 8'hbe; 8'haf: dso = 8'h1b;
            8'hb0: dso = 8'hfc; 8'hb1: dso = 8'h56; 8'hb2: dso = 8'h3e; 8'hb3: dso = 8'h4b;
            8'hb4: dso = 8'hc6; 8'hb5: dso = 8'hd2; 8'hb6: dso = 8'h79; 8'hb7: dso = 8'h20;
            8'hb8: dso = 8'h9a; 8'hb9: dso = 8'hdb; 8'hba: dso = 8'hc0; 8'hbb: dso = 8'hfe;
            8'hbc: dso = 8'h78; 8'hbd: dso = 8'hcd; 8'hbe: dso = 8'h5a; 8'hbf: dso = 8'hf4;
            8'hc0: dso = 8'h1f; 8'hc1: dso = 8'hdd; 8'hc2: dso = 8'ha8; 8'hc3: dso = 8'h33;
            8'hc4: dso = 8'h88; 8'hc5: dso = 8'h07; 8'hc6: dso = 8'hc7; 8'hc7: dso = 8'h31;
            8'hc8: dso = 8'hb1; 8'hc9: dso = 8'h12; 8'hca: dso = 8'h10; 8'hcb: dso = 8'h59;
            8'hcc: dso = 8'h27; 8'hcd: dso = 8'h80; 8'hce: dso = 8'hec; 8'hcf: dso = 8'h5f;
            8'hd0: dso = 8'h60; 8'hd1: dso = 8'h51; 8'hd2: dso = 8'h7f; 8'hd3: dso = 8'ha9;
            8'hd4: dso = 8'h19; 8'hd5: dso = 8'hb5; 8'hd6: dso = 8'h4a; 8'hd7: dso = 8'h0d;
            8'hd8: dso = 8'h2d; 8'hd9: dso = 8'he5; 8'hda: dso = 8'h7a; 8'hdb: dso = 8'h9f;
            8'hdc: dso = 8'h93; 8'hdd: dso = 8'hc9; 8'hde: dso = 8'h9c; 8'hdf: dso = 8'hef;
            8'he0: dso = 8'ha0; 8'he1: dso = 8'he0; 8'he2: dso = 8'h3b; 8'he3: dso = 8'h4d;
            8'he4: dso = 8'hae; 8'he5: dso = 8'h2a; 8'he6: dso = 8'hf5; 8'he7: dso = 8'hb0;
            8'he8: dso = 8'hc8; 8'he9: dso = 8'heb; 8'hea: dso = 8'hbb; 8'heb: dso = 8'h3c;
            8'hec: dso = 8'h83; 8'hed: dso = 8'h53; 8'hee: dso = 8'h99; 8'hef: dso = 8'h61;
            8'hf0: dso = 8'h17; 8'hf1: dso = 8'h2b; 8'hf2: dso = 8'h04; 8'hf3: dso = 8'h7e;
            8'hf4: dso = 8'hba; 8'hf5: dso = 8'h77; 8'hf6: dso = 8'hd6; 8'hf7: dso = 8'h26;
            8'hf8: dso = 8'he1; 8'hf9: dso = 8'h69; 8'hfa: dso = 8'h14; 8'hfb: dso = 8'h63;
            8'hfc: dso = 8'h55; 8'hfd: dso = 8'h21; 8'hfe: dso = 8'h0c; 8'hff: dso = 8'h7d;
            default: dso = 8'h00;
        endcase
    end

    //Final Round result
    assign dsi_res = dso << {bs, 3'b000};

    //Middle Round result
    logic [7:0] dso_x1, dso_x2, dso_x4, dso_x8;
    assign dso_x1 = dso;
    assign dso_x2 = {dso_x1[6:0], 1'b0} ^ (dso_x1[7] ? 8'h1b : 8'h00);
    assign dso_x4 = {dso_x2[6:0], 1'b0} ^ (dso_x2[7] ? 8'h1b : 8'h00);
    assign dso_x8 = {dso_x4[6:0], 1'b0} ^ (dso_x4[7] ? 8'h1b : 8'h00);

    logic [7:0] dso_x9, dso_xb, dso_xd, dso_xe;
    assign dso_x9 = dso_x8 ^ dso_x1;
    assign dso_xb = dso_x8 ^ dso_x2 ^ dso_x1;
    assign dso_xd = dso_x8 ^ dso_x4 ^ dso_x1;
    assign dso_xe = dso_x8 ^ dso_x4 ^ dso_x2;

    assign inv_mix_col = {dso_xb, dso_xd, dso_x9, dso_xe};

    always_comb begin
        case(bs)
            0: dsmi_res = inv_mix_col;
            1: dsmi_res = {inv_mix_col[23:0], inv_mix_col[31:24]};
            2: dsmi_res = {inv_mix_col[15:0], inv_mix_col[31:16]};
            3: dsmi_res = {inv_mix_col[7:0], inv_mix_col[31:8]};
            default: dsmi_res = inv_mix_col;
    end
    
    always_comb begin
        case (ALU_FUN)
            0: begin    //ADD
                RESULT = srcA + srcB;
            end
            1: begin    //SLL
                RESULT = srcA << srcB[4:0];
            end
            2: begin    //SLT
                RESULT = {31'b0, $signed(srcA) < $signed(srcB)};
            end
            3: begin    //SLTU
                RESULT = {31'b0, srcA < srcB};
            end
            4: begin    //XOR
                RESULT = srcA ^ srcB;
            end
            5: begin    //SRL
                RESULT = srcA >> srcB[4:0];
            end
            6: begin    //OR
                RESULT = srcA | srcB;
            end
            7: begin    //AND
                RESULT = srcA & srcB;
            end
            8: begin    //SUB
                RESULT = srcA - srcB;
            end
            9: begin    //LUI-COPY
                RESULT = srcA;
            end
            10: begin   //AES32ESMI/AES32ESI
                RESULT = srcA ^ (aes_func ? esi_res : esmi_res);
            end
            11: begin   //AES32DSMI/AES32DSI
                RESULT = srcA ^ (aes_func ? dsi_res : dsmi_res);
            end
            13: begin   //SRA
                RESULT = $signed(srcA) >>> srcB[4:0];
            end

            default: begin
                RESULT = 'hDEADBEEF;
            end
        endcase
    end
endmodule
