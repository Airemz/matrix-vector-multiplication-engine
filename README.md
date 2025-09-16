# Matrix-Vector Multiplication (MVM) Engine

A pipelined **Matrix-Vector Multiplication (MVM) engine** written in Verilog/SystemVerilog.  
This project was developed as part of a hardware design lab to explore datapath design, pipelining, and parallel computation.

## 📌 Overview
The engine performs matrix-vector multiplication using a modular design:
- **Dot-product unit (`dot8.sv`)** – computes partial dot products across 8 lanes in parallel.
- **Accumulator (`accum.sv`)** – accumulates intermediate sums over multiple cycles.
- **Memory (`mem.sv`)** – stores input vectors/matrix rows for computation.
- **Controller (`ctrl.sv`)** – manages pipeline flow and synchronization.
- **Top-level (`mvm.sv`)** – integrates all components into a working matrix-vector engine.

The design is pipelined for improved throughput, allowing multiple operations to overlap.

## 🛠️ Features
- **Pipelined datapath** for higher throughput.
- **Parallelism** using multiple dot-product lanes.
- **Modular design** with clear separation of datapath, control, and memory.
- **Scalable** — can be extended for larger matrices/vectors.
