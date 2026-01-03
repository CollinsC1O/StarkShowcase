//@dev: example below shows an example demonstrating how to use a library_call_syscall to call the
//set_value function of ValueStore contract:
#[starknet::contract]
mod valueStore {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ClassHash, SyscallResultTrait, syscalls};

    #[storage]
    struct Storage {
        logic_library: ClassHash,
        value: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, logic_library: ClassHash) {
        self.logic_library.write(logic_library);
    }

    #[external(v0)]
    fn set_value(ref self: ContractState, value: u128) -> bool {
        let mut calldata: Array<felt252> = array![];

        Serde::serialize(@value, ref calldata);

        let mut res = syscalls::library_call_syscall(
            self.logic_library.read(), selector!("set_value"), calldata.span(),
        )
            .unwrap_syscall();

        Serde::<bool>::deserialize(ref res).unwrap()
    }

    #[external(v0)]
    fn get_value(self: @ContractState) -> u128 {
        self.value.read()
    }
}
