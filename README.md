# Estimation and Detection Theory – Assignments 2024/2025

This repository contains the assignments for the **Estimation and Detection Theory** course at ECE AUTH for the 2024–2025 academic year.

**Authors:** Georgios Rousomanis (10703), Aristeidis Daskalopoulos (10640)

## 📂 Repository Structure

* **`PartA/`**: Literature assignment on biased estimation, exploring bounds and asymptotically optimal estimators.
* **`PartB/`**: Computational assignment implementing Wiener filters for denoising multichannel signals.

## Part A: Biased Estimation Theory

* Focuses on understanding **variance-bias trade-offs** and deriving bounds for biased estimators.
* Discusses **optimal estimators** in linear Gaussian models and their asymptotic properties.
* Highlights methods to achieve minimum variance under different bias constraints.

## Part B: Multichannel Signal Denoising

* Implements **Wiener filtering** to remove artifacts from multichannel EEG signals.
* Compares **offline smoothing** (using full signal data) versus **online filtering** (real-time estimation).
* Demonstrates that **multi-channel smoothing** significantly improves estimation accuracy by leveraging inter-channel correlations.
* Notes practical limitations when high-energy, non-linear artifacts occur, recommending preprocessing for artifact detection.
