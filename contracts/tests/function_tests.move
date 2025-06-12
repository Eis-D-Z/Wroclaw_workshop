module 0x0::function_tests;

use sui::clock::{Self, Clock};
use sui::test_scenario::{Self as ts, Scenario};

use contracts::hello_world::{Self as mod, MessageContainer, ENotAllowed};


const USER: address = @0x12312312312;

#[test_only]
public fun setup(): Scenario {
    let mut scn = ts::begin(@0x0);
    {
        let mut clock = clock::create_for_testing(scn.ctx());
        clock.increment_for_testing(1000323232);
        clock.share_for_testing();
    };

    scn
}

#[test]
public fun create_new_message (): Scenario {
    let mut scn = setup();
    let message = b"Hi everyone".to_string();

    scn.next_tx(USER);
    {
        
        let object = mod::new_container(message, scn.ctx());
        let clock = scn.take_shared<Clock>();

        let now = clock.timestamp_ms();
        std::debug::print(&now);
        transfer::public_transfer(object, USER);
        ts::return_shared(clock);
    };

    scn.next_tx(USER);
    {
        let object = scn.take_from_sender<MessageContainer>();
        assert!(object.get_message() == message);

        scn.return_to_sender(object);
    };

    scn
}


#[test]
public fun change_message_test () {
    let mut scn = create_new_message();

    scn.next_tx(USER);
    let new_message = b"New one".to_string();
    {
        let mut object = scn.take_from_sender<MessageContainer>();
        object.change_message(new_message, scn.ctx());

        scn.return_to_sender(object);

    };

    scn.next_tx(USER);
    {
        let object = scn.take_from_sender<MessageContainer>();
        assert!(object.get_message() == new_message);

        scn.return_to_sender(object);
    };

    scn.end();
}

#[test]
#[expected_failure(abort_code=ENotAllowed)]
public fun test_0x2_not_allowed() {
    let mut scn = create_new_message();

    scn.next_tx(USER);
    {
        let object = scn.take_from_sender<MessageContainer>();
        transfer::public_transfer(object, @0x2);
    
    };

    scn.next_tx(@0x2);
    {
        let mut object = scn.take_from_sender<MessageContainer>();
        object.change_message(b"random".to_string(), scn.ctx());

        scn.return_to_sender(object);
    };

    scn.end();
}