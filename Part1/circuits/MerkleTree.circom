pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component poseidon[2**(n-1)];
    var previousHashes = leaves;
    for(var level = 0; level < n; level=level+1) {
        var hashes[2**(n-level-1)];
        for(var i = 0; i < 2**(n - level); i=i+1) {
            var toHash;
            poseidon[2**level+i-1] = Poseidon(2);
            if(i%2==0) {
                poseidon[2**level+i/2].in[0] <== previousHashes[i];
            } else {
                poseidon[2**level+i/2].in[1] <== previousHashes[i];
                hashes[(i-1)/2] <== poseidon[2**level+i/2].out;
            }
        }
        previousHashes = hashes;
    }
    root = previousHashes[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    component switcher[n];
    signal hashes[n];
    hashes[0] <== leaf;
    for(var i=0; i<n; i=i+1){
        poseidon[i] = Poseidon(2);
        switcher[i] = Switcher();

        switcher[i].L <== path_elements[i];
        switcher[i].R <== hashes[i];
        switcher[i].sel <== path_index[i];

        poseidon[i].inputs[0] <== switcher[i].outL;
        poseidon[i].inputs[1] <== switcher[i].outR;

        if(i==n-1){
            root <== poseidon[i].out;
        } else {
            hashes[i+1] <== poseidon[i].out;
        }  
    }
}