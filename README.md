# Metaphor Identification Using Large Language Models

## Overview

This repository accompanies the paper *“Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning”* by Fuoli et al. (2025), available as a preprint on [arXiv](https://arxiv.org/abs/2509.24866).

The repository contains all materials and code necessary to **replicate the study**, which investigates how large language models (LLMs) can be used to automatically identify and annotate metaphorical expressions in full texts. We compare three core approaches:

1. **Retrieval-Augmented Generation (RAG):** Supplying the model with an external codebook to guide annotation.
2. **Prompt Engineering:** Using zero-shot, few-shot, and chain-of-thought strategies to guide LLM outputs.
3. **Fine-Tuning:** Training the model on a subset of hand-annotated texts to optimize performance.

Our results show that state-of-the-art closed-source LLMs can achieve **high accuracy**, with fine-tuning reaching a **median F1 score of 0.79**. This demonstrates the potential for LLMs to semi-automate metaphor identification, making large-scale metaphor analysis more efficient and scalable.

---

## Repository Contents

- **Corpus/** – IMDb film reviews used in the study, including:
  - *Uncoded dataset*
  - *Human-annotated gold-standard dataset* (CSV and XML formats)
- **Resources/** – Full set of prompts used in experiments and detailed annotation manual used to create the gold-standard dataset.
- **Scripts/** – Annotated Jupyter notebooks for running experiments and evaluating output.
- **Results/** – Results table (CSV format) and R scripts for statistical analysis.

---

## Citation

If you use this repository or its resources in your research, please cite the paper as follows:

```
Fuoli, M., Huang, W., Littlemore, J., Turner, S., & Wilding, E. (2025). 
Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning.
arXiv preprint, arXiv:2509.24866
```

**BibTeX format:**

```bibtex
@article{fuoli2025metaphor,
  title={Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning},
  author={Fuoli, Matteo and Huang, Weihang and Littlemore, Jeannette and Turner, Sarah and Wilding, Ellen},
  journal={arXiv preprint arXiv:2509.24866},
  year={2025}
}
```
