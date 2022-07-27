#!bin/bash -e

CIRCUIT_NAME=BitsSum


prove_verify() {
    node ${CIRCUIT_NAME}_js/generate_witness.js ${CIRCUIT_NAME}_js/$CIRCUIT_NAME.wasm ../input_${1}.json witness_${1}.wtns
    echo "------------------------generate witness for ${1}------------------------"
    
    echo "------------------------start generating proof for ${1}------------------------"
    snarkjs groth16 prove ${CIRCUIT_NAME}_0001.zkey witness_${1}.wtns proof_${1}.json public_${1}.json
    
    echo "------------------------start verifying proof for ${1}------------------------"
    snarkjs groth16 verify verification_key.json public_${1}.json proof_${1}.json
    
    echo "------------------------end verifying proof for ${1}------------------------\n"
}

main() {
    mkdir build/
    rm -rf build/*
    
    circom $CIRCUIT_NAME.circom --r1cs --wasm --sym --c --json -o build/
    
    echo "------------------------compile circuit successfully------------------------"
    
    cd build
    echo "------------------------start trust setup------------------------"
    snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
    snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
    snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
    
    snarkjs groth16 setup $CIRCUIT_NAME.r1cs pot12_final.ptau ${CIRCUIT_NAME}_0000.zkey
    snarkjs zkey contribute ${CIRCUIT_NAME}_0000.zkey ${CIRCUIT_NAME}_0001.zkey --name="1st Contributor Name" -v
    snarkjs zkey export verificationkey ${CIRCUIT_NAME}_0001.zkey verification_key.json
    echo "------------------------trust setup successfully------------------------"
    
    prove_verify 1
    prove_verify 2
    
}

main











