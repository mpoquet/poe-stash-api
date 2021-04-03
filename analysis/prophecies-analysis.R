#!/usr/bin/env Rscript
library(tidyverse)
library(viridis)
library(treemap)

theme_set(theme_bw())

raw_data = read_csv('character-level-30.csv', comment='#')
seal_cost = read_csv('prophecies-seal-cost.csv', comment='#')
tiers = read_csv('prophecies-tiers.csv', comment='#')

data = inner_join(raw_data, inner_join(seal_cost, tiers))
total_nb_prophecies = sum(data$count)

data = data %>% mutate(
  total_sc_cost = count * (seal_cost+1),
  probability = count / total_nb_prophecies,
) %>% mutate(
  probability_percent_lab = sprintf("%02.2f ‰", probability*1000)
)
nb_silver_coins_used = sum(data$total_sc_cost)

write_csv(data, "./analyzed-data.csv")

# raw visualization
ggplot(data, aes(x=reorder(item, count), y=count, fill=tier)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(expand=c(0.01,0.01)) +
  scale_fill_viridis(discrete=TRUE) +
  labs(y="Number of prophecies") +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.7,0.1),
    legend.title = element_blank(),
    axis.title.y = element_blank(),
    axis.text = element_text(size=8),
    panel.grid.major.x = element_blank(),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-count-barchart.png', width=8, height=16)

# sealing cost of each prophecy
ggplot(data, aes(x=reorder(item, count), y=seal_cost, fill=tier)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(expand=c(0.01,0.01)) +
  scale_fill_viridis(discrete=TRUE) +
  labs(y="Sealing cost") +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.75,0.1),
    legend.title = element_blank(),
    axis.title.y = element_blank(),
    axis.text = element_text(size=8),
    panel.grid.major.x = element_blank(),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-sealcost-barchart.png', width=8, height=4)

# treemap
png(filename="/tmp/prophecies-count-treemap.png", width=2400, height=1200)
treemap(data,
  index = c("tier","item"),
  vSize = "count",
  type = "index",
  fontsize.labels = c(48,36),
  palette = viridis_pal()(4),
  border.col = c("white","white"),
  border.lwds = c(21,6),
  align.labels = list(
    c("left", "top"),
    c("center", "center")
  ),
  title = "Prophecies distribution. Area is proportional to number of prophecies.",
  fontsize.title=60,
)
dev.off()

# treemap with probabilities
png(filename="/tmp/prophecies-count-treemap-labels-proba.png", width=2400, height=1200)
treemap(data %>% mutate(label=paste(item, probability_percent_lab, sep="\n")),
  index = c("tier","label"),
  vSize = "count",
  type = "index",
  fontsize.labels = c(48,36),
  palette = c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c"),
  border.col = c("black","white"),
  border.lwds = c(21,6),
  align.labels = list(
    c("left", "top"),
    c("center", "center")
  ),
  title = "Prophecies distribution. Area is proportional to number of prophecies.",
  fontsize.title=60,
)
dev.off()

# which ones to block?
data %>% ggplot(aes(x=reorder(item, total_sc_cost), y=total_sc_cost, fill=tier)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(expand=c(0.01,0.01)) +
  scale_fill_viridis(discrete=TRUE) +
  labs(y="Total amount of silver coins used") +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.7,0.1),
    legend.title = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-cost-barchart.png', width=8, height=4)

palette_without_good = viridis_pal()(4)[-1]
data %>% filter(tier != "good") %>% ggplot(aes(x=reorder(item, total_sc_cost), y=total_sc_cost, fill=tier)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(expand=c(0.01,0.01)) +
  scale_fill_manual(values=palette_without_good) +
  labs(y="Total amount of silver coins used") +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.7,0.1),
    legend.title = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-waste-barchart.png', width=8, height=4)
