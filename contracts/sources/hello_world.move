module contracts::hello_world;
// Imports
use std::string::String;
use sui::coin::Coin;
use sui::dynamic_field as df;
use sui::table::{Self, Table};

// Errors
const ENotAllowed: u64 = 101;
const EDoesNotHaveColor: u64 = 102;
const EFieldAlreadyExists: u64 = 103;
const EInexistentIndex: u64 = 104;

// Constant
const ADMIN_ADDRESS: address = @0x38e6bd6c23b8cd9b8ea0e18bd45da43406190df850b1d47614fd573eac41a913;

// Structs
public struct MessageContainer {
    id: UID,
    message: String,
    author: address,
    old_messages: Table<u64, String>
} has key, store;

public struct Keys {} has copy, drop, store;

// Functions

public fun new_container(message: String, ctx: &mut TxContext): MessageContainer
{
    let container = MessageContainer {
        id: object::new(ctx),
        message,
        old_messages: table::new<u64, String>(ctx),
        author: ctx.sender()
    };
    
    container
}

public fun new_payed_container<T>(message: String, coin: Coin<T>, ctx: &mut TxContext): MessageContainer {
    transfer::public_transfer(coin, ADMIN_ADDRESS);
    new_container(message, ctx)
}

public fun change_message(container: &mut MessageContainer, message: String, ctx: &TxContext) {
    // change author
    // assert!(ctx.sender() != @0x2, ENotAllowed);

    let new_key = container.old_messages.length();
    container.old_messages.add(new_key, container.message);
    container.message = message;

    change_author(container, ctx.sender());
}

public fun get_message(container: &MessageContainer): String {
    container.message
}

public fun get_old_message(object: &MessageContainer, index: u64): String {
    assert!(object.old_messages.contains(index), EInexistentIndex);
    *object.old_messages.borrow(index)
}

public fun delete_old_message(object: &mut MessageContainer, index: u64) {
    assert!(object.old_messages.contains(index), EInexistentIndex);
    let _string = object.old_messages.remove(index);
}

public fun add_a_new_primitive_value<Value: store>(
    object: &mut MessageContainer,
    key: Keys,
    value: Value) {
        assert!(!df::exists_(&object.id, key), EFieldAlreadyExists);

        df::add<Keys, Value>(&mut object.id, key, value);
}


public fun add_color(object: &mut MessageContainer, color: vector<u8>) {
    df::add<String, vector<u8>>(
        &mut object.id,
        b"color".to_string(),
        color
    );
}

public fun get_color(object: &MessageContainer): vector<u8> {
    assert!(df::exists_(&object.id, b"color".to_string()), EDoesNotHaveColor);
    *df::borrow<String, vector<u8>>(&object.id, b"color".to_string())
}

public fun remove_color(object: &mut MessageContainer) {
    assert!(df::exists_(&object.id, b"color".to_string()), EDoesNotHaveColor);
    df::remove<String, vector<u8>>(&mut object.id, b"color".to_string());
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

