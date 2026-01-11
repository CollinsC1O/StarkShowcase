use starknet::ContractAddress;
#[starknet::interface]
pub trait IOwnable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn transfer_owner(ref self: TContractState, new_owner: ContractAddress);
    fn renounce_owner(ref self: TContractState);
}

///////////////////////////////////
/////////// ERROR MODULE ///////////
///////////////////////////////////
pub mod Errors {
    pub const ZERRO_ADDRESS_CALLER: felt252 = 'caller is address zerro';
    pub const NOT_OWNER: felt252 = 'caller not owner';
}

///////////////////////////////////
/////////// COMPONENT MODULE///////////
///////////////////////////////////
#[starknet::component]
pub mod OwnableComponent {
    use core::num::traits::Zero;
    use starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};
    use starknet::{ContractAddress, get_caller_address};
    use super::Errors;

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, Copy, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, Copy, starknet::Event)]
    pub struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[embeddable_as(OwnableImpl)]
    impl Ownable<
        TContractState, +HasComponent<TContractState>,
    > of super::IOwnable<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_owner(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            assert(!new_owner.is_zero(), Errors::ZERRO_ADDRESS_CALLER);
            self.assert_only_owner();
            self._transfer_ownership(new_owner);
        }

        fn renounce_owner(ref self: ComponentState<TContractState>) {
            self.assert_only_owner();
            self._transfer_ownership(Zero::zero());
        }
    }

    ///////////////////////////////////
    /////////// INTERNAL FUNCTIONS ///////////
    ///////////////////////////////////
    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>,
    > of InternalTrait<TContractState> {
        fn initializer(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self._transfer_ownership(owner);
        }

        fn assert_only_owner(self: @ComponentState<TContractState>) {
            let owner: ContractAddress = self.owner.read();
            let caller: ContractAddress = get_caller_address();

            //assert owner is not zero address
            assert(!owner.is_zero(), Errors::ZERRO_ADDRESS_CALLER);
            assert(caller == owner, Errors::NOT_OWNER);
        }

        fn _transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress,
        ) {
            let previous_owner: ContractAddress = self.owner.read();

            self.owner.write(new_owner);

            self.emit(OwnershipTransferred { previous_owner, new_owner })
        }
    }
}
