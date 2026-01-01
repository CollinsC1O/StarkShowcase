use starknet::ContractAddress;

trait IERC20DispatcherTrait<T> {
    fn name(self: T) -> felt252;
    fn transfer(self: T, recipient: ContractAddress, amount: u256);
    // fn transfer_from(self: T, sender: ContractAddress, recipient: ContractAddress, amount: u256);
// fn allowance(self: T, owner: ContractAddress, spender: ContractAddress) -> u256;
}

#[derive(Copy, Drop, starknet::Store, Serde)]
struct IERC20Dispatcher {
    pub contract_address: ContractAddress,
}

impl IERC20DispatcherImpl of IERC20DispatcherTrait<IERC20Dispatcher> {
    fn name(self: IERC20Dispatcher) -> felt252 {
        let mut calldata = core::traits::Default::default();

        let mut dispatcher_return_data = starknet::syscalls::call_contract_syscall(
            self.contract_address, selector!("name"), core::array::ArrayTrait::span(@calldata),
        );

        let mut dispatcher_return_data = starknet::SyscallResultTrait::unwrap_syscall(
            dispatcher_return_data,
        );

        core::option::OptionTrait::expect(
            core::serde::Serde::<felt252>::deserialize(ref dispatcher_return_data),
            'Return data too short',
        )
    }

    fn transfer(self: IERC20Dispatcher, recipient: ContractAddress, amount: u256) {
        let mut calldata = core::traits::Default::default();

        core::serde::Serde::<ContractAddress>::serialize(@recipient, ref calldata);
        core::serde::Serde::<u256>::serialize(@amount, ref calldata);

        let mut __dispatcher_return_data__ = starknet::SyscallResultTrait::unwrap_syscall(
            starknet::syscalls::call_contract_syscall(
                self.contract_address,
                selector!("transfer"),
                core::array::ArrayTrait::span(@calldata),
            ),
        );
    }
    // // An addition functionality
// fn transfer_from(
//     self: IERC20Dispatcher, sender: ContractAddress, recipient: ContractAddress, amount:
//     u256,
// ) {
//     //create an empty default array
//     let mut calldata = core::traits::Default::default();

    //     // serialize/append arguments into the calldata array
//     core::serde::Serde::<ContractAddress>::serialize(@sender, ref calldata);
//     core::serde::Serde::<ContractAddress>::serialize(@recipient, ref calldata);
//     core::serde::Serde::<u256>::serialize(@amount, ref calldata);

    //     let mut dispatcher_return_data = starknet::syscalls::call_contract_syscall(
//         self.contract_address,
//         selector!("transfer_from"),
//         core::array::ArrayTrait::span(@calldata),
//     );

    //     let mut dispatcher_return_data = starknet::SyscallResultTrait::unwrap_syscall(
//         dispatcher_return_data,
//     );
// }

    // fn allowance(self: IERC20Dispatcher, owner: ContractAddress, spender: ContractAddress) ->
// u256 {
//     let mut calldata_ = core::traits::Default::default();

    //     core::serde::Serde::serialize(@owner, ref calldata_);
//     core::serde::Serde::serialize(@spender, ref calldata_);

    //     let mut dispatcher_return_data = starknet::syscalls::call_contract_syscall(
//         self.contract_address,
//         selector!("allowance"),
//         core::array::ArrayTrait::span(@calldata_),
//     );

    //     let mut dispatcher_return_data = starknet::SyscallResultTrait::unwrap_syscall(
//         dispatcher_return_data,
//     );

    //     core::option::OptionTrait::expect(
//         core::serde::Serde::<felt252>::deserialize(ref dispatcher_return_data),
//         "return value too short",
//     )
// }
}
