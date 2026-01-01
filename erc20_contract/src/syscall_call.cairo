use starknet::ContractAddress;

#[starknet::interface]
trait ITokenWrapper<T> {
    fn transfer_token(
        ref self: T, address: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;
}

#[starknet::contract]
mod TokenWrapper {
    use starknet::{ContractAddress, get_caller_address, SyscallResultTrait, syscalls};
    use super::ITokenWrapper;
    //use erc20_contract::{IERC20Dispatcher, IERC20SafeDispatcher};

    #[storage]
    struct Storage {}

    impl ITokenWrapperImpl of ITokenWrapper<ContractState> {
        fn transfer_token(
            ref self: ContractState,
            address: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            let mut calldata: Array<felt252> = array![];

            let caller = get_caller_address();

            Serde::<ContractAddress>::serialize(@caller, ref calldata);
            Serde::<ContractAddress>::serialize(@recipient, ref calldata);
            Serde::<u256>::serialize(@amount, ref calldata);

            let mut res = syscalls::call_contract_syscall(
                address, selector!("transfer_from"), calldata.span(),
            );

            let mut res = starknet::SyscallResultTrait::unwrap_syscall(res);

            Serde::<bool>::deserialize(ref res).unwrap()
        }
    }
}
