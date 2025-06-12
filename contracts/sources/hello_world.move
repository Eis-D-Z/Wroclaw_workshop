module contracts::hello_world;
// Imports
use std::string::String;

// Errors
const ENotAllowed: u64 = 101;

// Structs

public struct MessageContainer {
    id: UID,
    message: String,
    author: address,
} has key, store;


// Functions

public fun new_container(message: String, ctx: &mut TxContext): MessageContainer
{
    let container = MessageContainer {
        id: object::new(ctx),
        message,
        author: ctx.sender()
    };
    
    container
}

public fun change_message(container: &mut MessageContainer, message: String, ctx: &TxContext) {
    container.message = message;

    // change author
    assert!(ctx.sender() != @0x2, ENotAllowed);

    change_author(container, ctx.sender());
}

public fun get_message(container: &MessageContainer): String {
    container.message
}

fun change_author(container: &mut MessageContainer, author: address) {
    container.author = author;
}

// getters
#[test_only]
public fun message(self: &MessageContainer): String {
    self.message
}


// Test helpers

