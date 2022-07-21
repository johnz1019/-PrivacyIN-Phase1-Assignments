pragma circom 2.0.0;

// Reference from https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom
template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}

// Reference from https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom
template IsEqual() {
    signal input in[2];
    signal output out;

    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    isz.out ==> out;
}

template Multiplier2(){
   //Declaration of signals.
   signal input in1;
   signal input in2;
   signal output out;

   //Statements.
   out <== in1 * in2;
}

template Calculator () {  

   // Declaration of signals.  
   signal input x;  
   signal input y;  
   signal input z;  
   signal output out;  

   // x == 1
   component ise = IsEqual();
   x ==> ise.in[0];
   1 ==> ise.in[1];

   // x*y
   component mul1 = Multiplier2();
   y ==> mul1.in1;
   z ==> mul1.in2;
   
   // (1 - ise.out) * (2*y - z)
   component mul2 = Multiplier2();
   1 - ise.out ==> mul2.in1;
   2 * y - z  ==> mul2.in2;

   out <== ise.out * mul1.out + mul2.out;

}

 component main = Calculator();

