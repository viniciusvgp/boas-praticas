#!/bin/bash
#SBATCH --nodes=2
#SBATCH --partition=hype
#SBATCH --time=00:40:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

# Comandos para execução do experimento
