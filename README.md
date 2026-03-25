# Metaphor Identification Using Large Language Models

## Overview

This repository accompanies the paper *“Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning”* by Fuoli et al. (2026), published open access in _Applied Corpus Linguistics_ and available here: [https://doi.org/10.1016/j.acorp.2026.100204](https://doi.org/10.1016/j.acorp.2026.100204).

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
Fuoli, M., Huang, W., Littlemore, J., Turner, S., & Wilding, E. (2026). 
Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning.
Applied Corpus Linguistics, DOI: https://doi.org/10.1016/j.acorp.2026.100204.
```

**BibTeX format:**

```bibtex
@article{fuoli2026metaphor,
  title={Metaphor Identification Using Large Language Models: A Comparison of RAG, Prompt Engineering, and Fine-Tuning},
  author={Fuoli, Matteo and Huang, Weihang and Littlemore, Jeannette and Turner, Sarah and Wilding, Ellen},
  journal={Applied Corpus Linguistics},
  year={2026},
  doi={10.1016/j.acorp.2026.100204}
}
```
