extern crate aoc_runner;
#[macro_use]
extern crate aoc_runner_derive;

mod common {
    pub mod direction;
    pub mod parse_error;
    pub mod vector2;
}

mod solutions {
    pub mod day01;
    pub mod day02;
    pub mod day03;
}

aoc_lib! { year = 2020 }
