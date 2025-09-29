#--------LIBRARIES--------

library(ggplot2)
library(dplyr)
library(glmmTMB)
library(marginaleffects)

#--------DATA IMPORT--------

raw <- read.csv("llm-metaphor-data.csv", header = TRUE, stringsAsFactors = TRUE)
raw$shots <- as.factor(raw$shots)
summary(raw)

#--------DESCRIPTIVE STATISTICS--------
#--------Boxplot comparing methods and models (Figure 1)--------
model_colors <- c("#e41a1c","#FF4C4C","#FF8485","#377eb8","#4daf4a","#63C361","#79D776","#984ea3","#B36DBE","#ff7f00")

raw$model <- factor(raw$model, level = c("Llama 3.1 8B", "Llama 3.2 3B", "Llama 3.2 1B",  "Deepseek R1 8B", "GPT 4.1", "GPT 4.1 mini", "GPT 4.1 nano", "o3", "o3 mini", "o4 mini")) # reorder models for plot clarity
raw$model_type <- factor(raw$model_type, level = c("Open source", "Closed source")) # reorder models for plot clarity
raw$method <- factor(raw$method, level = c("RAG", "Prompt engineering", "Fine-tuning")) # reorder models for plot clarity

ggplot(raw, aes(x = method, y = f1, fill = model)) +
  geom_boxplot(
    position = position_dodge(width = 0.85),
    notch = TRUE,         # add notches for median CI
    outlier.shape = NA,   # hide raw outlier points
    alpha = 1,
    size = 0.4
  ) +
  facet_grid(cols = vars(model_type)) +
  scale_fill_manual(values = model_colors) +
  scale_y_continuous(breaks = seq(0.1, 0.9, 0.1), expand = c(0, 0)) +
  coord_cartesian(ylim = c(0, 1)) +
  theme_linedraw() +
  labs(
    x = "Method",
    y = "F1 score",
    fill = "Model"
  )

# Print plot
ggsave("Figure 1.png", 
       plot = last_plot(), # or specify your ggplot object
       width = 11,         # Width in inches
       height = 6,        # Height in inches
       dpi = 400)         # Resolution in DPI

#--------Descriptive statistics for methods and models--------
# Median F1 scores
medians_meth <- raw %>%
  group_by(method, model) %>% # all the factors you want to keep, e.g. for plotting
  summarise(sum_variable_name = round(median(f1), 2), .groups = "drop")
print(medians_meth, n=26)

# Inter-quartile ranges
IQR_meth <- raw %>%
  group_by(method, model) %>% # all the factors you want to keep, e.g. for plotting
  summarise(
    Q1 = round(quantile(f1, probs = 0.25), 2),
    Q3 = round(quantile(f1, probs = 0.75), 2),
    .groups = "drop"
  )
print(IQR_meth, n=52)

#--------Boxplot comparing core prompt engineering strategies (Figure 2)--------
# Create new dataset that only contains the prompt engineering data
unwanted_approaches <- c('Fine-tuning','RAG')
prompts <- raw %>% filter(!method %in% unwanted_approaches) %>% 
  mutate(method = droplevels(method))
levels(prompts$method) # check this worked
summary(prompts)

prompts$model <- factor(prompts$model, level = c("Llama 3.1 8B", "Llama 3.2 3B", "Llama 3.2 1B",  "Deepseek R1 8B", "GPT 4.1", "GPT 4.1 mini", "GPT 4.1 nano", "o3", "o3 mini", "o4 mini")) # reorder models for plot clarity
prompts$model_type <- factor(prompts$model_type, level = c("Open source", "Closed source")) # reorder models for plot clarity
prompts$method <- factor(prompts$method, level = c("RAG", "Prompt engineering", "Fine-tuning")) # reorder models for plot clarity
prompts$macro_prompt <- factor(prompts$macro_prompt, level = c("Zero-shot", "Few-shot", "Chain-of-thought")) # reorder models for plot clarity

ggplot(prompts, aes(x = macro_prompt, y = f1, fill = model)) +
  geom_boxplot(
    position = position_dodge(width = 0.85),
    notch = TRUE,         # add notches for median CI
    outlier.shape = NA,   # hide raw outlier points
    alpha = 1,
    size = 0.4
  ) +
  facet_grid(cols = vars(model_type)) +
  scale_fill_manual(values = model_colors) +
  scale_y_continuous(breaks = seq(0.1, 0.9, 0.1), expand = c(0, 0)) +
  coord_cartesian(ylim = c(0, 1)) +
  theme_linedraw() +
  labs(
    x = "Prompting strategy",
    y = "F1 score",
    fill = "Model"
  )

# Print plot
ggsave("Figure 2.png", 
       plot = last_plot(), # or specify your ggplot object
       width = 11,         # Width in inches
       height = 6,        # Height in inches
       dpi = 400)         # Resolution in DPI

#--------Descriptive statistics for core prompt engineering strategies--------
# Median F1 scores
medians_prompts <- prompts %>%
  group_by(macro_prompt, model) %>% # all the factors you want to keep, e.g. for plotting
  summarise(sum_variable_name = round(median(f1), 2), .groups = "drop")
print(medians_prompts, n=30)

# Inter-quartile ranges
IQR_meth <- prompts %>%
  group_by(macro_prompt, model) %>% # all the factors you want to keep, e.g. for plotting
  summarise(
    Q1 = round(quantile(f1, probs = 0.25), 2),
    Q3 = round(quantile(f1, probs = 0.75), 2),
    .groups = "drop"
  )
print(IQR_meth, n=30)

#--------BETA REGRESSION--------
#--------Comparison of methods--------
# Prep the data for regression
# Smithson–Verkuilen transformation (based on https://cran.r-project.org/web/packages/betareg/vignettes/betareg.html)
n <- nrow(raw)
raw$score_tr <- (raw$f1*(n-1) + 0.5)/n  
range(raw$score_tr)

# Center text length variable
raw$L_s <- scale(raw$L) # center length too to avoid problems with model fit

# Model 1 comparing methods
# RAG as baseline
raw$method <- relevel(raw$method, ref = "RAG")
mod1a <- glmmTMB(
  score_tr ~ method + model_type + L_s + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = raw,
  family = beta_family(link = "logit")   
)
summary(mod1a)

# Prompt engineering as baseline
raw$method <- relevel(raw$method, ref = "Prompt engineering")
mod1b <- glmmTMB(
  score_tr ~ method + model_type + L_s + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = raw,
  family = beta_family(link = "logit")   
)
summary(mod1b)

# Compute predicted delta F1 scores for model 1
raw$method <- relevel(raw$method, ref = "RAG")

# Delta F1 scores for method
avg_comparisons(
  mod1a,
  variables = list(method = "pairwise"),
  type = "response"
)

# Delta F1 scores for model type
avg_comparisons(
  mod1a,
  variables = list(model_type = "pairwise"),
  type = "response"
)

# Delta F1 scores for text length
avg_comparisons(
  mod1a,
  variables = "L_s",   
  type = "response"
)

# Extract predictions for specific LLMs
# GPT 4.1
raw_GPT4.1 <- subset(raw, model == "GPT 4.1")
mod_GPT4.1 <- glmmTMB(
  score_tr ~ method + L_s + (1 | textid) + (1 | experiment_seed),
  data   = raw_GPT4.1,
  family = beta_family(link = "logit")   
)
summary(mod_GPT4.1)

# Delta F1 scores for GPT 4.1
avg_comparisons(
  mod_GPT4.1,
  variables = list(method = "pairwise"),
  type = "response"
)

# Llama 3.1 8B
raw_Llama <- subset(raw, model == "Llama 3.1 8B")
mod_Llama <- glmmTMB(
  score_tr ~ method + L_s + (1 | textid) + (1 | experiment_seed),
  data   = raw_Llama,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod_Llama)

# Delta F1 scores for Llama 3.1 8B
avg_comparisons(
  mod_Llama,
  variables = list(method = "pairwise"),
  type = "response"
)

#--------Comparison of prompt engineering strategies--------
# Prep the data for regression
# Smithson–Verkuilen transformation (based on https://cran.r-project.org/web/packages/betareg/vignettes/betareg.html)
n <- nrow(prompts)
prompts$score_tr <- (prompts$f1*(n-1) + 0.5)/n  
range(prompts$score_tr)

# Center text length variable
prompts$L_s <- scale(prompts$L) # center length too to avoid problems with model fit

# Model 2 comparing prompting strategies
# Zero-shot as baseline
prompts$macro_prompt <- relevel(prompts$macro_prompt, ref = "Zero-shot")
mod2a <- glmmTMB(
  score_tr ~ macro_prompt + L_s + model_type + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = prompts,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod2a)

# Few-shot as baseline
prompts$macro_prompt <- relevel(prompts$macro_prompt, ref = "Few-shot")
mod2b <- glmmTMB(
  score_tr ~ macro_prompt + L_s + model_type + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = prompts,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod2b)

# Compute predicted delta F1 scores
prompts$macro_prompt <- relevel(prompts$macro_prompt, ref = "Zero-shot")

# Delta F1 scores for strategy
avg_comparisons(
  mod2a,
  variables = list(macro_prompt = "pairwise"),
  type = "response"
)

# Delta F1 scores for model type
avg_comparisons(
  mod2a,
  variables = list(model_type = "pairwise"),
  type = "response"
)

# Delta F1 scores for text length
avg_comparisons(
  mod2a,
  variables = "L_s",   # your continuous predictor
  type = "response"
)

#--------Effects of number and composition of examples--------
# Model 3 comparing 0, 4, and 8 shots
# 0-shot as baseline as baseline
prompts$shots <- relevel(prompts$shots, ref = "0")
mod3a <- glmmTMB(
  score_tr ~ shots + model_type + L_s + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = prompts,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod3a)

# 4-shot as baseline as baseline
prompts$shots <- relevel(prompts$shots, ref = "4")
mod3b <- glmmTMB(
  score_tr ~ shots + model_type + L_s + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = prompts,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod3b)

# Compute predicted delta F1 scores
prompts$shots <- relevel(prompts$shots, ref = "0")

# Delta F1 scores for number of shots
avg_comparisons(
  mod3a,
  variables = list(shots = "pairwise"),
  type = "response"
)

# Model 4 assessing effect of creativeconventional vs creative metaphor ration
prompt_ratio <- prompts[prompts$macro_prompt != "Zero-shot", ] # drop zero shots because test doesn't apply
prompt_ratio <- droplevels(prompt_ratio)

mod4 <- glmmTMB(
  score_tr ~ ratio + model_type + L_s + (1 | model) + (1 | textid) + (1 | experiment_seed),
  data   = prompt_ratio,
  family = beta_family(link = "logit")   # logit link is conventional
)
summary(mod4)

# Compute predicted delta F1 scores
# Delta F1 scores for metaphor type ratio
avg_comparisons(
  mod4,
  variables = list(ratio = "pairwise"),
  type = "response"
)


