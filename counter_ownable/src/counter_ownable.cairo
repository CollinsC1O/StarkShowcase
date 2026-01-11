/// Interface representing `CounterOwnable`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait ICounterOwnable<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: u128);
    /// Decrease contract balance
    fn decrease_balance(ref self: TContractState, decrs_amount: u128) -> bool;
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> u128;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod CounterOwnable {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use ownable_component::ownable_component::OwnableComponent;
    
    component!(path: OwnableComponent, storage: owner, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        balance: u128,
        #[substorage(v0)]
        owner: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, Copy, starknet::Event)]
    enum Event{
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner)
    }
    #[abi(embed_v0)]
    impl CounterOwnableImpl of super::ICounterOwnable<ContractState> {
        fn increase_balance(ref self: ContractState, amount: u128) {
            self.assert_only_owner();
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn decrease_balance(ref self: ContractState, decrs_amount: u128) -> bool {
            self.assert_only_owner();
            assert(decrs_amount != 0, 'amount can not be 0')
            self.balance.write(self.balance.read() - decrs_amount);
            true
        }

        fn get_balance(self: @ContractState) -> u128 {
            self.balance.read()
        }
    }
}
