pragma circom 2.0.0;

template BitsSum() {
    signal input in[2][256];
    signal output out[257];

    var i;
    var sum = 0;
    var carry = 0;

    for(i = 255; i >= 0; i-- ) {
        // constraints for input
        in[0][i] * (in[0][i] - 1) === 0;
        in[1][i] * (in[1][i] - 1) === 0;

        sum = carry + in[0][i] + in[1][i];

        carry = (sum >> 1) & 1;
        out[i + 1] <-- sum % 2;
        
        // constraints for output
        out[i + 1] * (out[i + 1] - 1) === 0;
    }

    out[0] <-- carry;
    out[0] * (out[0] - 1) === 0;

}

 component main = BitsSum();

