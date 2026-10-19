# Brewed Behavior: Question 1 counts
# Question: Who spends more on coffee each month, and who will pay more for a single
# cup: heavy drinkers, strong-coffee drinkers, or coffee enthusiasts?

library(tidyverse)
library(scales)

coffee <- read_csv("data/coffee_survey.csv", show_col_types = FALSE)

q1_vars <- c("cups", "strength", "expertise", "total_spend", "most_willing")

# 1. Missing data in each Question 1 variable (full dataset)
missing_by_variable <- coffee |>
  summarise(across(all_of(q1_vars),
                   list(n_missing   = ~ sum(is.na(.x)),
                        pct_missing = ~ round(mean(is.na(.x)) * 100, 1)))) |>
  pivot_longer(everything(),
               names_to = c("variable", ".value"),
               names_pattern = "(.*)_(n_missing|pct_missing)")
missing_by_variable

# 2. Building the shared sample
coffee <- coffee |>
  mutate(
    q1_complete       = if_all(all_of(q1_vars), ~ !is.na(.x)),
    missing_both_spend = is.na(total_spend) & is.na(most_willing)
  )

sample_flow <- coffee |>
  summarise(
    total_respondents         = n(),
    missing_any_q1_variable   = sum(!q1_complete),
    missing_both_spending     = sum(missing_both_spend),
    pct_missing_both_spending = round(mean(missing_both_spend) * 100, 1),
    analysis_sample           = sum(q1_complete)
  )
sample_flow

# Values for inline code in the write-up
n_total     <- nrow(coffee)
n_q1        <- sum(coffee$q1_complete)
n_excluded  <- n_total - n_q1
pct_dropoff <- round(mean(coffee$missing_both_spend) * 100)

# 3. Do excluded respondents differ? (supports the limitation statement- by confirming similarity in excluded respondents) # similar
dropoff_comparison <- coffee |>
  group_by(missing_both_spend) |>
  summarise(n = n(),
            mean_expertise = round(mean(expertise, na.rm = TRUE), 2),
            .groups = "drop")
dropoff_comparison

wilcox.test(expertise ~ missing_both_spend, data = coffee)

# 4. Recode groups in the shared sample (case definition for the plots)
level_order <- c("1 cup or less", "2 cups", "3+ cups",
                 "Light", "Medium", "Strong",
                 "Novice (1-3)", "Middle (4-6)", "Expert (7-10)")
trait_labels <- c(cups_group      = "Heavy drinkers (cups per day)",
                  strength_group  = "Strong-coffee drinkers (preferred strength)",
                  expertise_group = "Coffee enthusiasts (self-rated expertise)")

coffee_q1 <- coffee |>
  filter(q1_complete) |>
  mutate(
    cups_group = case_when(
      cups %in% c("Less than 1", "1")      ~ "1 cup or less",
      cups == "2"                          ~ "2 cups",
      cups %in% c("3", "4", "More than 4") ~ "3+ cups"
    ),
    strength_group = case_when(
      strength %in% c("Weak", "Somewhat light")         ~ "Light",
      strength == "Medium"                              ~ "Medium",
      strength %in% c("Somewhat strong", "Very strong") ~ "Strong"
    ),
    expertise_group = case_when(
      expertise <= 3 ~ "Novice (1-3)",
      expertise <= 6 ~ "Middle (4-6)",
      TRUE           ~ "Expert (7-10)"
    ),
    spend_tier = case_when(
      total_spend == "<$20"                              ~ "Under $20",
      total_spend %in% c("$20-$40", "$40-$60")           ~ "$20-$60",
      total_spend %in% c("$60-$80", "$80-$100", ">$100") ~ "$60+"
    ),
    spend_tier   = factor(spend_tier, levels = c("Under $20", "$20-$60", "$60+")),
    pays_15_plus = most_willing %in% c("$15-$20", "More than $20")
  )

q1_long <- coffee_q1 |>
  select(submission_id, spend_tier, pays_15_plus,
         cups_group, strength_group, expertise_group) |>
  pivot_longer(c(cups_group, strength_group, expertise_group),
               names_to = "trait", values_to = "level") |>
  mutate(trait = factor(trait, levels = names(trait_labels),
                        labels = trait_labels),
         level = factor(level, levels = level_order))

# 5. Group sizes (the n shown in both plots)
group_sizes <- q1_long |>
  count(trait, level, name = "n")
group_sizes

# 6. Plot 1 counts: monthly spending tier by group
plot1_counts <- q1_long |>
  count(trait, level, spend_tier) |>
  group_by(trait, level) |>
  mutate(pct = round(n / sum(n) * 100, 1)) |>
  ungroup()

# Wide version: one row per group, counts and percentages side by side
plot1_table <- plot1_counts |>
  pivot_wider(names_from = spend_tier, values_from = c(n, pct),
              names_glue = "{spend_tier} ({.value})") |>
  mutate(total_n = rowSums(across(ends_with("(n)"))))
plot1_table

# 7. Plot 2 counts: willing to pay $15+ by group, with 95% CI
plot2_table <- q1_long |>
  group_by(trait, level) |>
  summarise(n          = n(),
            n_willing  = sum(pays_15_plus),
            p          = n_willing / n,
            .groups    = "drop") |>
  mutate(
    se        = sqrt(p * (1 - p) / n),
    pct       = round(p * 100, 1),
    ci_lower  = round(pmax(p - 1.96 * se, 0) * 100, 1),
    ci_upper  = round(pmin(p + 1.96 * se, 1) * 100, 1)
  ) |>
  select(trait, level, n, n_willing, pct, ci_lower, ci_upper)
plot2_table

# Change from lowest to highest group in each characteristic (panel labels)
plot2_gaps <- plot2_table |>
  group_by(trait) |>
  summarise(lowest  = first(pct),
            highest = last(pct),
            gap_points = round(last(pct) - first(pct)),
            .groups = "drop")
plot2_gaps

# Overall share willing to pay $15+ in the analysis sample
overall_willing <- round(mean(coffee_q1$pays_15_plus) * 100, 1)
overall_willing

# Optional: print tables neatly in the rendered write-up
knitr::kable(plot1_table)
knitr::kable(plot2_table)

# =============================================================================
# Brewed Behavior: Question 1 plots
#
# Plot 1: 100% stacked horizontal bars of monthly spending (with group sizes)
# Plot 2: connected dot plot of the share willing to pay $15+ per cup
#
# Both plots use one shared sample: respondents who answered all five
# Question 1 variables, so group sizes match across the two plots.
# =============================================================================

# Spending tiers: one gold-brown hue with large lightness steps, so the order
# stays readable with colour blindness and in greyscale
tier_colours <- c("Under $20" = "#F2C14E",
                  "$20-$60"   = "#A8741A",
                  "$60+"      = "#3E2A0E")
highlight  <- "#7A4E12"   # deep brown, matching Plot 1's darkest tier
base_line  <- "#707070"   # mid-grey for the other two panels
panel_grey <- "#EDEDED"
ink        <- "#1F2933"

source_caption <- "Source: Great American Coffee Taste Test (2023), via TidyTuesday (2024-05-14)"

theme_q1 <- function(base_size = 15) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = panel_grey, colour = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "white", linewidth = 0.6),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title    = element_text(face = "bold", size = rel(1.3), colour = ink),
      plot.subtitle = element_text(colour = "grey35", margin = margin(b = 12)),
      plot.caption  = element_text(colour = "grey50", size = rel(0.65),
                                   hjust = 0, margin = margin(t = 12)),
      strip.text    = element_text(face = "bold", colour = ink, hjust = 0,
                                   size = rel(1)),
      axis.text     = element_text(colour = ink),
      plot.margin   = margin(18, 25, 12, 18)
    )
}

# Data preparation
q1_vars <- c("cups", "strength", "expertise", "total_spend", "most_willing")

trait_labels <- c(cups_group      = "Heavy drinkers (cups per day)",
                  strength_group  = "Strong-coffee drinkers (preferred strength)",
                  expertise_group = "Coffee enthusiasts (self-rated expertise)")
level_order <- c("1 cup or less", "2 cups", "3+ cups",
                 "Light", "Medium", "Strong",
                 "Novice (1-3)", "Middle (4-6)", "Expert (7-10)")

coffee_q1 <- coffee |>
  filter(if_all(all_of(q1_vars), ~ !is.na(.x))) |>
  mutate(
    cups_group = case_when(
      cups %in% c("Less than 1", "1")      ~ "1 cup or less",
      cups == "2"                          ~ "2 cups",
      cups %in% c("3", "4", "More than 4") ~ "3+ cups"
    ),
    strength_group = case_when(
      strength %in% c("Weak", "Somewhat light")         ~ "Light",
      strength == "Medium"                              ~ "Medium",
      strength %in% c("Somewhat strong", "Very strong") ~ "Strong"
    ),
    expertise_group = case_when(
      expertise <= 3 ~ "Novice (1-3)",
      expertise <= 6 ~ "Middle (4-6)",
      TRUE           ~ "Expert (7-10)"
    ),
    spend_tier = case_when(
      total_spend == "<$20"                              ~ "Under $20",
      total_spend %in% c("$20-$40", "$40-$60")           ~ "$20-$60",
      total_spend %in% c("$60-$80", "$80-$100", ">$100") ~ "$60+"
    ),
    spend_tier   = factor(spend_tier, levels = names(tier_colours)),
    pays_15_plus = most_willing %in% c("$15-$20", "More than $20")
  )

n_q1 <- nrow(coffee_q1)   # use inline in the write-up: `r n_q1`

# One row per respondent per trait; group labels include the group size
q1_long <- coffee_q1 |>
  select(submission_id, spend_tier, pays_15_plus,
         cups_group, strength_group, expertise_group) |>
  pivot_longer(c(cups_group, strength_group, expertise_group),
               names_to = "trait", values_to = "level") |>
  mutate(trait = factor(trait, levels = names(trait_labels),
                        labels = trait_labels),
         level = factor(level, levels = level_order)) |>
  add_count(trait, level, name = "group_n") |>
  mutate(level_n = paste0(level, "\n(n = ", comma(group_n), ")"),
         level_n = fct_reorder(level_n, as.numeric(level)))

# PLOT 1: Monthly spending, 100% stacked horizontal bars

plot1_data <- q1_long |>
  count(trait, level_n, spend_tier) |>
  group_by(trait, level_n) |>
  mutate(share = n / sum(n)) |>
  ungroup()

plot1 <- ggplot(plot1_data,
                aes(x = share, y = fct_rev(level_n), fill = spend_tier)) +
  geom_col(width = 0.72, colour = "grey15", linewidth = 0.3,
           position = position_fill(reverse = TRUE)) +
  # Percentages inside segments; dark text on the light tier, white elsewhere
  geom_text(aes(group = spend_tier,
                label = if_else(share >= 0.07, percent(share, accuracy = 1), ""),
                colour = spend_tier == "Under $20"),
            position = position_fill(vjust = 0.5, reverse = TRUE),
            size = 4.3, show.legend = FALSE) +
  facet_wrap(~ trait, ncol = 1, scales = "free_y") +
  scale_x_continuous(labels = label_percent(), breaks = seq(0, 1, 0.1),
                     expand = expansion(mult = c(0, 0.01))) +
  scale_fill_manual(values = tier_colours, name = "Monthly coffee spending:") +
  scale_colour_manual(values = c(`TRUE` = ink, `FALSE` = "white")) +
  labs(
    title    = "Who spends more on coffee each month?",
    subtitle = "Heavy drinkers and enthusiasts are the most likely to spend $60 or more a month",
    x = NULL, y = NULL, caption = source_caption
  ) +
  theme_q1() +
  theme(legend.position      = "top",
        legend.justification = "left",
        panel.grid.major.y   = element_blank(),
        panel.spacing.y      = unit(1, "lines"),
        axis.text.y          = element_text(lineheight = 0.9))

ggsave("final_plots/q1_final_plot1_monthly_spend.png", plot1,
       width = 12, height = 9, dpi = 300)


# PLOT 2: Willing to pay $15+, connected dot plot

plot2_data <- q1_long |>
  group_by(trait, level, level_n, group_n) |>
  summarise(p = mean(pays_15_plus), .groups = "drop") |>
  mutate(
    se    = sqrt(p * (1 - p) / group_n),
    lower = pmax(p - 1.96 * se, 0),
    upper = pmin(p + 1.96 * se, 1),
    is_highlight = trait == "Coffee enthusiasts (self-rated expertise)"
  )

# Lowest-to-highest change in each panel, in percentage points
plot2_gap <- plot2_data |>
  group_by(trait, is_highlight) |>
  summarise(gap = (last(p) - first(p)) * 100, .groups = "drop") |>
  mutate(label = sprintf("%+.0f points", gap))

plot2 <- ggplot(plot2_data,
                aes(x = level_n, y = p, colour = is_highlight,
                    group = trait)) +
  geom_line(linewidth = 1.4) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.08,
                linewidth = 0.8) +
  geom_point(shape = 21, size = 4.5, stroke = 1.6, fill = "white") +
  # Values sit to the right of each point, clear of whiskers and lines
  geom_text(aes(label = percent(p, accuracy = 1)), hjust = 0,
            nudge_x = 0.12, nudge_y = -0.014, size = 4.4, fontface = "bold",
            show.legend = FALSE) +
  geom_text(data = plot2_gap,
            aes(x = 1, y = 0.47, label = label, colour = is_highlight),
            inherit.aes = FALSE, hjust = 0.2, size = 5.2, fontface = "bold",
            show.legend = FALSE) +
  facet_wrap(~ trait, scales = "free_x",
             labeller = labeller(trait = \(x) str_replace(x, " \\(", "\n("))) +
  scale_y_continuous(labels = label_percent(), limits = c(0, 0.5),
                     breaks = seq(0, 0.5, 0.1)) +
  scale_colour_manual(values = c(`TRUE` = highlight, `FALSE` = base_line),
                      guide = "none") +
  labs(
    title    = "Enthusiasts show the steepest rise in willingness to pay a premium",
    subtitle = "Share willing to pay $15 or more for a single cup; whiskers show 95% confidence intervals",
    x = NULL, y = "Willing to pay $15+", caption = source_caption
  ) +
  theme_q1() +
  theme(panel.grid.major.x = element_blank(),
        panel.spacing.x    = unit(1.8, "lines"),
        axis.text.x        = element_text(lineheight = 0.9),
        axis.title.y       = element_text(colour = "grey35",
                                          margin = margin(r = 10)))

ggsave("final_plots/q1_final_plot2_willing_to_pay.png", plot2,
       width = 13, height = 6.5, dpi = 300)

