---
title: Conway's Game of Life in Rust with macroquad
date: 2022-09-28
description: Using macroquad library to make a simple Conway's Game of Life
---

[Macroquad](https://macroquad.rs) is a small Rust library to make graphical apps with little code. Think it as a [LÖVE](https://love2d.org) or a [Processing](https://processing.org) but for Rust.
I wanted to test it by making an implementation of [Conway's game of life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

# Result
![Screenshot](../img/conway-rust.png)

# Data structure
Very simple. Justa a matrix of boolean values indicating if the cell is alive or not.
```{.rust}
#[derive(Clone)]
pub struct World {
    step: u32,
    width: usize,
    height: usize,
    cells: Vec<Vec<bool>>,
}
```

# Functions
```{.rust}
// Compute the next step of the world
fn update_world(world_now: &World, world_next: &mut World)
// Compute the number of alive neighbours of a cell at i row, and j column
fn alive_neighbours(w: &World, i: usize, j: usize) -> usize
// Selects the neighbours of a cell at i row and j column
fn neighbours(world: &World, i: usize, j: usize) -> Vec<bool>
```

# Tests
The most important tests check the count of alive neighbours with special attention to wrapping (when you overflow or underflow the index of the world and it gets wrapped like a 'round' globe world). And the basic rules:

```{.console}
cni@mil:(master)$~/D/P/P/r/m/conway(148)$ cargo t
   Compiling conway v0.1.0 (/home/cnidario/Documents/Personal/Proyectos/rust/macroquad/conway)
    Finished test [unoptimized + debuginfo] target(s) in 1.58s
     Running unittests src/main.rs (target/debug/deps/conway-aeaeacb751c479dd)

running 4 tests
test tests::test_neighbour_count ... ok
test tests::test_superpopulation_and_reproduce ... ok
test tests::test_underpopulation ... ok
test tests::test_blinker ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

1. Neighbour count
```{.rust}
    #[test]
    fn test_neighbour_count() {
        let world0 = world_from_map(&vec![F, T, F, T, T, T, F, T, F], 3);
        assert_eq!(alive_neighbours(&world0, 0, 0), 5);
        assert_eq!(alive_neighbours(&world0, 0, 1), 4);
        assert_eq!(alive_neighbours(&world0, 0, 2), 5);
        assert_eq!(alive_neighbours(&world0, 1, 0), 4);
        assert_eq!(alive_neighbours(&world0, 1, 1), 4);
        assert_eq!(alive_neighbours(&world0, 1, 2), 4);
        assert_eq!(alive_neighbours(&world0, 2, 0), 5);
        assert_eq!(alive_neighbours(&world0, 2, 1), 4);
        assert_eq!(alive_neighbours(&world0, 2, 2), 5);
    }
```
2. Underpopulation
```{.rust}
    #[test]
    fn test_underpopulation() {
        let world0 = world_from_map(&vec![F, F, T, F], 2);
        let world1 = world_from_map(&vec![F, F, F, F], 2);
        let world_before = world0.clone();
        let mut world_next = world0.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world1.cells);
        let world_before = world_next.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world1.cells);
    }
```
3. Superpopulation & reproduce
```{.rust}
    #[test]
    fn test_superpopulation_and_reproduce() {
        let world0 = world_from_map(
            &vec![
                F, F, F, F, F, F, F, T, F, F, F, T, T, T, F, F, F, T, F, F, F, F, F, F, F,
            ],
            5,
        );
        let world1 = world_from_map(
            &vec![
                F, F, F, F, F, F, T, T, T, F, F, T, F, T, F, F, T, T, T, F, F, F, F, F, F,
            ],
            5,
        );
        let world_before = world0.clone();
        let mut world_next = world0.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world1.cells);
    }
```
4. Blinker. A blinker is an special pattern of Conway's game of life, the simplest oscillator.
```{.rust}
    #[test]
    fn test_blinker() {
        let world0 = world_from_map(&BLINKER0.to_vec(), 5);
        let world1 = world_from_map(&BLINKER1.to_vec(), 5);
        let world_before = world0.clone();
        let mut world_next = world0.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world1.cells);
        //
        let world_before = world_next.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world0.cells);
        //
        let world_before = world_next.clone();
        update_world(&world_before, &mut world_next);
        assert_eq!(world_next.cells, world1.cells);
    }
```
# Comments
 - Macroquad is an easy library, and Conway's game of life is an easy exercise to implement, while learning Rust.
 - Maybe my solution is not very efficient, because it relies in copying the world state every step. It also steps over each array location. Though not copying the state would complicate the logic (or the data structure). I think also that my solution trashes an entire world of cells matrix every step causing maybe lots of memory allocations and deallocations, I could use in-place editing instead of this and rotate the 2 matrix each step. Anyway I should measure before making assumptions.
 - I regret the chosen data structure, it would be easier to implement with a flat vector, anyways the cell information is stored raw and does not use any kind of compression scheme (like in sparse structures).
 - Also `Vec<bool>` is not space-optimal. Would be interesting research into `bit-vec` or `bitvec` crates. Or maybe experimenting with `u8/u16/...` and use bit arithmetic.
 - An small efficiency improvement would be to calculate directly `alive_neighbours` without computing a vector of them.
 - I underestimated the 'simple' neighbours function at first (I didn't even plan at the beginning to make a test for this, but after some problems with a bad wrap arithmetic it helped me to solve it.
 - Rust type system is strong, and mostly helpful, sometimes tricky. I can write a lot with some kind of functional style, but not all I'll do with other functional language like Haskell.
 - Rust aritmetic comes also with strong guarantees, though you can really break your code (it's not bullet proof like its memory model).
 
Here is an example of an arithmetic unsafe program in Rust (it panics without noticing the programmer). You can test it online in [Rust Playground](https://play.rust-lang.org)
```{.rust}
fn main() {
    let mut u: usize = 0;
    u -= 1;
    println!("{u}");
}
```
Output
```{.console}
 Compiling playground v0.0.1 (/playground)
    Finished dev [unoptimized + debuginfo] target(s) in 2.42s
     Running `target/debug/playground`
thread 'main' panicked at 'attempt to subtract with overflow', src/main.rs:5:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
