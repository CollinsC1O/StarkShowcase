use starknet::ContractAddress;

trait IERC20DispatcherTrait<T> {
    fn name(self: T) -> felt252;
    fn transfer(self: T, recipient: ContractAddress, amount: u256);
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
}
