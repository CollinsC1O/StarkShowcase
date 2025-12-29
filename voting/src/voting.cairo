#[starknet::contract]
mod Voting {
    use crate::interfaces::IVoting::IVoting;
    use starknet::{ContractAddress};

    #[derive(Drop, starknet::Store)]
    pub struct Candidate {
        pub id: u256,
        pub name: ByteArray,
        pub address: ContractAddress,
        pub vote_count: u256
    }

    #[storage]
    struct Storage {

    }


}