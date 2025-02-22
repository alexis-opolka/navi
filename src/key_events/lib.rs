extern crate uinput;

use uinput::event::keyboard;
use std::thread;
use std::time::Duration;

pub fn test() {
    let mut device = uinput::default().unwrap()
        .name("test").unwrap()
        .event(uinput::event::Keyboard::All).unwrap()
        .create().unwrap();

    device.synchronize().unwrap();

    println!("I'm linked!");
}
