module contracts::hello_world;
// Imports
use std::string::String;

// Errors

// Constants
const MS_IN_DAY: u64 = 24 * 60 * 60 * 1000;
// Structs

public struct MessageContainer {
    id: UID,
    message: String,
    author: address
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

public fun change_message(container: &mut MessageContainer, message: String) {
    container.message = message;

    // change author
}

public fun get_message(container: &MessageContainer): String {
    container.message
}

fun change_author(container: &mut MessageContainer, author: address) {
    container.author = author;
}


// Test helpers