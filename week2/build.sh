#!bin/bash -e

CIRCUIT_NAME=calculator

mkdir build/
rm -rf build/*


circom $CIRCUIT_NAME.circom --r1cs --wasm --sym --c --json -o build/

echo "------------------------compile circuit successfully------------------------"

cd build
node calculator_js/generate_witness.js calculator_js/$CIRCUIT_NAME.wasm ../input.json witness.wtns
echo "------------------------generate witness successfully------------------------"

echo "------------------------start trust setup------------------------"
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup $CIRCUIT_NAME.r1cs pot12_final.ptau $CIRCUIT_NAME_0000.zkey
snarkjs zkey contribute $CIRCUIT_NAME_0000.zkey $CIRCUIT_NAME_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey $CIRCUIT_NAME_0001.zkey verification_key.json
echo "------------------------trust setup successfully------------------------"

echo "------------------------start generating proof------------------------"
snarkjs groth16 prove $CIRCUIT_NAME_0001.zkey witness.wtns proof.json public.json

echo "------------------------start verifying proof------------------------"
snarkjs groth16 verify verification_key.json public.json proof.json













